package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceFacade;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import com.alexsoft.smarthouse.mqtt.MessageSenderService;
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

  @InjectMocks ScheduledService scheduledService;

  private static final String BLINK_PAYLOAD = "{\"effect\": \"blink\"}";
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
    verifyNoInteractions(indicationRepositoryV3);
  }

  @Test
  void dehNotFound_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.empty());

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3);
  }

  @Test
  void dehOn_switchedOnNull_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, null)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3);
  }

  @Test
  void dehOn_withinStartupGracePeriod_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, DAYTIME_UTC.minusMinutes(3))));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    verifyNoInteractions(indicationRepositoryV3);
  }

  @Test
  void dehOn_noLastReading_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.empty());

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
  }

  @Test
  void dehOn_lastReadingZeroWattsDuringActiveHours_blinksOnlyLedUnderTv() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(0.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
  }

  @Test
  void dehOn_lastReadingBelowThresholdAt1059PmEst_blinksLedUnderTv() {
    // 22:59 EST = 03:59 UTC next day
    LocalDateTime lateEveningUtc = LocalDateTime.of(2026, 11, 21, 3, 59);
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON, lateEveningUtc.minusHours(1))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(49.9)));

    scheduledService.checkDehPowerAnomaly(lateEveningUtc);

    verify(messageSenderService).sendMessage(eq("zigbee2mqtt/LED_UNDER_TV/set"), eq(BLINK_PAYLOAD));
    verifyNoMoreInteractions(messageSenderService);
  }

  @Test
  void dehOn_at11PmEst_quietHoursNoAlertSent() {
    // 23:00 EST = 04:00 UTC next day
    LocalDateTime nightUtc = LocalDateTime.of(2026, 11, 21, 4, 0);

    scheduledService.checkDehPowerAnomaly(nightUtc);

    verifyNoInteractions(applianceService, indicationRepositoryV3, messageSenderService);
  }

  @Test
  void dehOn_at859AmEst_quietHoursNoAlertSent() {
    // 08:59 EST = 13:59 UTC
    LocalDateTime earlyMorningUtc = LocalDateTime.of(2026, 11, 20, 13, 59);

    scheduledService.checkDehPowerAnomaly(earlyMorningUtc);

    verifyNoInteractions(applianceService, indicationRepositoryV3, messageSenderService);
  }

  @Test
  void dehOn_lastReadingAtThreshold_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(50.0)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
  }

  @Test
  void dehOn_lastReadingAtOperatingPower_noAlertSent() {
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(dehOnLongRunning()));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("DEHUMIDIFIER", "power"))
        .thenReturn(Optional.of(powerReading(102.4)));

    scheduledService.checkDehPowerAnomaly(DAYTIME_UTC);

    verify(messageSenderService, never()).sendMessage(anyString(), anyString());
  }
}
