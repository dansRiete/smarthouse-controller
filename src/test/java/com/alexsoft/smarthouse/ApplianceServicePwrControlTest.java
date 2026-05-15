package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.entity.Appliance;
import com.alexsoft.smarthouse.entity.IndicationV3;
import com.alexsoft.smarthouse.repository.ApplianceGroupRepository;
import com.alexsoft.smarthouse.repository.ApplianceRepository;
import com.alexsoft.smarthouse.repository.EventRepository;
import com.alexsoft.smarthouse.repository.IndicationRepositoryV3;
import com.alexsoft.smarthouse.repository.RequestRepository;
import com.alexsoft.smarthouse.service.ApplianceFacade;
import com.alexsoft.smarthouse.service.ApplianceService;
import com.alexsoft.smarthouse.service.IndicationServiceV3;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static com.alexsoft.smarthouse.enums.ApplianceState.OFF;
import static com.alexsoft.smarthouse.enums.ApplianceState.ON;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.times;

@ExtendWith(MockitoExtension.class)
class ApplianceServicePwrControlTest {

    @Mock ApplianceRepository applianceRepository;
    @Mock IndicationRepositoryV3 indicationRepositoryV3;
    @Mock ApplianceGroupRepository applianceGroupRepository;
    @Mock IndicationServiceV3 indicationServiceV3;
    @Mock RequestRepository requestRepository;
    @Mock ApplianceFacade applianceFacade;
    @Mock EventRepository eventRepository;

    @InjectMocks ApplianceService applianceService;

    private Appliance acOn() {
        Appliance a = new Appliance();
        a.setCode("AC");
        a.setState(ON, LocalDateTime.now());
        a.setSetting(25.0);
        a.setHysteresisOn(0.5);
        a.setHysteresisOff(1.0);
        a.setReferenceSensors(List.of("mb-sensor"));
        a.setMeasurementType("temperature");
        a.setAveragePeriodMinutes(60);
        a.setMetricType("temperature");
        return a;
    }

    private Appliance acOff() {
        Appliance a = acOn();
        a.setState(OFF, LocalDateTime.now());
        return a;
    }

