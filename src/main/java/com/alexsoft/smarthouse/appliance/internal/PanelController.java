package com.alexsoft.smarthouse.appliance.internal;

import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceService;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static com.alexsoft.smarthouse.appliance.ApplianceState.ON;
import static com.alexsoft.smarthouse.core.util.DateUtils.getUtc;
import static com.alexsoft.smarthouse.core.util.DateUtils.toLocalDateTime;

@RestController
@RequestMapping("/panel")
@RequiredArgsConstructor
public class PanelController {

    private static final List<String> DEFAULT_ROOMS = List.of("LIVING-ROOM", "BEDROOM");
    private static final List<String> OUTDOOR_LOCATIONS = List.of("OUTDOOR", "FORT-LAUDERDALE");
    private static final long ROOM_STALE_MINUTES = 15;
    private static final long OUTDOOR_STALE_MINUTES = 90;
    private static final double DEH_OPERATING_POWER_WATTS = 50.0;
    private static final long DEH_ANOMALY_DELAY_MINUTES = 5;

    private final ApplianceService applianceService;
    private final IndicationRepositoryV3 indicationRepositoryV3;

    @GetMapping("/state")
    public ResponseEntity<PanelStateResponse> getPanelState() {
        return ResponseEntity.ok(buildPanelState(getUtc()));
    }

    PanelStateResponse buildPanelState(LocalDateTime utc) {
        LocalDateTime local = toLocalDateTime(utc);
        List<Appliance> allAppliances = applianceService.getAllAppliances();

        Map<String, ApplianceView> applianceViews = new LinkedHashMap<>();
        Appliance ac = null;
        Appliance deh = null;
        for (Appliance appliance : allAppliances) {
            applianceViews.put(appliance.getCode(), toApplianceView(appliance, utc));
            if ("AC".equals(appliance.getCode())) {
                ac = appliance;
            } else if ("DEH".equals(appliance.getCode())) {
                deh = appliance;
            }
        }

        List<String> roomLocations = resolveRoomLocations(ac);
        List<RoomReadingView> rooms = new ArrayList<>();
        for (String locationId : roomLocations) {
            rooms.add(buildRoomReading(locationId, utc, ROOM_STALE_MINUTES));
        }

        OutdoorReadingView outdoor = buildOutdoorReading(utc);
        Double dehPowerWatts = resolveDehPowerWatts(deh, utc);
        boolean dehBucketFullSuspected = isDehBucketFullSuspected(deh, dehPowerWatts, utc);

        return new PanelStateResponse(
                utc,
                local,
                applianceViews,
                rooms,
                outdoor,
                dehPowerWatts,
                dehBucketFullSuspected
        );
    }

    private ApplianceView toApplianceView(Appliance appliance, LocalDateTime utc) {
        Double target = null;
        if (appliance.getSetting() != null) {
            Double hystOn = appliance.getHysteresisOn();
            Double hystOff = appliance.getHysteresisOff();
            if (appliance.getState() == ON && hystOff != null) {
                target = appliance.getSetting() - hystOff;
            } else if (appliance.getState() != ON && hystOn != null) {
                target = appliance.getSetting() + hystOn;
            }
        }

        Long lockedRemainingSeconds = null;
        if (appliance.isLocked() && appliance.getLockedUntilUtc() != null && appliance.getLockedUntilUtc().isAfter(utc)) {
            lockedRemainingSeconds = Duration.between(utc, appliance.getLockedUntilUtc()).getSeconds();
        }

        return new ApplianceView(
                appliance.getCode(),
                appliance.getDescription(),
                appliance.getState(),
                appliance.getSetting(),
                appliance.getActual(),
                appliance.getActualRh(),
                appliance.getHysteresisOn(),
                appliance.getHysteresisOff(),
                target,
                appliance.isLocked(),
                appliance.getLockedUntilUtc(),
                lockedRemainingSeconds,
                appliance.getReferenceSensors(),
                appliance.getUnits(),
                appliance.getMetricType()
        );
    }

    private List<String> resolveRoomLocations(Appliance ac) {
        Set<String> locations = new LinkedHashSet<>();
        if (ac != null && ac.getReferenceSensors() != null && !ac.getReferenceSensors().isEmpty()) {
            locations.addAll(ac.getReferenceSensors());
        } else {
            locations.addAll(DEFAULT_ROOMS);
        }
        return new ArrayList<>(locations);
    }

