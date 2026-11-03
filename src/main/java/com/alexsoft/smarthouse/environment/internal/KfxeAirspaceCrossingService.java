package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.environment.AirspaceCrossingAlertEvent;
import com.alexsoft.smarthouse.environment.model.airplaneslive.Aircraft;
import com.alexsoft.smarthouse.environment.model.airplaneslive.AircraftData;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

@Service
public class KfxeAirspaceCrossingService {

    private static final Logger LOGGER = LoggerFactory.getLogger(KfxeAirspaceCrossingService.class);

    static final String ADSB_URL = "https://api.adsb.lol/v2/point/26.19728/-80.17071/35";
    static final double KFXE_LAT = 26.19728;
    static final double KFXE_LON = -80.17071;
    static final double KFXE_CLASS_D_RADIUS_NM = 4.0;
    static final int KFXE_CLASS_D_CEILING_FT = 2500;
    static final int MIN_AIRBORNE_ALT_FT = 300;
    static final double MIN_GROUND_SPEED_KT = 50.0;

    // KFXE Runway true headings: Rwy 09 (084°), Rwy 27 (264°), Rwy 13 (129°), Rwy 31 (309°)
    static final double[] KFXE_RUNWAY_TRUE_HEADINGS = {84.0, 264.0, 129.0, 309.0};
    static final double RUNWAY_HEADING_TOLERANCE_DEG = 15.0;
    static final double RUNWAY_FINAL_CORRIDOR_NM = 1.8;

    static final double MIN_ADVANCE_MINUTES = 0.5;
    static final double MAX_ADVANCE_MINUTES = 5.5;
    static final double MIN_CROSSING_CHORD_NM = 1.0;

    static final int CB_FAILURE_THRESHOLD = 3;
    static final Duration CB_INITIAL_COOLDOWN = Duration.ofMinutes(15);
    static final Duration CB_MAX_COOLDOWN = Duration.ofHours(6);
    static final Duration ALERT_DEDUP_WINDOW = Duration.ofMinutes(30);

    private static final DateTimeFormatter UTC_TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");
    private static final String[] COMPASS_DIRS = {
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    };

    private final RestTemplate restTemplate;
    private final ApplicationEventPublisher eventPublisher;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private Clock clock = Clock.systemUTC();
    private int consecutiveFailures = 0;
    private Duration currentCooldown = CB_INITIAL_COOLDOWN;
    private LocalDateTime circuitOpenUntil = null;
    private boolean halfOpenProbe = false;
    private final Map<String, LocalDateTime> recentAlerts = new HashMap<>();

    public KfxeAirspaceCrossingService(
            RestTemplateBuilder restTemplateBuilder,
            ApplicationEventPublisher eventPublisher) {
        this.restTemplate = restTemplateBuilder
                .connectTimeout(Duration.ofSeconds(5))
                .readTimeout(Duration.ofSeconds(10))
                .build();
        this.eventPublisher = eventPublisher;
    }

    void setClock(Clock clock) {
        this.clock = clock;
    }

    @Async("ioTaskExecutor")
    @Scheduled(cron = "${kfxe.crossing-cron:0 */1 * * * *}")
    public void checkApproachingAircraft() {
        try {
            evaluateAirspaceCrossings();
        } catch (Exception e) {
            LOGGER.error("Error during checkApproachingAircraft", e);
        }
    }

    public synchronized void evaluateAirspaceCrossings() {
        LocalDateTime nowUtc = LocalDateTime.now(clock.withZone(ZoneOffset.UTC));
        if (circuitOpenUntil != null) {
            if (nowUtc.isBefore(circuitOpenUntil)) {
                LOGGER.debug("KFXE crossing circuit breaker is OPEN until {}; skipping call", circuitOpenUntil);
                return;
            }
            circuitOpenUntil = null;
            halfOpenProbe = true;
            LOGGER.info("KFXE crossing circuit breaker entering HALF-OPEN state; probing {}", ADSB_URL);
        }

        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.ACCEPT, "application/json");
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<String> response;
        try {
            response = restTemplate.exchange(ADSB_URL, HttpMethod.GET, entity, String.class);
        } catch (HttpClientErrorException e) {
            int status = e.getStatusCode().value();
            boolean immediateTrip = (status == 403 || status == 429);
            recordFailure(nowUtc, immediateTrip, e.getMessage());
            return;
        } catch (Exception e) {
            recordFailure(nowUtc, false, e.getMessage());
            return;
        }

        String rawPayload = response.getBody();
        if (rawPayload == null) {
            recordFailure(nowUtc, false, "empty response body");
            return;
        }

        recordSuccess();

        if (rawPayload.equalsIgnoreCase("[]")) {
            return;
        }

        AircraftData aircraftData;
        try {
            aircraftData = objectMapper.readValue(rawPayload, AircraftData.class);
        } catch (JsonProcessingException e) {
            LOGGER.warn("Failed to parse ADS-B payload in KfxeAirspaceCrossingService: {}", e.getMessage());
            return;
        }

