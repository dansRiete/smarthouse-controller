package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceFacade;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import com.alexsoft.smarthouse.mqtt.MessageSenderService;
import com.alexsoft.smarthouse.watchdog.internal.FcmService;
import com.alexsoft.smarthouse.watchdog.internal.ScheduledService;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static com.alexsoft.smarthouse.appliance.ApplianceState.OFF;
import static com.alexsoft.smarthouse.appliance.ApplianceState.ON;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScheduledServiceDehPowerAnomalyTest {

  @Mock ApplianceService applianceService;
  @Mock ApplianceFacade applianceFacade;
  @Mock IndicationRepositoryV3 indicationRepositoryV3;
  @Mock IndicationServiceV3 indicationServiceV3;
  @Mock MessageSenderService messageSenderService;
  @Mock FcmService fcmService;

  @InjectMocks ScheduledService scheduledService;

  private static final String BLINK_PAYLOAD = "{\"effect\": \"blink\"}";
  private static final String FCM_TITLE = "Dehumidifier Bucket Full";
  private static final String FCM_BODY = "Please empty the bucket";
  // 12:00 EST (17:00 UTC in November) — inside 9 AM to 11 PM window
  private static final LocalDateTime DAYTIME_UTC = LocalDateTime.of(2026, 11, 20, 17, 0);

  private Appliance deh(ApplianceState state, LocalDateTime switchedOn) {
    Appliance a = new Appliance();
    a.setCode("DEH");
    a.setZigbee2MqttTopic("zigbee2mqtt/DEHUMIDIFIER/set");
    a.setState(state, switchedOn);
    return a;
  }

  private Appliance dehOnLongRunning() {
    return deh(ON, DAYTIME_UTC.minusHours(1));
  }

  private IndicationV3 powerReading(double watts) {
    return IndicationV3.builder()
        .locationId("DEHUMIDIFIER")
        .measurementType("power")
        .value(watts)
        .utcTime(DAYTIME_UTC)
        .localTime(DAYTIME_UTC.minusHours(5))
        .build();
  }

  @Test
  void dehOff_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(OFF, DAYTIME_UTC.minusHours(1))));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3, fcmService);
  }

  @Test
  void dehNotFound_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.empty());

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3, fcmService);
  }

  @Test
  void dehOn_switchedOnNull_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, null)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3, fcmService);
  }

  @Test
  void dehOn_withinStartupGracePeriod_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, DAYTIME_UTC.minusMinutes(3))));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3, fcmService);
  }

  @Test
  void dehOn_noLastReading_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.empty());

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);
  }

  @Test
  void dehOn_lastReadingZeroWattsDuringActiveHours_blinksLedUnderTvAndSendsFcm() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_fcmReminderRateLimitedToEvery30MinutesAndResetsOnRecovery() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    // First detection -> blink + FCM #1
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    // 5 seconds later -> blink, no new FCM
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusSeconds(5));
    // 29 minutes later -> blink, still no new FCM
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(29));
    verify(fcmService, times(1)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");

    // 30 minutes later -> blink + FCM #2 reminder
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(30));
    verify(fcmService, times(2)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");

    // Bucket emptied (power recovers to 102.4W) -> resets cooldown
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(102.4)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(31));

    // Drops back to 0W 2 minutes later -> immediate FCM #3
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(33));

    verify(fcmService, times(3)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
    verify(messageSenderService, times(5)).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
  }

  @Test
  void dehOn_lastReadingBelowThresholdAt1059PmEst_blinksLedUnderTvAndSendsFcm() {
    // 22:59 EST = 03:59 UTC next day
    LocalDateTime lateEveningUtc = LocalDateTime.of(2026, 11, 21, 3, 59);
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, lateEveningUtc.minusHours(1))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(49.9)));

    scheduledService.checkDehPowerAnomaly(lateEveningUtc);

    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_at11PmEst_quietHoursNoAlertSent() {
    // 23:00 EST = 04:00 UTC next day
    LocalDateTime nightUtc = LocalDateTime.of(2026, 11, 21, 4, 0);

    scheduledService.checkDehPowerAnomaly(nightUtc);

    verifyNoInteractions(applianceService, indicationRepositoryV3, messageSenderService, fcmService);
  }

  @Test
  void dehOn_at859AmEst_quietHoursNoAlertSent() {
    // 08:59 EST = 13:59 UTC
    LocalDateTime earlyMorningUtc = LocalDateTime.of(2026, 11, 20, 13, 59);

    scheduledService.checkDehPowerAnomaly(earlyMorningUtc);

    verifyNoInteractions(applianceService, indicationRepositoryV3, messageSenderService, fcmService);
  }

  @Test
  void dehOn_lastReadingAtThreshold_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(50.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);
  }

  @Test
  void dehOn_lastReadingAtOperatingPower_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(102.4)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);
  }
}