    private RoomReadingView buildRoomReading(String locationId, LocalDateTime utc, long staleMinutes) {
        Optional<IndicationV3> temp = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(locationId, "temp");
        Optional<IndicationV3> rh = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(locationId, "rh");
        Optional<IndicationV3> ah = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(locationId, "ah");
        Optional<IndicationV3> co2 = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(locationId, "co2");

        LocalDateTime latestUpdate = latestTimestamp(temp, rh, ah, co2);
        boolean stale = latestUpdate == null || latestUpdate.isBefore(utc.minusMinutes(staleMinutes));
        boolean co2Stale = co2.map(IndicationV3::getUtcTime)
                .map(t -> t.isBefore(utc.minusMinutes(staleMinutes)))
                .orElse(true);

        return new RoomReadingView(
                locationId,
                formatRoomLabel(locationId),
                temp.map(IndicationV3::getValue).orElse(null),
                rh.map(IndicationV3::getValue).orElse(null),
                ah.map(IndicationV3::getValue).orElse(null),
                co2.map(IndicationV3::getValue).orElse(null),
                latestUpdate,
                stale,
                co2Stale
        );
    }

    private OutdoorReadingView buildOutdoorReading(LocalDateTime utc) {
        LocalDateTime cutoff = utc.minusMinutes(OUTDOOR_STALE_MINUTES);
        for (String loc : OUTDOOR_LOCATIONS) {
            Optional<IndicationV3> temp = indicationRepositoryV3
                    .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(loc, "temp");
            if (temp.isPresent() && temp.get().getUtcTime() != null && !temp.get().getUtcTime().isBefore(cutoff)) {
                Optional<IndicationV3> rh = indicationRepositoryV3
                        .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(loc, "rh");
                return new OutdoorReadingView(
                        loc,
                        temp.get().getValue(),
                        rh.map(IndicationV3::getValue).orElse(null),
                        temp.get().getUtcTime()
                );
            }
        }
        return null;
    }

    private Double resolveDehPowerWatts(Appliance deh, LocalDateTime utc) {
        if (deh == null) {
            return null;
        }
        String locationId = resolveDehPowerLocationId(deh.getZigbee2MqttTopic());
        Optional<IndicationV3> power = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(locationId, "power");
        if (power.isEmpty() || power.get().getUtcTime() == null
                || power.get().getUtcTime().isBefore(utc.minusMinutes(ROOM_STALE_MINUTES))) {
            return null;
        }
        return power.get().getValue();
    }

    private boolean isDehBucketFullSuspected(Appliance deh, Double dehPowerWatts, LocalDateTime utc) {
        if (deh == null || deh.getState() != ON || dehPowerWatts == null) {
            return false;
        }
        if (dehPowerWatts >= DEH_OPERATING_POWER_WATTS) {
            return false;
        }
        return deh.getSwitchedOn() == null || !utc.isBefore(deh.getSwitchedOn().plusMinutes(DEH_ANOMALY_DELAY_MINUTES));
    }

    private String resolveDehPowerLocationId(String zigbeeTopic) {
        if (zigbeeTopic != null && zigbeeTopic.startsWith("zigbee2mqtt/")) {
            String[] parts = zigbeeTopic.split("/");
            if (parts.length >= 2 && !parts[1].isBlank()) {
                return parts[1];
            }
        }
        return "DEH";
    }

    @SafeVarargs
    private LocalDateTime latestTimestamp(Optional<IndicationV3>... readings) {
        LocalDateTime latest = null;
        for (Optional<IndicationV3> reading : readings) {
            if (reading.isPresent() && reading.get().getUtcTime() != null) {
                LocalDateTime t = reading.get().getUtcTime();
                if (latest == null || t.isAfter(latest)) {
                    latest = t;
                }
            }
        }
        return latest;
    }

    private String formatRoomLabel(String locationId) {
        return switch (locationId) {
            case "LIVING-ROOM" -> "Living Room";
            case "BEDROOM" -> "Bedroom";
            case "MASTER-BEDROOM" -> "Master Bedroom";
            default -> locationId;
        };
    }

    public record PanelStateResponse(
            LocalDateTime serverTimeUtc,
            LocalDateTime serverTimeLocal,
            Map<String, ApplianceView> appliances,
            List<RoomReadingView> rooms,
            OutdoorReadingView outdoor,
            Double dehPowerWatts,
            boolean dehBucketFullSuspected
    ) {
    }

    public record ApplianceView(
            String code,
            String description,
            ApplianceState state,
            Double setting,
            Double actual,
            Double actualRh,
            Double hysteresisOn,
            Double hysteresisOff,
            Double target,
            boolean locked,
            LocalDateTime lockedUntilUtc,
            Long lockedRemainingSeconds,
            List<String> referenceSensors,
            String units,
            String metricType
    ) {
    }

    public record RoomReadingView(
            String locationId,
            String label,
            Double temp,
            Double rh,
            Double ah,
            Double co2,
            LocalDateTime updatedAtUtc,
            boolean stale,
            boolean co2Stale
    ) {
    }

    public record OutdoorReadingView(
            String locationId,
            Double temp,
            Double rh,
            LocalDateTime updatedAtUtc
    ) {
    }
}
