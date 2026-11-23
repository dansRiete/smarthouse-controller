package com.alexsoft.smarthouse.appliance.internal;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class PanelControllerTest {

  @Mock ApplianceService applianceService;
  @Mock IndicationRepositoryV3 indicationRepositoryV3;

  @InjectMocks PanelController panelController;

  private static final LocalDateTime NOW = LocalDateTime.of(2026, 11, 22, 23, 0, 0);

  private IndicationV3 reading(String loc, String type, double val, LocalDateTime utc) {
    return IndicationV3.builder()
        .locationId(loc)
        .measurementType(type)
        .value(val)
        .utcTime(utc)
        .build();
  }

  @Test
  void buildPanelState_computesTargetsRoomsOutdoorAndLockCountdown() {
    Appliance ac = new Appliance();
    ac.setCode("AC");
    ac.setDescription("Air Conditioner");
    ac.setState(ApplianceState.OFF);
    ac.setSetting(24.44);
    ac.setActual(24.5);
    ac.setHysteresisOn(0.5);
    ac.setHysteresisOff(0.5);
    ac.setLocked(true);
    ac.setLockedUntilUtc(NOW.plusMinutes(10));
    ac.setReferenceSensors(List.of("LIVING-ROOM", "BEDROOM"));

    Appliance deh = new Appliance();
    deh.setCode("DEH");
    deh.setDescription("Dehumidifier");
    deh.setState(ApplianceState.ON);
    deh.setSetting(10.0);
    deh.setActual(10.2);
    deh.setActualRh(52.0);
    deh.setHysteresisOn(0.5);
    deh.setHysteresisOff(0.5);
    deh.setZigbee2MqttTopic("zigbee2mqtt/lr-sp-dehumidifier/set");
    deh.setSwitchedOn(NOW.minusMinutes(20));

    when(applianceService.getAllAppliances()).thenReturn(List.of(ac, deh));

    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("LIVING-ROOM", "temp"))
        .thenReturn(Optional.of(reading("LIVING-ROOM", "temp", 24.6, NOW.minusSeconds(10))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("LIVING-ROOM", "co2"))
        .thenReturn(Optional.of(reading("LIVING-ROOM", "co2", 950.0, NOW.minusSeconds(10))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("BEDROOM", "temp"))
        .thenReturn(Optional.of(reading("BEDROOM", "temp", 24.4, NOW.minusMinutes(20))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("BEDROOM", "co2"))
        .thenReturn(Optional.of(reading("BEDROOM", "co2", 1120.0, NOW.minusMinutes(20))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("FORT-LAUDERDALE", "temp"))
        .thenReturn(Optional.of(reading("FORT-LAUDERDALE", "temp", 27.0, NOW.minusMinutes(15))));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("lr-sp-dehumidifier", "power"))
        .thenReturn(Optional.of(reading("lr-sp-dehumidifier", "power", 410.0, NOW.minusSeconds(30))));

    PanelController.PanelStateResponse state = panelController.buildPanelState(NOW);

    PanelController.ApplianceView acView = state.appliances().get("AC");
    assertThat(acView.target(), is(24.94)); // OFF: setting + hystOn
    assertThat(acView.lockedRemainingSeconds(), is(600L));

    PanelController.ApplianceView dehView = state.appliances().get("DEH");
    assertThat(dehView.target(), is(9.5)); // ON: setting - hystOff
    assertThat(dehView.lockedRemainingSeconds(), is(nullValue()));

    assertThat(state.rooms(), hasSize(2));
    assertThat(state.rooms().get(0).locationId(), is("LIVING-ROOM"));
    assertThat(state.rooms().get(0).co2(), is(950.0));
    assertThat(state.rooms().get(0).stale(), is(false));
    assertThat(state.rooms().get(0).co2Stale(), is(false));

    assertThat(state.rooms().get(1).locationId(), is("BEDROOM"));
    assertThat(state.rooms().get(1).stale(), is(true)); // 20 min old > 15 min
    assertThat(state.rooms().get(1).co2Stale(), is(true));

    assertThat(state.outdoor(), is(notNullValue()));
    assertThat(state.outdoor().locationId(), is("FORT-LAUDERDALE"));
    assertThat(state.outdoor().temp(), is(27.0));

    assertThat(state.dehPowerWatts(), is(410.0));
    assertThat(state.dehBucketFullSuspected(), is(false));
  }

  @Test
  void buildPanelState_flagsDehBucketFullWhenOnWithLowPowerForOverFiveMinutes() {
    Appliance deh = new Appliance();
    deh.setCode("DEH");
    deh.setState(ApplianceState.ON);
    deh.setSetting(10.0);
    deh.setHysteresisOn(0.5);
    deh.setHysteresisOff(0.5);
    deh.setZigbee2MqttTopic("zigbee2mqtt/lr-sp-dehumidifier/set");
    deh.setSwitchedOn(NOW.minusMinutes(10));

    when(applianceService.getAllAppliances()).thenReturn(List.of(deh));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("lr-sp-dehumidifier", "power"))
        .thenReturn(Optional.of(reading("lr-sp-dehumidifier", "power", 1.2, NOW.minusSeconds(5))));

    PanelController.PanelStateResponse state = panelController.buildPanelState(NOW);

    assertThat(state.dehPowerWatts(), is(1.2));
    assertThat(state.dehBucketFullSuspected(), is(true));
  }

  @Test
  void buildPanelState_doesNotFlagDehBucketFullDuringFirstFiveMinutes() {
    Appliance deh = new Appliance();
    deh.setCode("DEH");
    deh.setState(ApplianceState.ON);
    deh.setSetting(10.0);
    deh.setHysteresisOn(0.5);
    deh.setHysteresisOff(0.5);
    deh.setZigbee2MqttTopic("zigbee2mqtt/lr-sp-dehumidifier/set");
    deh.setSwitchedOn(NOW.minusMinutes(2));

    when(applianceService.getAllAppliances()).thenReturn(List.of(deh));
    when(indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc("lr-sp-dehumidifier", "power"))
        .thenReturn(Optional.of(reading("lr-sp-dehumidifier", "power", 1.2, NOW.minusSeconds(5))));

    PanelController.PanelStateResponse state = panelController.buildPanelState(NOW);

    assertThat(state.dehBucketFullSuspected(), is(false));
  }
}
