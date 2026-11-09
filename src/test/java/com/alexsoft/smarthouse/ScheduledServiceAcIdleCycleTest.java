package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceFacade;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.mqtt.MessageSenderService;
import com.alexsoft.smarthouse.watchdog.internal.ScheduledService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Optional;

import static com.alexsoft.smarthouse.appliance.ApplianceState.OFF;
import static com.alexsoft.smarthouse.appliance.ApplianceState.ON;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.reset;
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

  private Appliance createFan(ApplianceState state) {
    Appliance fan = new Appliance();
    fan.setCode("FAN");
    fan.setState(state);
    return fan;
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
  void acOffLessThanOneHour_doesNotStartIdleCycleAtTopOfHour() {
    // AC turned off at 22:38 EST (03:38 UTC); at 23:00 EST (04:00 UTC) only 22 minutes elapsed
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 3, 22);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 3, 38);
    LocalDateTime checkUtc = LocalDateTime.of(2026, 11, 9, 4, 0);

    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(anyList(), any(), eq("power")))
        .thenReturn(Collections.emptyList());

    scheduledService.controlFanForDeh(checkUtc);

    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(checkUtc), eq("deh-on"), eq(true));
    verify(applianceFacade, never()).toggle(eq(fan), eq(ON), any(), eq("ac-idle"), eq(true));
  }

  @Test
  void acOffAtLeastOneHour_runsFanFirst8MinThenAcLast2MinThenOffAt10Min_andRepeatsNextHour() {
    // AC turned off at 22:38 EST (03:38 UTC); at 00:00 EST (05:00 UTC) 82 minutes elapsed
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 3, 22);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 3, 38);
    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    stubToggleStateMutation();

    // 00:00 EST (05:00 UTC) -> FAN ON, AC remains OFF
    LocalDateTime t0000 = LocalDateTime.of(2026, 11, 9, 5, 0);
    scheduledService.controlFanForDeh(t0000);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0000), eq("ac-idle"), eq(true));
    assertThat(fan.getState(), is(ON));
    assertThat(ac.getState(), is(OFF));

    // 00:07 EST (05:07 UTC) -> FAN still ON, AC still OFF
    LocalDateTime t0007 = LocalDateTime.of(2026, 11, 9, 5, 7);
    scheduledService.controlFanForDeh(t0007);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0007), eq("ac-idle"), eq(true));
    assertThat(fan.getState(), is(ON));
    assertThat(ac.getState(), is(OFF));

    // 00:08 EST (05:08 UTC) -> FAN OFF, AC ON and locked until 05:10 UTC
    LocalDateTime t0008 = LocalDateTime.of(2026, 11, 9, 5, 8);
    scheduledService.controlFanForDeh(t0008);
    verify(applianceFacade).toggle(eq(fan), eq(OFF), eq(t0008), eq("ac-idle"), eq(true));
    verify(applianceFacade).toggle(eq(ac), eq(ON), eq(t0008), eq("ac-idle"), eq(true));
    assertThat(fan.getState(), is(OFF));
    assertThat(ac.getState(), is(ON));
    assertThat(ac.isLocked(), is(true));
    assertThat(ac.getLockedUntilUtc(), is(LocalDateTime.of(2026, 11, 9, 5, 10)));

    // 00:09 EST (05:09 UTC) -> FAN OFF, AC stays ON and locked until 05:10 UTC
    LocalDateTime t0009 = LocalDateTime.of(2026, 11, 9, 5, 9);
    scheduledService.controlFanForDeh(t0009);
    assertThat(fan.getState(), is(OFF));
    assertThat(ac.getState(), is(ON));
    assertThat(ac.isLocked(), is(true));

    // 00:10 EST (05:10 UTC) -> AC unlocked and turned OFF, FAN OFF
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(anyList(), any(), eq("power")))
        .thenReturn(Collections.emptyList());
    LocalDateTime t0010 = LocalDateTime.of(2026, 11, 9, 5, 10);
    scheduledService.controlFanForDeh(t0010);
    verify(applianceFacade).toggle(eq(ac), eq(OFF), eq(t0010), eq("ac-idle"), eq(true));
    assertThat(ac.getState(), is(OFF));
    assertThat(ac.isLocked(), is(false));
    assertThat(ac.getLockedUntilUtc(), is(nullValue()));

    // Next hour 01:00 EST (06:00 UTC) -> repeats because only the 2-min idle cycle ran at 00:08-00:10
    reset(applianceFacade);
    stubToggleStateMutation();
    LocalDateTime t0100 = LocalDateTime.of(2026, 11, 9, 6, 0);
    scheduledService.controlFanForDeh(t0100);
    verify(applianceFacade).toggle(eq(fan), eq(ON), eq(t0100), eq("ac-idle"), eq(true));
    assertThat(fan.getState(), is(ON));
  }

  @Test
  void acLocked_doesNotStartIdleCycle() {
    LocalDateTime acOnUtc = LocalDateTime.of(2026, 11, 9, 2, 0);
    LocalDateTime acOffUtc = LocalDateTime.of(2026, 11, 9, 2, 15);
    LocalDateTime checkUtc = LocalDateTime.of(2026, 11, 9, 5, 0);

    Appliance ac = createAc(OFF, acOnUtc, acOffUtc);
    ac.setLocked(true);
    Appliance fan = createFan(OFF);

    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(ac));
    when(applianceService.getApplianceByCode("FAN")).thenReturn(Optional.of(fan));
    when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(anyList(), any(), eq("power")))
        .thenReturn(Collections.emptyList());

    scheduledService.controlFanForDeh(checkUtc);

    verify(applianceFacade, never()).toggle(eq(fan), eq(ON), any(), eq("ac-idle"), eq(true));
  }
}