    private void mockAcAvg(Appliance ac, double value) {
        when(applianceRepository.findById("AC")).thenReturn(Optional.of(ac));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(value).build()));
    }

    private Appliance lightOff() {
        Appliance a = new Appliance();
        a.setCode("MB-LOB");
        a.setState(OFF, LocalDateTime.now());
        a.setSetting(75.0);
        a.setHysteresisOn(25.0);
        a.setHysteresisOff(25.0);
        a.setInverted(true);
        a.setReferenceSensors(List.of("mb-lis-outdoor"));
        a.setMeasurementType("illuminance");
        a.setAveragePeriodMinutes(60);
        a.setMetricType("illuminance");
        return a;
    }

    private Appliance lightOn() {
        Appliance a = lightOff();
        a.setState(ON, LocalDateTime.now());
        return a;
    }

    private void mockAvg(double value) {
        when(applianceRepository.findById("MB-LOB"))
                .thenReturn(Optional.of(value < 50 ? lightOff() : value > 100 ? lightOn() : lightOff()));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(value).build()));
    }

    // avg = 58.75 (hysteresis zone 50–100): state was OFF, must stay OFF — the bug that hit on 2026-04-07
    @Test
    void invertedAppliance_hysteresisZone_doesNotToggle() {
        when(applianceRepository.findById("MB-LOB")).thenReturn(Optional.of(lightOff()));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(58.75).build()));

        applianceService.powerControl("MB-LOB");

        verify(applianceFacade, never()).toggle(any(), eq(ON), any(), any(), anyBoolean());
    }

    // avg = 30 (below threshold 50): dark enough → turn ON
    @Test
    void invertedAppliance_belowThreshold_triggersOn() {
        when(applianceRepository.findById("MB-LOB")).thenReturn(Optional.of(lightOff()));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(30.0).build()));

        applianceService.powerControl("MB-LOB");

        verify(applianceFacade).toggle(any(), eq(ON), any(), eq("pwr-control"), eq(true));
    }

    // avg = 150 (above threshold 100): bright enough → turn OFF
    @Test
    void invertedAppliance_aboveThreshold_triggersOff() {
        when(applianceRepository.findById("MB-LOB")).thenReturn(Optional.of(lightOn()));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(150.0).build()));

        applianceService.powerControl("MB-LOB");

        verify(applianceFacade).toggle(any(), eq(OFF), any(), eq("pwr-control"), eq(true));
    }

    // checkLock: expired lock is cleared and power control resumes normally
    @Test
    void checkLock_expiredLock_clearsLockAndResumesPwrControl() {
        Appliance light = lightOff();
        light.setLocked(true);
        light.setLockedUntilUtc(LocalDateTime.of(2020, 1, 1, 0, 0)); // clearly in the past

        when(applianceRepository.findById("MB-LOB")).thenReturn(Optional.of(light));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(5.0).build())); // dark → would turn ON

        applianceService.powerControl("MB-LOB");

        assertThat(light.isLocked(), is(false));
        assertThat(light.getLockedUntilUtc(), is(nullValue()));
        verify(eventRepository).save(argThat(e -> "lock.expired".equals(e.getType())));
        verify(applianceFacade).toggle(any(), eq(ON), any(), eq("pwr-control"), eq(true));
    }

    // AC locked ON — sendState must be called every cycle so custom MQTT reinforces physical state
    @Test
    void ac_lockedOn_sendStateCalledEachCycle() {
        Appliance ac = acOn();
        ac.setLocked(true);
        ac.setLockedUntilUtc(LocalDateTime.of(9999, 12, 31, 23, 59)); // far future, survives any UTC offset

        mockAcAvg(ac, 26.0); // above threshold, irrelevant — locked

        applianceService.powerControl("AC");

        verify(applianceFacade).sendState(ac);
        verify(applianceFacade, never()).toggle(any(), any(), any(), any(), anyBoolean());
    }

    // AC locked OFF — same: sendState must reinforce the OFF state every cycle
    @Test
    void ac_lockedOff_sendStateCalledEachCycle() {
        Appliance ac = acOff();
        ac.setLocked(true);
        ac.setLockedUntilUtc(LocalDateTime.of(9999, 12, 31, 23, 59)); // far future, survives any UTC offset

        mockAcAvg(ac, 23.0); // below threshold, irrelevant — locked

        applianceService.powerControl("AC");

        verify(applianceFacade).sendState(ac);
        verify(applianceFacade, never()).toggle(any(), any(), any(), any(), anyBoolean());
    }

    // AC unlocked, avg above on-threshold, already ON — sendState reinforces without toggling
    @Test
    void ac_unlocked_onCondition_stateAlreadyOn_callsSendState() {
        Appliance ac = acOn();

        mockAcAvg(ac, 26.0); // avg 26 > setting 25 + hysteresisOn 0.5 → onCondition

        applianceService.powerControl("AC");

        verify(applianceFacade).sendState(ac);
        verify(applianceFacade, never()).toggle(any(), eq(ON), any(), any(), anyBoolean());
    }

    // Inverted light locked OFF overnight. Lock expires but illuminance is already above threshold —
    // offCondition is met but state is already OFF, so no toggle. sendState is called twice:
    // once immediately on lock expiry (line 84) and once because offCondition is satisfied with state
    // already correct (line 142). Both calls reinforce the physical state without toggling.
    @Test
    void lockExpiry_brightIlluminance_callsSendStateWithoutToggle() {
        Appliance light = lightOff();
        light.setLocked(true);
        light.setLockedUntilUtc(LocalDateTime.of(2020, 1, 1, 0, 0)); // expired

        when(applianceRepository.findById("MB-LOB")).thenReturn(Optional.of(light));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString()))
                .thenReturn(List.of(IndicationV3.builder().value(150.0).build())); // bright → offCondition met, state already OFF

        applianceService.powerControl("MB-LOB");

        verify(applianceFacade, times(1)).sendState(any());
        verify(applianceFacade, never()).toggle(any(), any(), any(), any(), anyBoolean());
    }
}
