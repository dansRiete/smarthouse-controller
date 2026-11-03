package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.watchdog.internal.AirspaceCrossingAlertListener;
import com.alexsoft.smarthouse.watchdog.internal.FcmService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.web.client.RestTemplateAutoConfiguration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;
import org.springframework.test.web.client.MockRestServiceServer;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Locale;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

@SpringJUnitConfig(classes = {
        RestTemplateAutoConfiguration.class,
        KfxeAirspaceCrossingService.class,
        AirspaceCrossingAlertListener.class
})
class KfxeAirspaceCrossingIntegrationTest {

    @Autowired
    private KfxeAirspaceCrossingService crossingService;

    @MockitoBean
    private FcmService fcmService;

    private MockRestServiceServer mockServer;

    @BeforeEach
    void setUp() {
        crossingService.resetStateForTesting();
        crossingService.setClock(Clock.fixed(Instant.parse("2026-11-03T03:52:00Z"), ZoneOffset.UTC));
        mockServer = MockRestServiceServer.createServer(crossingService.getRestTemplate());
    }

    private static String singleAircraftHttpPayload(
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
                  ],
                  "msg": "No error",
                  "now": 1793677920.0,
                  "total": 1
                }
                """, hex, reg, type, altBaro, gs, track, lat, lon);
    }

    @ParameterizedTest(name = "HTTP IT Triggering #{index}: {0}")
    @MethodSource("com.alexsoft.smarthouse.environment.internal.KfxeAirspaceCrossingServiceTest#triggeringAircraftProvider")
    void httpIntegration_triggeringAircraftPositions_sendsGentleFcmAlertEndToEnd(
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

        String jsonBody = singleAircraftHttpPayload("a00001", reg, type, lat, lon, track, gs, altBaro);

        mockServer.expect(requestTo(KfxeAirspaceCrossingService.ADSB_URL))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(HttpHeaders.ACCEPT, containsString(MediaType.APPLICATION_JSON_VALUE)))
                .andRespond(withSuccess(jsonBody, MediaType.APPLICATION_JSON));

        crossingService.evaluateAirspaceCrossings();

        mockServer.verify();

        ArgumentCaptor<String> titleCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> bodyCaptor = ArgumentCaptor.forClass(String.class);
        verify(fcmService, times(1)).sendAlert(titleCaptor.capture(), bodyCaptor.capture(), eq("gentle"));

        assertThat(scenario + " - FCM title", titleCaptor.getValue(), containsString("KFXE Airspace Crossing (" + expectedMinStr));
        assertThat(scenario + " - FCM title UTC", titleCaptor.getValue(), containsString("UTC)"));
        assertThat(scenario + " - FCM body UTC", bodyCaptor.getValue(), containsString("[03:52 UTC]"));
        assertThat(scenario + " - FCM body reg/type", bodyCaptor.getValue(), containsString(reg + " (" + type + ")"));
        assertThat(scenario + " - FCM body compass", bodyCaptor.getValue(), containsString("approaching from " + expectedCompass));
    }

    @ParameterizedTest(name = "HTTP IT Non-Triggering #{index}: {0}")
    @MethodSource("com.alexsoft.smarthouse.environment.internal.KfxeAirspaceCrossingServiceTest#nonTriggeringAircraftProvider")
    void httpIntegration_nonTriggeringAircraftPositions_doesNotSendFcmAlert(
            String scenario,
            String reg,
            double lat,
            double lon,
            double track,
            double gs,
            String altBaro) {

        String jsonBody = singleAircraftHttpPayload("b00001", reg, "C172", lat, lon, track, gs, altBaro);

        mockServer.expect(requestTo(KfxeAirspaceCrossingService.ADSB_URL))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(HttpHeaders.ACCEPT, containsString(MediaType.APPLICATION_JSON_VALUE)))
                .andRespond(withSuccess(jsonBody, MediaType.APPLICATION_JSON));

        crossingService.evaluateAirspaceCrossings();

        mockServer.verify();
        verify(fcmService, never()).sendAlert(anyString(), anyString(), anyString());
    }

    @Test
    void httpIntegration_mixedBatchResponse_alertsOnlyForValidCrossings() {
        String batchJson = """
                {
                  "ac": [
                    {
                      "hex": "a10101",
                      "r": "N101NS",
                      "t": "C172",
                      "alt_baro": "1800",
                      "gs": 120.0,
                      "track": 180.0,
                      "lat": 26.397280,
                      "lon": -80.170710
                    },
                    {
                      "hex": "b20101",
                      "r": "N201R9",
                      "t": "C56X",
                      "alt_baro": "1600",
                      "gs": 125.0,
                      "track": 84.0,
                      "lat": 26.183300,
                      "lon": -80.374000
                    },
                    {
                      "hex": "b20801",
                      "r": "DAL123",
                      "t": "B738",
                      "alt_baro": "8000",
                      "gs": 250.0,
                      "track": 180.0,
                      "lat": 26.397280,
                      "lon": -80.170710
                    },
                    {
                      "hex": "a10301",
                      "r": "N103NE",
                      "t": "SR22",
                      "alt_baro": "2200",
                      "gs": 140.0,
                      "track": 225.0,
                      "lat": 26.326916,
                      "lon": -80.026240
                    }
                  ]
                }
                """;

        mockServer.expect(requestTo(KfxeAirspaceCrossingService.ADSB_URL))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(batchJson, MediaType.APPLICATION_JSON));

        crossingService.evaluateAirspaceCrossings();

        mockServer.verify();

        ArgumentCaptor<String> bodyCaptor = ArgumentCaptor.forClass(String.class);
        verify(fcmService, times(2)).sendAlert(anyString(), bodyCaptor.capture(), eq("gentle"));
        assertThat(bodyCaptor.getAllValues().get(0), containsString("N101NS (C172)"));
        assertThat(bodyCaptor.getAllValues().get(1), containsString("N103NE (SR22)"));
    }

    @Test
    void httpIntegration_http429RateLimit_tripsCircuitBreakerAndSkipsNextHttpCall() {
        mockServer.expect(requestTo(KfxeAirspaceCrossingService.ADSB_URL))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withStatus(HttpStatus.TOO_MANY_REQUESTS));

        // 1st call receives HTTP 429 -> trips circuit immediately
        crossingService.evaluateAirspaceCrossings();
        mockServer.verify();

        // 2nd call while circuit is OPEN -> makes 0 HTTP requests (mockServer has no expectations and succeeds)
        mockServer.reset();
        crossingService.evaluateAirspaceCrossings();
        mockServer.verify();
        verify(fcmService, never()).sendAlert(anyString(), anyString(), anyString());
    }
}
