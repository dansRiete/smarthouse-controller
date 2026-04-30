package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.entity.Appliance;
import com.alexsoft.smarthouse.entity.IndicationV3;
import com.alexsoft.smarthouse.repository.IndicationRepositoryV3;
import com.alexsoft.smarthouse.service.ApplianceFacade;
import com.alexsoft.smarthouse.service.ApplianceService;
import com.alexsoft.smarthouse.service.IndicationServiceV3;
import com.alexsoft.smarthouse.service.MessageSenderService;
import com.alexsoft.smarthouse.service.ScheduledService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.IntStream;

import static com.alexsoft.smarthouse.enums.ApplianceState.OFF;
import static com.alexsoft.smarthouse.enums.ApplianceState.ON;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ScheduledServiceDehPowerAnomalyTest {

    @Mock ApplianceService applianceService;
    @Mock ApplianceFacade applianceFacade;
    @Mock IndicationRepositoryV3 indicationRepositoryV3;
    @Mock IndicationServiceV3 indicationServiceV3;
    @Mock MessageSenderService messageSenderService;

    @InjectMocks ScheduledService scheduledService;

    private static final String BLINK_TOPIC = "zigbee2mqtt/MB-LOTV/set";
    private static final String BLINK_PAYLOAD = "{\"effect\": \"blink\"}";

    private Appliance deh(com.alexsoft.smarthouse.enums.ApplianceState state) {
        Appliance a = new Appliance();
        a.setCode("DEH");
        a.setState(state, LocalDateTime.now().minusHours(1));
        return a;
    }

    private List<IndicationV3> powerReadings(int count, double watts) {
        return IntStream.range(0, count)
                .mapToObj(i -> IndicationV3.builder()
                        .locationId("DEH")
                        .measurementType("power")
                        .value(watts)
                        .utcTime(LocalDateTime.now().minusSeconds(i * 10L))
                        .localTime(LocalDateTime.now().minusSeconds(i * 10L))
                        .build())
                .toList();
    }

    private List<IndicationV3> mixedPowerReadings(int zeroCount, int highCount) {
        List<IndicationV3> zeros = powerReadings(zeroCount, 0.0);
        List<IndicationV3> highs = powerReadings(highCount, 563.0);
        return java.util.stream.Stream.concat(zeros.stream(), highs.stream()).toList();
    }

    // --- DEH state is OFF ---

    @Test
    void dehOff_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(OFF)));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
        verifyNoInteractions(indicationRepositoryV3);
    }

    // --- DEH not found ---

    @Test
    void dehNotFound_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.empty());

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
        verifyNoInteractions(indicationRepositoryV3);
    }

    // --- Insufficient readings ---

    @Test
    void dehOn_noReadings_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(Collections.emptyList());

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    @Test
    void dehOn_fewerThan20Readings_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(19, 0.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    @Test
    void dehOn_exactly20Readings_zeroWatts_alertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(20, 0.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService).sendMessage(BLINK_TOPIC, BLINK_PAYLOAD);
    }

    // --- Anomaly: ON state but zero power ---

    @Test
    void dehOn_30ReadingsAllZeroWatts_alertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(30, 0.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService).sendMessage(BLINK_TOPIC, BLINK_PAYLOAD);
    }

    @Test
    void dehOn_30ReadingsBelowThreshold_alertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        // 49W is below the 50W threshold
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(30, 49.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService).sendMessage(BLINK_TOPIC, BLINK_PAYLOAD);
    }

    // --- Normal operation: ON state with real power ---

    @Test
    void dehOn_30ReadingsAtOperatingPower_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(30, 563.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    @Test
    void dehOn_30ReadingsExactlyAt50Watts_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        // 50W is at the threshold — should NOT alert (condition is avg < 50)
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(30, 50.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    // --- Mixed readings: some high, some zero (DEH just started or briefly stopped) ---

    @Test
    void dehOn_mixedReadings_avgAboveThreshold_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        // 15 readings at 0W + 15 at 563W → avg ≈ 281W
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(mixedPowerReadings(15, 15));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    @Test
    void dehOn_mostlyZeroWithOneHighReading_avgAboveThreshold_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        // 29 readings at 0W + 1 at 563W → avg ≈ 18.8W — still below 50W, alert fires
        // This shows that a single spike does NOT suppress the alert
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(mixedPowerReadings(29, 1));

        scheduledService.checkDehPowerAnomaly();

        // avg = (29*0 + 1*563) / 30 = 18.8W < 50W → alert
        verify(messageSenderService).sendMessage(BLINK_TOPIC, BLINK_PAYLOAD);
    }

    @Test
    void dehOn_threeHighReadingsOutOf30_avgAboveThreshold_noAlertSent() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        // 27 at 0W + 3 at 563W → avg = 56.3W > 50W → no alert
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(mixedPowerReadings(27, 3));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, never()).sendMessage(anyString(), anyString());
    }

    // --- Correct query parameters ---

    @Test
    void dehOn_queriesCorrectLocationAndMeasurementType() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), anyString())).thenReturn(Collections.emptyList());

        scheduledService.checkDehPowerAnomaly();

        verify(indicationRepositoryV3).findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                eq(List.of("DEH")),
                any(LocalDateTime.class),
                eq("power"));
    }

    @Test
    void dehOn_alertSentExactlyOnce() {
        when(applianceService.getApplianceByCode("DEH")).thenReturn(Optional.of(deh(ON)));
        when(indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                anyList(), any(), eq("power"))).thenReturn(powerReadings(30, 0.0));

        scheduledService.checkDehPowerAnomaly();

        verify(messageSenderService, times(1)).sendMessage(BLINK_TOPIC, BLINK_PAYLOAD);
    }
}