        if (aircraftData == null || CollectionUtils.isEmpty(aircraftData.getAircrafts())) {
            return;
        }

        pruneExpiredAlerts(nowUtc);

        List<Aircraft> candidates = aircraftData.getAircrafts().stream()
                .filter(Objects::nonNull)
                .toList();

        for (Aircraft ac : candidates) {
            evaluateSingleAircraft(ac, nowUtc);
        }
    }

    private void evaluateSingleAircraft(Aircraft ac, LocalDateTime nowUtc) {
        if (ac.getLatitude() == null || ac.getLongitude() == null
                || ac.getGroundSpeed() == null || ac.getTrack() == null) {
            return;
        }
        if (ac.getGroundSpeed() < MIN_GROUND_SPEED_KT) {
            return;
        }
        if (!NumberUtils.isCreatable(ac.getAltBaro())) {
            return;
        }
        int altFt;
        try {
            altFt = Integer.parseInt(ac.getAltBaro().trim());
        } catch (NumberFormatException e) {
            return;
        }
        // Only aircraft within KFXE Class D altitude limits (SFC to 2,500 ft MSL) require FXE Tower clearance
        if (altFt < MIN_AIRBORNE_ALT_FT || altFt > KFXE_CLASS_D_CEILING_FT) {
            return;
        }

        // Convert aircraft position relative to KFXE center into Nautical Miles (local tangent plane)
        double dyNm = (ac.getLatitude() - KFXE_LAT) * 60.0;
        double dxNm = (ac.getLongitude() - KFXE_LON) * 60.0 * Math.cos(Math.toRadians(KFXE_LAT));
        double currentDistNm = Math.hypot(dxNm, dyNm);

        // Only evaluate aircraft currently outside KFXE Class D cylinder (4.0 NM radius)
        if (currentDistNm <= KFXE_CLASS_D_RADIUS_NM) {
            return;
        }

        // Velocity vector in NM/minute (groundSpeed is in knots = NM/hour; track is degrees true clockwise from North)
        double trackRad = Math.toRadians(ac.getTrack());
        double vxNmPerMin = (ac.getGroundSpeed() / 60.0) * Math.sin(trackRad);
        double vyNmPerMin = (ac.getGroundSpeed() / 60.0) * Math.cos(trackRad);
        double speedNmPerMin = ac.getGroundSpeed() / 60.0;

        // Dot product P . V: must be negative (aircraft moving toward KFXE, not away)
        double dotPV = dxNm * vxNmPerMin + dyNm * vyNmPerMin;
        if (dotPV >= 0) {
            return;
        }

        // Time to Closest Point of Approach (CPA) and minimum distance to KFXE center
        double vSq = speedNmPerMin * speedNmPerMin;
        double tCpaMin = -dotPV / vSq;
        double cpaX = dxNm + vxNmPerMin * tCpaMin;
        double cpaY = dyNm + vyNmPerMin * tCpaMin;
        double cpaDistNm = Math.hypot(cpaX, cpaY);

        if (cpaDistNm >= KFXE_CLASS_D_RADIUS_NM) {
            return;
        }

        // Chord length inside the 4.0 NM cylinder: 2 * sqrt(R^2 - cpaDist^2)
        double halfChordNm = Math.sqrt(KFXE_CLASS_D_RADIUS_NM * KFXE_CLASS_D_RADIUS_NM - cpaDistNm * cpaDistNm);
        double chordLengthNm = 2.0 * halfChordNm;
        if (chordLengthNm < MIN_CROSSING_CHORD_NM) {
            return;
        }

        // Time until entering the 4.0 NM boundary
        double tEntryMin = tCpaMin - (halfChordNm / speedNmPerMin);
        if (tEntryMin < MIN_ADVANCE_MINUTES || tEntryMin > MAX_ADVANCE_MINUTES) {
            return;
        }

        // Filter out aircraft on a landing course for KFXE runways (09/27 or 13/31)
        if (isOnRunwayLandingCourse(ac.getTrack(), cpaDistNm)) {
            LOGGER.debug("Skipping {} — aligned with KFXE runway landing course (track={}, cpaDist={} NM)",
                    getAircraftIdentifier(ac), ac.getTrack(), String.format(Locale.US, "%.2f", cpaDistNm));
            return;
        }

        String dedupKey = getDedupKey(ac);
        if (dedupKey != null && recentAlerts.containsKey(dedupKey)) {
            return;
        }
        if (dedupKey != null) {
            recentAlerts.put(dedupKey, nowUtc);
        }

        LocalDateTime entryUtc = nowUtc.plusSeconds(Math.round(tEntryMin * 60.0));
        int roundedMinutes = Math.max(1, (int) Math.round(tEntryMin));
        String compassFromKfxe = bearingToCompass(dxNm, dyNm);
        String identifier = getAircraftIdentifier(ac);

        String title = String.format(Locale.US,
                "KFXE Airspace Crossing (~%d min, ~%s UTC)",
                roundedMinutes, entryUtc.format(UTC_TIME_FMT));

        String body = String.format(Locale.US,
                "[%s UTC] %s approaching from %s (%.1f NM out) at %,d ft, %.0f kt, track %.0f°",
                nowUtc.format(UTC_TIME_FMT),
                identifier,
                compassFromKfxe,
                currentDistNm,
                altFt,
                ac.getGroundSpeed(),
                ac.getTrack());

        LOGGER.info("Detected approaching KFXE crossing: {} | {}", title, body);
        eventPublisher.publishEvent(new AirspaceCrossingAlertEvent(title, body));
    }

    static boolean isOnRunwayLandingCourse(double trackDeg, double cpaDistNm) {
        if (cpaDistNm > RUNWAY_FINAL_CORRIDOR_NM) {
            return false;
        }
        for (double rwyHeading : KFXE_RUNWAY_TRUE_HEADINGS) {
            if (angularDifferenceDeg(trackDeg, rwyHeading) <= RUNWAY_HEADING_TOLERANCE_DEG) {
                return true;
            }
        }
        return false;
    }

    static double angularDifferenceDeg(double a, double b) {
        double diff = Math.abs(a - b) % 360.0;
        return diff > 180.0 ? 360.0 - diff : diff;
    }

    private static String bearingToCompass(double dxNm, double dyNm) {
        double angleDeg = (Math.toDegrees(Math.atan2(dxNm, dyNm)) + 360.0) % 360.0;
        int idx = (int) Math.round(angleDeg / 22.5) % 16;
        return COMPASS_DIRS[idx];
    }

    private static String getDedupKey(Aircraft ac) {
        if (ac.getHex() != null && !ac.getHex().isBlank()) {
            return ac.getHex().trim().toLowerCase(Locale.ROOT);
        }
        if (ac.getRegistration() != null && !ac.getRegistration().isBlank()) {
            return ac.getRegistration().trim().toUpperCase(Locale.ROOT);
        }
        return null;
    }

    private static String getAircraftIdentifier(Aircraft ac) {
        String reg = ac.getRegistration() != null ? ac.getRegistration().trim() : null;
        String flight = ac.getFlight() != null ? ac.getFlight().trim() : null;
        String type = ac.getAircraftType() != null ? ac.getAircraftType().trim() : null;

        String primary = (reg != null && !reg.isEmpty()) ? reg
                : (flight != null && !flight.isEmpty()) ? flight
                : (ac.getHex() != null ? ac.getHex().trim() : "Unknown");

        if (type != null && !type.isEmpty()) {
            return primary + " (" + type + ")";
        }
        return primary;
    }

    private void pruneExpiredAlerts(LocalDateTime nowUtc) {
        LocalDateTime cutoff = nowUtc.minus(ALERT_DEDUP_WINDOW);
        recentAlerts.entrySet().removeIf(entry -> entry.getValue().isBefore(cutoff));
    }

    private void recordSuccess() {
        if (halfOpenProbe || consecutiveFailures > 0) {
            LOGGER.info("KFXE crossing ADS-B endpoint recovered; circuit breaker CLOSED");
        }
        consecutiveFailures = 0;
        currentCooldown = CB_INITIAL_COOLDOWN;
        circuitOpenUntil = null;
        halfOpenProbe = false;
    }

    private void recordFailure(LocalDateTime nowUtc, boolean immediateTrip, String reason) {
        consecutiveFailures++;
        if (halfOpenProbe) {
            halfOpenProbe = false;
            long nextMinutes = Math.min(currentCooldown.toMinutes() * 2, CB_MAX_COOLDOWN.toMinutes());
            currentCooldown = Duration.ofMinutes(nextMinutes);
            circuitOpenUntil = nowUtc.plus(currentCooldown);
            LOGGER.warn("KFXE crossing HALF-OPEN probe failed ({}). Circuit breaker re-opened for {} minutes until {}",
                    reason, currentCooldown.toMinutes(), circuitOpenUntil);
        } else if (immediateTrip || consecutiveFailures >= CB_FAILURE_THRESHOLD) {
            currentCooldown = CB_INITIAL_COOLDOWN;
            circuitOpenUntil = nowUtc.plus(currentCooldown);
            LOGGER.warn("KFXE crossing endpoint failed ({} consecutive, reason: {}). Circuit breaker OPEN for {} minutes until {}",
                    consecutiveFailures, reason, currentCooldown.toMinutes(), circuitOpenUntil);
        } else {
            LOGGER.warn("Couldn't read KFXE crossing aircraft (failure {}/{}): {}",
                    consecutiveFailures, CB_FAILURE_THRESHOLD, reason);
        }
    }
}
