package com.alexsoft.smarthouse.watchdog.internal;
import com.alexsoft.smarthouse.mqtt.MessageSenderService;
import com.alexsoft.smarthouse.appliance.ApplianceFacade;
import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.appliance.ApplianceService;

import com.alexsoft.smarthouse.environment.IndicationV3;
import com.alexsoft.smarthouse.appliance.Appliance;
import com.alexsoft.smarthouse.appliance.ApplianceState;
import com.alexsoft.smarthouse.environment.IndicationRepositoryV3;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.OptionalDouble;

import static com.alexsoft.smarthouse.appliance.ApplianceState.OFF;
import static com.alexsoft.smarthouse.appliance.ApplianceState.ON;
import static com.alexsoft.smarthouse.core.util.DateUtils.getLocalDateTime;
import static com.alexsoft.smarthouse.core.util.DateUtils.getUtc;
import static com.alexsoft.smarthouse.core.util.DateUtils.toLocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduledService {

    public static final List<String> TREND_DEVICE_IDS = List.of("935-CORKWOOD-MB", "935-CORKWOOD-LR");
    public static final List<String> TREND_MEASURE_TYPES = List.of("ah", "temp");
    private static final double DEH_OPERATING_POWER_THRESHOLD_WATTS = 50.0;
    private static final int DEH_FAN_MIN_CONTINUOUS_MINUTES = 20;

    private final ApplianceService applianceService;
    private final ApplianceFacade applianceFacade;
    private final IndicationRepositoryV3 indicationRepositoryV3;
    private final IndicationServiceV3 indicationServiceV3;
    private final MessageSenderService messageSenderService;


    @Scheduled(cron = "*/5 * * * * *")
    @Transactional
    public void checkDehPowerAnomaly() {
        checkDehPowerAnomaly(getUtc());
    }

    public void checkDehPowerAnomaly(LocalDateTime utc) {
        int localHour = toLocalDateTime(utc).getHour();
        if (localHour < 9 || localHour >= 23) {
            return;
        }
        applianceService.getApplianceByCode("DEH").ifPresent(deh -> {
            if (deh.getState() != ON) return;
            if (deh.getSwitchedOn() == null || deh.getSwitchedOn().isAfter(utc.minusMinutes(5))) return;
            String powerLocationId = resolveDehPowerLocationId(deh.getZigbee2MqttTopic());
            indicationRepositoryV3.findTopByLocationIdAndMeasurementTypeOrderByUtcTimeDesc(powerLocationId, "power")
                    .ifPresent(last -> {
                        if (last.getValue() < DEH_OPERATING_POWER_THRESHOLD_WATTS) {
                            log.warn("deh.power.anomaly: state=ON but last power reading={}W — alerting", last.getValue());
                            messageSenderService.sendMessage("zigbee2mqtt/LED_UNDER_TV/set", "{\"effect\": \"blink\"}");
                        }
                    });
        });
    }

    @Scheduled(cron = "0/10 * * * * ?")
    public void powerControl() {
        applianceService.getAllAppliances().forEach(app -> applianceService.powerControl(app.getCode()));
    }

    @Scheduled(cron = "0 * * * * *")
    @Transactional
    public void controlFanForDeh() {
        controlFanForDeh(getUtc());
    }

    public void controlFanForDeh(LocalDateTime utc) {
        applianceService.getApplianceByCodeReadOnly("AC").ifPresent(ac -> {
            if (ac.getState() != OFF) {
                return;
            }

            LocalDateTime twentyMinutesAgo = utc.minusMinutes(DEH_FAN_MIN_CONTINUOUS_MINUTES);
            boolean acOffForAtLeast20Min = ac.getSwitchedOff() == null || !ac.getSwitchedOff().isAfter(twentyMinutesAgo);

            LocalDateTime now = toLocalDateTime(utc);
            int minute = now.getMinute();
            boolean fanNeedsToBeTurnedOn = (minute < 10) || (minute >= 30 && minute < 40);

            Optional<Appliance> dehOpt = applianceService.getApplianceByCode("DEH");
            boolean dehOnForAtLeast20Min = dehOpt
                    .map(deh -> deh.getState() == ON
                            && deh.getSwitchedOn() != null
                            && !deh.getSwitchedOn().isAfter(twentyMinutesAgo))
                    .orElse(false);

            String dehLocationId = dehOpt
                    .map(deh -> resolveDehPowerLocationId(deh.getZigbee2MqttTopic()))
                    .orElse("DEH");
            int periodMin = ac.getAveragePeriodMinutes() != null ? ac.getAveragePeriodMinutes() : 1;
            LocalDateTime averageStart = utc.minus(Duration.ofMinutes(periodMin));
            OptionalDouble avgDehPower = indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                    List.of(dehLocationId), averageStart, "power").stream().mapToDouble(IndicationV3::getValue).average();

            applianceService.getApplianceByCode("FAN").ifPresent(fan -> {
                if (fan.isLocked() || Boolean.FALSE.equals(fan.getSensorControlled())) {
                    return;
                }
                ApplianceState target = acOffForAtLeast20Min
                        && dehOnForAtLeast20Min
                        && avgDehPower.isPresent()
                        && avgDehPower.getAsDouble() > DEH_OPERATING_POWER_THRESHOLD_WATTS
                        && fanNeedsToBeTurnedOn ? ON : OFF;
                applianceFacade.toggle(fan, target, utc, "deh-on", true);
            });
        });
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

    @Scheduled(cron = "*/5 * * * * *")
    @Transactional
    public void saveAcThresholds() {
        LocalDateTime utc = getUtc();
        LocalDateTime local = getLocalDateTime();
        saveActiveThreshold("AC", "temp", utc, local);
        saveActiveThreshold("DEH", "ah", utc, local);
    }

    private void saveActiveThreshold(String applianceCode, String measurementType, LocalDateTime utc, LocalDateTime local) {
        applianceService.getApplianceByCode(applianceCode).ifPresent(appliance -> {
            if (appliance.isLocked() || appliance.getSetting() == null) {
                return;
            }
            if (appliance.getState() == ON) {
                indicationServiceV3.save(IndicationV3.builder().publisherId("i7-4770k").measurementType(measurementType)
                        .locationId(applianceCode + "-THRESHOLD-OFF").utcTime(utc).localTime(local)
                        .value(appliance.getSetting() - appliance.getHysteresisOff()).build());
            } else {
                indicationServiceV3.save(IndicationV3.builder().publisherId("i7-4770k").measurementType(measurementType)
                        .locationId(applianceCode + "-THRESHOLD-ON").utcTime(utc).localTime(local)
                        .value(appliance.getSetting() + appliance.getHysteresisOn()).build());
            }
        });
    }

    @Scheduled(cron = "*/3 * * * * *")
    @Transactional
    public void calculateTrends() {
        LocalDateTime utcDateTime = getUtc();
        TREND_MEASURE_TYPES.forEach(measurementType -> {
            calculateTrendAndSend(utcDateTime, 1, measurementType, TREND_DEVICE_IDS);
            calculateTrendAndSend(utcDateTime, 5, measurementType, TREND_DEVICE_IDS);
        });
    }


    public void calculateTrendAndSend(LocalDateTime utcDateTime, int minutes, String measurementType, List<String> deviceIds) {
        Comparator<IndicationV3> comparator = Comparator.comparing(IndicationV3::getUtcTime);
        List<IndicationV3> averages = indicationRepositoryV3.findByLocationIdInAndUtcTimeIsAfterAndMeasurementType(
                deviceIds, utcDateTime.minusMinutes(minutes), measurementType);
        Optional<IndicationV3> first = averages.stream().max(comparator);
        Optional<IndicationV3> second = averages.stream().min(comparator);
        if (first.map(IndicationV3::getValue).isEmpty() || second.map(IndicationV3::getValue).isEmpty()) {
            return;
        }
        long secondsDifference = Duration.between(second.get().getLocalTime(), first.get().getLocalTime()).toSeconds();
        if (secondsDifference < ((long) minutes * 60 * 0.85)) {
            return;
        }
        Double trend = (first.get().getValue() - second.get().getValue()) / secondsDifference * 3600;
        indicationServiceV3.save(IndicationV3.builder().locationId("935-CORKWOOD-TREND%d".formatted(minutes)).localTime(getLocalDateTime()).utcTime(getUtc())
                .publisherId("i7-4770k").measurementType(measurementType.equals("ah") ? "ah" : "temp").value(trend).build());
    }

}
