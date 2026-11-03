package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.core.Event;
import com.alexsoft.smarthouse.core.EventRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Locale;
import java.util.stream.Stream;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class KfxeAirspaceCrossingServiceTest {

    // KFXE center reference: lat = 26.19728, lon = -80.17071
    // 1 NM North/South = 1/60 deg lat (~0.016667 deg)
    // 1 NM East/West at 26.2°N = 1 / (60 * cos(26.19728°)) deg lon (~0.018574 deg)

    @Mock
    private RestTemplateBuilder restTemplateBuilder;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private EventRepository eventRepository;

    private KfxeAirspaceCrossingService service;
    private Instant currentInstant;

    @BeforeEach
    void setUp() {
        lenient().when(restTemplateBuilder.connectTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.readTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.build()).thenReturn(restTemplate);

        service = new KfxeAirspaceCrossingService(restTemplateBuilder, eventRepository);
        currentInstant = Instant.parse("2026-11-03T03:52:00Z");
        updateClock();
    }

    private void updateClock() {
        service.setClock(Clock.fixed(currentInstant, ZoneOffset.UTC));
    }

    private void advanceTime(Duration duration) {
        currentInstant = currentInstant.plus(duration);
        updateClock();
    }

    private static String singleAircraftPayload(
            String hex, String reg, String type, double lat, double lon, double track, double gs, String altBaro) {
        return String.format(Locale.US, """
                {
                  "ac": [
                    {
                      "hex": "%s",
                      "r": "%s",
                      "t": "%s",
                      "alt_baro": "%s",
                      "gs": %.1f,
                      "track": %.1f,
                      "lat": %.6f,
                      "lon": %.6f
                    }
                  ]
                }
                """, hex, reg, type, altBaro, gs, track, lat, lon);
    }

    /**
     * Scenarios that MUST trigger a KFXE Class D crossing alert (~0.5 to 5.5 minutes before entering the 4.0 NM cylinder,
     * between 300 ft and 2,500 ft MSL, and not aligned with a KFXE runway final approach course).
     *
     * Columns: (scenario, reg, type, lat, lon, trackDeg, groundSpeedKt, altBaro, expectedCompass, expectedMinStr)
     */
    static Stream<Arguments> triggeringAircraftProvider() {
        return Stream.of(
                // 1. Direct North -> South overhead transit (12 NM North, track 180°, 120 kt -> enters 4 NM cylinder in 4.0 min)
                Arguments.of("Direct N->S overhead at 1800 ft",
                        "N101NS", "C172", 26.397280, -80.170710, 180.0, 120.0, "1800", "N", "~4 min"),

                // 2. Direct South -> North overhead transit (10 NM South, track 000°, 120 kt -> enters in 3.0 min)
                Arguments.of("Direct S->N overhead at 1500 ft",
                        "N102SN", "PA28", 26.030613, -80.170710, 0.0, 120.0, "1500", "S", "~3 min"),

                // 3. NE -> SW diagonal transit (11 NM NE: dx=+7.78 NM, dy=+7.78 NM, track 225°, 140 kt -> enters in ~3.0 min)
                Arguments.of("Diagonal NE->SW transit at 2200 ft",
                        "N103NE", "SR22", 26.326916, -80.026240, 225.0, 140.0, "2200", "NE", "~3 min"),

                // 4. SW -> NE diagonal transit right at 2,500 ft Class D ceiling (13 NM SW, track 045°, 150 kt -> enters in ~3.6 min)
                Arguments.of("Diagonal SW->NE transit at exact 2500 ft ceiling",
                        "N104SW", "C182", 26.044035, -80.341447, 45.0, 150.0, "2500", "SW", "~4 min"),

                // 5. Low-altitude helicopter transit at 400 ft (7 NM NNE, track 200°, 90 kt -> enters in ~2.0 min)
                Arguments.of("Low-altitude helicopter NNE->SSW at 400 ft",
                        "N105HE", "R44", 26.306910, -80.126200, 200.0, 90.0, "400", "NNE", "~2 min"),

                // 6. West-offset Northbound transit (dx = -2.0 NM West, dy = -10.0 NM South, track 000°, 110 kt -> CPA = 2.0 NM, enters in ~3.5 min)
                Arguments.of("West-offset S->N transit (CPA 2.0 NM west of center)",
                        "N106WO", "DA40", 26.030613, -80.207858, 0.0, 110.0, "1600", "SSW", "~4 min"),

                // 7. East-offset Southbound transit (dx = +2.5 NM East, dy = +11.0 NM North, track 180°, 120 kt -> CPA = 2.5 NM, enters in ~4.0 min)
                Arguments.of("East-offset N->S transit (CPA 2.5 NM east of center)",
                        "N107EO", "BE36", 26.380613, -80.124275, 180.0, 120.0, "2000", "NNE", "~4 min"),

                // 8. Coastal/Western edge chord transit (dx = -3.2 NM West, dy = +9.0 NM North, track 180°, 100 kt -> CPA = 3.2 NM, chord = 4.8 NM, enters in ~4.0 min)
                Arguments.of("Western Class D sector N->S transit (CPA 3.2 NM west)",
                        "N108WE", "C152", 26.347280, -80.230147, 180.0, 100.0, "1200", "NNW", "~4 min"),

                // 9. Parallel to Runway 09 heading (track 084°), but offset 2.5 NM North of airport (outside 1.8 NM landing corridor -> triggers!)
                Arguments.of("Eastbound track 084° but offset 2.5 NM North of Rwy 09 centerline",
                        "N109PR", "PA44", 26.228947, -80.356450, 84.0, 120.0, "1900", "W", "~4 min"),

                // 10. Parallel to Runway 31 heading (track 309°), but offset 2.4 NM NE of airport (outside 1.8 NM landing corridor -> triggers!)
                Arguments.of("NW-bound track 309° but offset 2.4 NM NE of Rwy 31 centerline",
                        "N110PR", "C208", 26.135000, -79.995000, 309.0, 130.0, "2100", "ESE", "~3 min"),

                // 11. Fast turboprop transit (16 NM North, track 175°, 190 kt -> enters in ~3.8 min)
                Arguments.of("Fast turboprop N->S transit at 190 kt and 2400 ft",
                        "N111TP", "PC12", 26.463947, -80.195000, 175.0, 190.0, "2400", "N", "~4 min"),

                // 12. Imminent entry (5.2 NM South, track 000°, 90 kt -> 1.2 NM from boundary -> enters in ~0.8 min -> rounds to ~1 min)
                Arguments.of("Imminent entry 1.2 NM south of Class D boundary",
                        "N112IM", "C172", 26.110613, -80.170710, 0.0, 90.0, "1100", "S", "~1 min"),

                // 13. Outer 5-minute window edge (14.5 NM North, track 180°, 120 kt -> 10.5 NM from boundary -> enters in 5.25 min -> rounds to ~5 min)
                Arguments.of("Outer 5-minute window edge (5.25 min to boundary)",
                        "N113OU", "M20P", 26.438947, -80.170710, 180.0, 120.0, "1700", "N", "~5 min"),

                // 14. Early radio call-up lead window (20 NM North, track 180°, 120 kt -> 16 NM from boundary -> enters in 8.0 min -> ~3 min before 10 NM radio call!)
                Arguments.of("Early radio call-up window 20 NM out (8.0 min to boundary)",
                        "N114RC", "C172", 26.530613, -80.170710, 180.0, 120.0, "1800", "N", "~8 min")
        );
    }

    @ParameterizedTest(name = "{index}: {0}")
    @MethodSource("triggeringAircraftProvider")
    void evaluateAirspaceCrossings_triggeringScenarios_publishesAlert(
            String scenario,
            String reg,
            String type,
            double lat,
            double lon,
            double track,
            double gs,
            String altBaro,
            String expectedCompass,
            String expectedMinStr) {

        String payload = singleAircraftPayload("a00001", reg, type, lat, lon, track, gs, altBaro);
        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        ArgumentCaptor<Event> captor = ArgumentCaptor.forClass(Event.class);
        verify(eventRepository, times(1)).save(captor.capture());

        Event event = captor.getValue();
        String expectedCoords = String.format(Locale.US, "%.4f,%.4f", lat, lon);
        assertThat(scenario + " - type", event.getType(), is("kfxe.airspace.crossing"));
        assertThat(scenario + " - device", event.getDevice(), is("KFXE"));
        assertThat(scenario + " - utcTime", event.getUtcTime(), is(LocalDateTime.of(2026, 11, 3, 3, 52, 0)));
        assertThat(scenario + " - title", event.getData().get("title"), is(type + " will cross KFXE airspace in " + expectedMinStr));
        assertThat(scenario + " - body METAR UTC + reg + compass", (String) event.getData().get("body"),
                containsString("030352Z, " + reg + " approaching from " + expectedCompass + ", "));
        assertThat(scenario + " - body coords", (String) event.getData().get("body"), containsString(expectedCoords));
    }

    /**
     * Scenarios that MUST NOT trigger an alert:
     * - Aligned with KFXE runway final approach courses (Rwy 09: 084°, Rwy 27: 264°, Rwy 13: 129°, Rwy 31: 309°)
     * - Above 2,500 ft MSL Class D ceiling or below 300 ft airborne threshold
     * - Already inside the 4.0 NM cylinder (including departing aircraft)
     * - Flying away from KFXE or missing the 4.0 NM cylinder (or grazing with chord < 1.0 NM)
     * - Too far out (> 5.5 minutes to boundary) or too slow (< 50 kt)
     *
     * Columns: (scenario, reg, lat, lon, trackDeg, groundSpeedKt, altBaro)
     */
    static Stream<Arguments> nonTriggeringAircraftProvider() {
        return Stream.of(
                // --- Runway Final Approach Courses (Excluded) ---
                // 1. Final approach Runway 09 (exact true heading 084° from 11 NM West)
                Arguments.of("Landing Rwy 09 centerline (track 084° from West)",
                        "N201R9", 26.183300, -80.374000, 84.0, 125.0, "1600"),

                // 2. Final approach Runway 09 with +10° intercept angle (track 094° within ±15° tolerance, CPA < 1.8 NM)
                Arguments.of("Landing Rwy 09 intercept (track 094° within tolerance)",
                        "N202R9", 26.209000, -80.356000, 94.0, 120.0, "1500"),

                // 3. Final approach Runway 27 (exact true heading 264° from 11 NM East)
                Arguments.of("Landing Rwy 27 centerline (track 264° from East)",
                        "N203R27", 26.211200, -79.967500, 264.0, 130.0, "1500"),

                // 4. Final approach Runway 27 with -12° intercept angle (track 252° within ±15° tolerance)
                Arguments.of("Landing Rwy 27 intercept (track 252° within tolerance)",
                        "N204R27", 26.248000, -79.992000, 252.0, 120.0, "1700"),

                // 5. Final approach Runway 13 (exact true heading 129° from 10 NM NW)
                Arguments.of("Landing Rwy 13 centerline (track 129° from NW)",
                        "N205R13", 26.302200, -80.315000, 129.0, 115.0, "1400"),

                // 6. Final approach Runway 31 (exact true heading 309° from 10 NM SE)
                Arguments.of("Landing Rwy 31 centerline (track 309° from SE)",
                        "N206R31", 26.092400, -80.026400, 309.0, 115.0, "1400"),

                // --- Altitude Exclusions ---
                // 7. Above Class D ceiling at 2,600 ft MSL (overflying in KFLL Class C shelf)
                Arguments.of("Above Class D ceiling (2600 ft > 2500 ft)",
                        "N207HI", 26.397280, -80.170710, 180.0, 120.0, "2600"),

                // 8. High-altitude airliner at 8,000 ft MSL
                Arguments.of("High-altitude airliner at 8000 ft",
                        "N208AL", 26.397280, -80.170710, 180.0, 250.0, "8000"),

                // 9. Below minimum airborne altitude at 200 ft
                Arguments.of("Below minimum airborne altitude (200 ft < 300 ft)",
                        "N209LO", 26.310000, -80.170710, 180.0, 80.0, "200"),

                // 10. Aircraft reporting 'ground' in alt_baro
                Arguments.of("Aircraft on ground (alt_baro = 'ground')",
                        "N210GR", 26.310000, -80.170710, 180.0, 80.0, "ground"),

                // --- Distance / Position Exclusions ---
                // 11. Already inside the 4.0 NM Class D cylinder (2.5 NM North, heading South)
                Arguments.of("Already inside 4.0 NM cylinder (2.5 NM North)",
                        "N211IN", 26.238947, -80.170710, 180.0, 120.0, "1500"),

                // 12. Taking off / departing from inside KFXE (1.5 NM East, climbing out heading East)
                Arguments.of("Departing aircraft inside 4.0 NM cylinder (1.5 NM East)",
                        "N212DP", 26.197280, -80.142850, 84.0, 110.0, "900"),

                // 13. Outside cylinder but flying AWAY from KFXE (8 NM North, heading 000° Northbound)
                Arguments.of("Outside cylinder flying away (8 NM North heading 000°)",
                        "N213AW", 26.330613, -80.170710, 0.0, 120.0, "1800"),

                // 14. Outside cylinder on parallel path missing cylinder completely (CPA = 5.5 NM East > 4.0 NM)
                Arguments.of("Misses 4.0 NM cylinder completely (CPA 5.5 NM East)",
                        "N214MS", 26.397280, -80.068550, 180.0, 120.0, "1800"),

                // 15. Grazing outer edge of 4.0 NM cylinder (dx = 3.96 NM East -> CPA = 3.96 NM -> chord = 1.13 NM, let's use dx = 3.98 NM -> chord = 0.80 NM < 1.0 NM)
                Arguments.of("Shallow graze of cylinder edge (CPA 3.98 NM, chord 0.80 NM < 1.0 NM)",
                        "N215GZ", 26.363947, -80.096785, 180.0, 120.0, "1800"),

                // --- Timing & Speed Exclusions ---
                // 16. Too far away: 26 NM North at 120 kt (22 NM to boundary -> 11.0 minutes away > 8.5 min max window)
                Arguments.of("Too far away (11.0 minutes to boundary > 8.5 min window)",
                        "N216FR", 26.630613, -80.170710, 180.0, 120.0, "1800"),

                // 17. Too close to boundary (< 0.5 min): 4.2 NM North at 120 kt (0.2 NM to boundary -> 0.1 min < 0.5 min)
                Arguments.of("Already at boundary edge (0.1 min to boundary < 0.5 min)",
                        "N217CL", 26.267280, -80.170710, 180.0, 120.0, "1800"),

                // 18. Ground speed below 50 kt threshold (hovering/slow helicopter at 35 kt)
                Arguments.of("Speed below 50 kt threshold (35 kt)",
                        "N218SL", 26.297280, -80.170710, 180.0, 35.0, "1000")
        );
    }

    @ParameterizedTest(name = "{index}: {0}")
    @MethodSource("nonTriggeringAircraftProvider")
    void evaluateAirspaceCrossings_nonTriggeringScenarios_doesNotPublishAlert(
            String scenario,
            String reg,
            double lat,
            double lon,
            double track,
            double gs,
            String altBaro) {

        String payload = singleAircraftPayload("b00001", reg, "C172", lat, lon, track, gs, altBaro);
        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        verify(eventRepository, never()).save(any(Event.class));
    }

    @Test
    void evaluateAirspaceCrossings_sameAircraftWithin30Minutes_alertsOnlyOnceThenReAlertsAfterExpiry() {
        String payload = singleAircraftPayload(
                "a12345", "N123AB", "C172", 26.397280, -80.170710, 180.0, 120.0, "1800");

        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        // First detection -> saves event
        service.evaluateAirspaceCrossings();
        verify(eventRepository, times(1)).save(any(Event.class));

        // 1 minute and 15 minutes later -> suppressed by 30-minute deduplication window
        clearInvocations(eventRepository);
        advanceTime(Duration.ofMinutes(1));
        service.evaluateAirspaceCrossings();
        advanceTime(Duration.ofMinutes(14));
        service.evaluateAirspaceCrossings();
        verify(eventRepository, never()).save(any(Event.class));

        // 31 minutes after first alert -> deduplication expired, saves event again
        advanceTime(Duration.ofMinutes(16));
        service.evaluateAirspaceCrossings();
        verify(eventRepository, times(1)).save(any(Event.class));
    }

    @Test
    void evaluateAirspaceCrossings_exactTitleAndBodyFormatting_matchesSpecification() {
        String payload = singleAircraftPayload(
                "a12345", "N123AB", "C172", 26.397280, -80.170710, 180.0, 120.0, "1800");

        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        ArgumentCaptor<Event> captor = ArgumentCaptor.forClass(Event.class);
        verify(eventRepository, times(1)).save(captor.capture());

        Event event = captor.getValue();
        assertThat(event.getType(), is("kfxe.airspace.crossing"));
        assertThat(event.getDevice(), is("KFXE"));
        assertThat(event.getUtcTime(), is(LocalDateTime.of(2026, 11, 3, 3, 52, 0)));
        assertThat(event.getData().get("title"), is("C172 will cross KFXE airspace in ~4 min"));
        assertThat(event.getData().get("body"), is("030352Z, N123AB approaching from N, 12.0 NM out, 26.3973,-80.1707, 1,800 ft, 120 kt, 180°"));
    }
}
