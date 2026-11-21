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
  void dehOn_noLastReading_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.empty());

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);
  }

  @Test
  void dehOn_lastReadingZeroWattsDuringActiveHours_waitsFiveMinutesThenBlinksLedUnderTvAndSendsFcm() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    // First detection starts the 5-minute delay -> no alert yet
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(4).plusSeconds(55));
    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);

    // 5 minutes elapsed -> blink + FCM alert
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));
    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_justSwitchedOnWithFullBucket_alertsAfterFiveMinutes() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, DAYTIME_UTC)));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(4));
    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));
    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_briefPowerDipUnderFiveMinutes_resetsTimerAndSendsNoAlert() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    // Starts low-power timer at t=0, stays low at t=4m
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(4));

    // Recovers at t=4m30s -> resets timer
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(102.4)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(4).plusSeconds(30));

    // Drops again at t=5m -> starts fresh 5-minute timer, so no alert at t=5m or t=9m
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(9));

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);

    // Alerts once the fresh 5-minute timer completes at t=10m
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(10));
    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_fcmReminderRateLimitedToEvery30MinutesAndResetsOnRecovery() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    // First detection starts delay -> no alert yet
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);
    // 5 minutes later -> blink + FCM #1
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));
    // 5 seconds after alert -> blink, no new FCM
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5).plusSeconds(5));
    // 29 minutes after alert -> blink, still no new FCM
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(34));
    verify(fcmService, times(1)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");

    // 30 minutes after alert -> blink + FCM #2 reminder
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(35));
    verify(fcmService, times(2)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");

    // Bucket emptied (power recovers to 102.4W) -> resets both delay and FCM cooldown
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(102.4)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(36));

    // Drops back to 0W 2 minutes later -> requires another 5-minute delay before FCM #3
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(38));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(42));
    verify(fcmService, times(2)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");

    // 5 minutes after second drop -> blink + FCM #3
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(43));

    verify(fcmService, times(3)).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
    verify(messageSenderService, times(5)).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
  }

  @Test
  void dehOn_lastReadingBelowThresholdAt1059PmEst_blinksLedUnderTvAndSendsFcm() {
    // 22:54 EST = 03:54 UTC next day -> 22:59 EST = 03:59 UTC next day
    LocalDateTime startUtc = LocalDateTime.of(2026, 11, 21, 3, 54);
    LocalDateTime lateEveningUtc = LocalDateTime.of(2026, 11, 21, 3, 59);
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, startUtc.minusHours(1))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(49.9)));

    scheduledService.checkDehPowerAnomaly(startUtc);
    scheduledService.checkDehPowerAnomaly(lateEveningUtc);

    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
    verify(fcmService).sendAlert(FCM_TITLE, FCM_BODY, "gentle");
  }

  @Test
  void dehOn_quietHoursResetsPendingDelayTimer() {
    // 22:56 EST = 03:56 UTC -> starts timer, then 23:00 EST quiet hours resets it
    LocalDateTime beforeQuietUtc = LocalDateTime.of(2026, 11, 21, 3, 56);
    LocalDateTime quietUtc = LocalDateTime.of(2026, 11, 21, 4, 0);
    LocalDateTime nextMorningUtc = LocalDateTime.of(2026, 11, 21, 14, 0); // 09:00 EST
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, beforeQuietUtc.minusHours(1))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    scheduledService.checkDehPowerAnomaly(beforeQuietUtc);
    scheduledService.checkDehPowerAnomaly(quietUtc);
    // At 09:00 EST next morning, timer was reset so no immediate alert
    scheduledService.checkDehPowerAnomaly(nextMorningUtc);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);
  }

  @Test
  void dehOn_restartedBetweenTicks_resetsPendingDelayTimer() {
    LocalDateTime initialStart = DAYTIME_UTC.minusHours(1);
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, initialStart)));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    // DEH restarted at t+4m (without check seeing OFF) -> timer must restart at t+5m
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, DAYTIME_UTC.plusMinutes(4))));
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(5));
    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(fcmService);

    // 5 minutes after new detection (t+10m) -> alerts
    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC.plusMinutes(10));
    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
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
