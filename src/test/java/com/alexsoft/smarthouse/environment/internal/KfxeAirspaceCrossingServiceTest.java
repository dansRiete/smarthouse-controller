package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.environment.AirspaceCrossingAlertEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
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

    @Mock
    private RestTemplateBuilder restTemplateBuilder;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    private KfxeAirspaceCrossingService service;
    private Instant currentInstant;

    @BeforeEach
    void setUp() {
        lenient().when(restTemplateBuilder.connectTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.readTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.build()).thenReturn(restTemplate);

        service = new KfxeAirspaceCrossingService(restTemplateBuilder, eventPublisher);
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

    @Test
    void evaluateAirspaceCrossings_southboundTransitBelow2500Ft_publishesCrossingAlertWithUtcTime() {
        // Aircraft ~12 NM directly North of KFXE (lat = 26.19728 + 0.20 = 26.39728, lon = -80.17071),
        // heading 180° (due South, not aligned with Rwy 09/27 or 13/31) at 120 kt (2 NM/min).
        // Distance = 12 NM; enters 4 NM circle at distance 8 NM -> t_entry = 4.0 minutes (~03:56 UTC).
        String payload = """
                {
                  "ac": [
                    {
                      "hex": "a12345",
                      "r": "N123AB",
                      "t": "C172",
                      "alt_baro": "1800",
                      "gs": 120.0,
                      "track": 180.0,
                      "lat": 26.39728,
                      "lon": -80.17071
                    }
                  ]
                }
                """;

        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        ArgumentCaptor<AirspaceCrossingAlertEvent> captor = ArgumentCaptor.forClass(AirspaceCrossingAlertEvent.class);
        verify(eventPublisher, times(1)).publishEvent(captor.capture());

        AirspaceCrossingAlertEvent event = captor.getValue();
        assertThat(event.title(), containsString("KFXE Airspace Crossing (~4 min, ~03:56 UTC)"));
        assertThat(event.body(), containsString("[03:52 UTC] N123AB (C172) approaching from N (12.0 NM out) at 1,800 ft, 120 kt, track 180°"));

        // Deduplicated on next minute tick
        clearInvocations(eventPublisher);
        advanceTime(Duration.ofMinutes(1));
        service.evaluateAirspaceCrossings();
        verify(eventPublisher, never()).publishEvent(any(AirspaceCrossingAlertEvent.class));
    }

    @Test
    void evaluateAirspaceCrossings_aircraftOnRunway09LandingCourse_isFilteredOut() {
        // Aircraft ~12 NM West of KFXE approaching on true track 084° (Runway 09 final approach course)
        String payload = """
                {
                  "ac": [
                    {
                      "hex": "a99999",
                      "r": "N900FX",
                      "t": "C56X",
                      "alt_baro": "1600",
                      "gs": 130.0,
                      "track": 84.0,
                      "lat": 26.1833,
                      "lon": -80.3910
                    }
                  ]
                }
                """;

        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        verify(eventPublisher, never()).publishEvent(any(AirspaceCrossingAlertEvent.class));
    }

    @Test
    void evaluateAirspaceCrossings_aircraftAbove2500FtCeiling_isFilteredOut() {
        // Same trajectory as the valid crossing, but at 3,000 ft MSL (above KFXE Class D 2,500 ft ceiling)
        String payload = """
                {
                  "ac": [
                    {
                      "hex": "a55555",
                      "r": "N555HI",
                      "t": "PA28",
                      "alt_baro": "3000",
                      "gs": 120.0,
                      "track": 180.0,
                      "lat": 26.39728,
                      "lon": -80.17071
                    }
                  ]
                }
                """;

        when(restTemplate.exchange(eq(KfxeAirspaceCrossingService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(payload));

        service.evaluateAirspaceCrossings();

        verify(eventPublisher, never()).publishEvent(any(AirspaceCrossingAlertEvent.class));
    }
}
