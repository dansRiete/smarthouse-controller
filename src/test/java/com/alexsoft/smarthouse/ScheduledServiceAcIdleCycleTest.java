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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static com.alexsoft.smarthouse.appliance.ApplianceState.OFF;
import static com.alexsoft.smarthouse.appliance.ApplianceState.ON;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScheduledServiceAcIdleCycleTest {

  @Mock ApplianceService applianceService;
  @Mock ApplianceFacade applianceFacade;
  @Mock IndicationRepositoryV3 indicationRepositoryV3;
  @Mock IndicationServiceV3 indicationServiceV3;
  @Mock MessageSenderService messageSenderService;

  @InjectMocks ScheduledService scheduledService;

  private Appliance createAc(ApplianceState state, LocalDateTime switchedOnUtc, LocalDateTime switchedOffUtc) {
    Appliance ac = new Appliance();
    ac.setCode("AC");
    ac.setAveragePeriodMinutes(1);
    if (switchedOnUtc != null) {
      ac.setState(ON, switchedOnUtc);
    }
    if (state == OFF && switchedOffUtc != null) {
      ac.setState(OFF, switchedOffUtc);
    } else {
      ac.setState(state);
    }
    return ac;
  }

  private Appliance createDeh(String zigbeeTopic, ApplianceState state, LocalDateTime switchedOnUtc) {
    Appliance deh = new Appliance();
    deh.setCode("DEH");
    deh.setZigbee2MqttTopic(zigbeeTopic);
    if (switchedOnUtc != null) {
      deh.setState(state, switchedOnUtc);
    } else {
      deh.setState(state);
    }
    return deh;
  }

  private Appliance createFan(ApplianceState state) {
    Appliance fan = new Appliance();
    fan.setCode("FAN");
    fan.setState(state);
    return fan;
  }

  private IndicationV3 powerReading(String locationId, double watts) {
    return IndicationV3.builder()
        .locationId(locationId)
        .measurementType("power")
        .value(watts)
        .build();
  }

  private void stubToggleStateMutation() {
    doAnswer(invocation -> {
      Appliance app = invocation.getArgument(0);
      ApplianceState newState = invocation.getArgument(1);
      LocalDateTime time = invocation.getArgument(2);
      app.setState(newState, time);
      return null;
    }).when(applianceFacade).toggle(any(), any(), any(), anyString(), eq(true));
  }

  @Test
  void dehRunningAtLeast20MinAndAcOffAtLeast20Min_runsFanDuring0To10And30To40Minutes() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 4, 0);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 4, 30); // 30m before 05:00
    LocalDateTime dehOnUtc = LocalDateTime.of(2026, 11, 9, 4, 35); // 25m before 05:00
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance deh = createDeh("zigbee2mqtt/DEHUMIDIFIER/set", ON, dehOnUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCodeReadOnly("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
        eq(List.of("DEHUMIDIFIER")), any(), eq("power")))
        .thenReturn(List.of(powerReading("DEHUMIDIFIER", 102.4)));
    stubToggleStateMutation();

    // 00:00 EST (05:00 UTC) -> FAN ON
    LocalDateTime t0000 = LocalDateTime.of(2026, 11, 9, 5, 0);
    scheduledService.controlFanForDeh(t0000);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0000), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(ON));

    // 00:09 EST (05:09 UTC) -> FAN still ON
    LocalDateTime t0009 = LocalDateTime.of(2026, 11, 9, 5, 9);
    scheduledService.controlFanForDeh(t0009);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0009), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(ON));

    // 00:10 EST (05:10 UTC) -> FAN OFF
    LocalDateTime t0010 = LocalDateTime.of(2026, 11, 9, 5, 10);
    scheduledService.controlFanForDeh(t0010);
    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0010), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(OFF));

    // 00:30 EST (05:30 UTC) -> FAN ON
    LocalDateTime t0030 = LocalDateTime.of(2026, 11, 9, 5, 30);
    scheduledService.controlFanForDeh(t0030);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0030), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(ON));

    // 00:39 EST (05:39 UTC) -> FAN still ON
    LocalDateTime t0039 = LocalDateTime.of(2026, 11, 9, 5, 39);
    scheduledService.controlFanForDeh(t0039);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0039), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(ON));

    // 00:40 EST (05:40 UTC) -> FAN OFF
    LocalDateTime t0040 = LocalDateTime.of(2026, 11, 9, 5, 40);
    scheduledService.controlFanForDeh(t0040);
    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0040), eq("deh-on"), eq(true));
    assertThat(fan.getState(), is(OFF));
  }

  @Test
  void dehRunningLessThan20Minutes_fanStaysOff() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 4, 0);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 4, 20);
    LocalDateTime dehOnUtc = LocalDateTime.of(2026, 11, 9, 4, 45); // only 15m before 05:00
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance deh = createDeh("zigbee2mqtt/DEHUMIDIFIER/set", ON, dehOnUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCodeReadOnly("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
        eq(List.of("DEHUMIDIFIER")), any(), eq("power")))
        .thenReturn(List.of(powerReading("DEHUMIDIFIER", 102.4)));

    LocalDateTime t0000 = LocalDateTime.of(2026, 11, 9, 5, 0);
    scheduledService.controlFanForDeh(t0000);

    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0000), eq("deh-on"), eq(true));
    verify(applianceFacade, never()).toggle(eq(fan), eq(ON), any(), anyString(), eq(true));
  }

  @Test
  void acTurnedOffLessThan20MinutesAgo_fanStaysOff() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 4, 35);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 4, 50); // only 10m before 05:00
    LocalDateTime dehOnUtc = LocalDateTime.of(2026, 11, 9, 4, 15); // 45m before 05:00
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance deh = createDeh("zigbee2mqtt/DEHUMIDIFIER/set", ON, dehOnUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCodeReadOnly("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
        eq(List.of("DEHUMIDIFIER")), any(), eq("power")))
        .thenReturn(List.of(powerReading("DEHUMIDIFIER", 102.4)));

    LocalDateTime t0000 = LocalDateTime.of(2026, 11, 9, 5, 0);
    scheduledService.controlFanForDeh(t0000);

    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0000), eq("deh-on"), eq(true));
    verify(applianceFacade, never()).toggle(eq(fan), eq(ON), any(), anyString(), eq(true));
  }

  @Test
  void dehPowerBelowThreshold_fanStaysOffInWindow() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 4, 0);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 4, 20);
    LocalDateTime dehOnUtc = LocalDateTime.of(2026, 11, 9, 4, 20);
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance deh = createDeh("zigbee2mqtt/DEHUMIDIFIER/set", ON, dehOnUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCodeReadOnly("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
        eq(List.of("DEHUMIDIFIER")), any(), eq("power")))
        .thenReturn(List.of(powerReading("DEHUMIDIFIER", 5.0)));

    LocalDateTime t0005 = LocalDateTime.of(2026, 11, 9, 5, 5);
    scheduledService.controlFanForDeh(t0005);

    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0005), eq("deh-on"), eq(true));
    verify(applianceFacade, never()).toggle(eq(fan), eq(ON), any(), anyString(), eq(true));
  }

  @Test
  void fanLocked_doesNotToggleFan() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 4, 0);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 4, 20);
    LocalDateTime dehOnUtc = LocalDateTime.of(2026, 11, 9, 4, 20);
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance deh = createDeh("zigbee2mqtt/DEHUMIDIFIER/set", ON, dehOnUtc);
    Appliance fan = createFan(OFF);
    fan.setLocked(true);

    when(applianceService.getApplianceByCodeReadOnly("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
        eq(List.of("DEHUMIDIFIER")), any(), eq("power")))
        .thenReturn(List.of(powerReading("DEHUMIDIFIER", 102.4)));

    LocalDateTime checkUtc = LocalDateTime.of(2026, 11, 9, 5, 0);
    scheduledService.controlFanForDeh(checkUtc);

    verify(applianceFacade, never()).toggle(any(), any(), any(), anyString(), eq(true));
  }
}
