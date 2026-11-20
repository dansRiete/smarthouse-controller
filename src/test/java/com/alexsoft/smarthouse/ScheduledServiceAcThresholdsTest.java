package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import com.alexsoft.smarthouse.watchdog.internal.ScheduledService;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScheduledServiceAcThresholdsTest {

  @Mock ApplianceService applianceService;
  @Mock IndicationRepositoryV3 indicationRepositoryV3;
  @Mock IndicationServiceV3 indicationServiceV3;

  @InjectMocks ScheduledService scheduledService;

  private Appliance ac(double setting, double hysteresisOn, double hysteresisOff, ApplianceState state) {
    Appliance a = new Appliance();
    a.setCode("AC");
    a.setSetting(setting);
    a.setHysteresisOn(hysteresisOn);
    a.setHysteresisOff(hysteresisOff);
    a.setState(state);
    return a;
  }

  @Test
  void saveAcThresholds_whenAcIsOff_savesOnlyUpperThresholdOn() {
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(ac(24.75, 0.5, 1.0, ApplianceState.OFF)));

    scheduledService.saveAcThresholds();

    ArgumentCaptor<IndicationV3> captor = ArgumentCaptor.forClass(IndicationV3.class);
    verify(indicationServiceV3, times(1)).save(captor.capture());

    IndicationV3 saved = captor.getValue();
    assertThat(saved.getLocationId(), is("AC-THRESHOLD-ON"));
    assertThat(saved.getValue(), is(25.25)); // 24.75 + 0.5
    assertThat(saved.getMeasurementType(), is("temp"));
  }

  @Test
  void saveAcThresholds_whenAcIsOn_savesOnlyLowerThresholdOff() {
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(ac(24.75, 0.5, 1.0, ApplianceState.ON)));

    scheduledService.saveAcThresholds();

    ArgumentCaptor<IndicationV3> captor = ArgumentCaptor.forClass(IndicationV3.class);
    verify(indicationServiceV3, times(1)).save(captor.capture());

    IndicationV3 saved = captor.getValue();
    assertThat(saved.getLocationId(), is("AC-THRESHOLD-OFF"));
    assertThat(saved.getValue(), is(23.75)); // 24.75 - 1.0
    assertThat(saved.getMeasurementType(), is("temp"));
  }

  @Test
  void saveAcThresholds_whenAcIsLocked_savesNothing() {
    Appliance a = ac(24.75, 0.5, 1.0, ApplianceState.OFF);
    a.setLocked(true);
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(a));

    scheduledService.saveAcThresholds();

    verify(indicationServiceV3, never()).save(any());
  }

  @Test
  void saveAcThresholds_acNotFound_savesNothing() {
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.empty());

    scheduledService.saveAcThresholds();

    verify(indicationServiceV3, never()).save(any());
  }

  @Test
  void saveAcThresholds_withScheduledHysteresis() {
    Appliance a = ac(25.0, 0.5, 1.0, ApplianceState.OFF);
    a.setSchedule(java.util.Map.of(
        "*", java.util.Map.of(
            String.valueOf(java.time.ZonedDateTime.now(java.time.ZoneId.of("America/New_York")).getHour()), "/2.0/3.0"
        )
    ));
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.of(a));

    scheduledService.saveAcThresholds();

    ArgumentCaptor<IndicationV3> captor = ArgumentCaptor.forClass(IndicationV3.class);
    verify(indicationServiceV3, times(1)).save(captor.capture());
    assertThat(captor.getValue().getLocationId(), is("AC-THRESHOLD-ON"));
    assertThat(captor.getValue().getValue(), is(27.0)); // 25.0 + 2.0
  }

  private Appliance deh(double setting, double hysteresisOn, double hysteresisOff, ApplianceState state) {
    Appliance a = new Appliance();
    a.setCode("DEH");
    a.setSetting(setting);
    a.setHysteresisOn(hysteresisOn);
    a.setHysteresisOff(hysteresisOff);
    a.setState(state);
    return a;
  }

  @Test
  void saveAcThresholds_whenDehIsOff_savesOnlyUpperThresholdOn() {
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.empty());
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(10.0, 0.5, 0.5, ApplianceState.OFF)));

    scheduledService.saveAcThresholds();

    ArgumentCaptor<IndicationV3> captor = ArgumentCaptor.forClass(IndicationV3.class);
    verify(indicationServiceV3, times(1)).save(captor.capture());

    IndicationV3 saved = captor.getValue();
    assertThat(saved.getLocationId(), is("DEH-THRESHOLD-ON"));
    assertThat(saved.getValue(), is(10.5));
    assertThat(saved.getMeasurementType(), is("ah"));
  }

  @Test
  void saveAcThresholds_whenDehIsOn_savesOnlyLowerThresholdOff() {
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.empty());
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(10.0, 0.5, 0.5, ApplianceState.ON)));

    scheduledService.saveAcThresholds();

    ArgumentCaptor<IndicationV3> captor = ArgumentCaptor.forClass(IndicationV3.class);
    verify(indicationServiceV3, times(1)).save(captor.capture());

    IndicationV3 saved = captor.getValue();
    assertThat(saved.getLocationId(), is("DEH-THRESHOLD-OFF"));
    assertThat(saved.getValue(), is(9.5));
    assertThat(saved.getMeasurementType(), is("ah"));
  }

  @Test
  void saveAcThresholds_whenDehIsLocked_savesNothing() {
    Appliance d = deh(10.0, 0.5, 0.5, ApplianceState.ON);
    d.setLocked(true);
    when(applianceService.getApplianceByCode("AC")).thenReturn(Optional.empty());
    when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(d));

    scheduledService.saveAcThresholds();

    verify(indicationServiceV3, never()).save(any());
  }
}
