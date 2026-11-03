package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.environment.MetarLocationsConfig;
import com.alexsoft.smarthouse.mqtt.MessageSenderService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.util.concurrent.Executor;

import static org.hamcrest.MatcherAssert.assertThat;
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
class MetarServiceAircraftCircuitBreakerTest {

    private static final String SAMPLE_PAYLOAD = """
            {
              "ac": [
                {
                  "hex": "a11111",
                  "r": "N123AB",
                  "alt_baro": "2500",
                  "gs": 120.0,
                  "lat": 26.20,
                  "lon": -80.17
                },
                {
                  "hex": "a22222",
                  "r": "N999ZZ",
                  "alt_baro": "ground",
                  "gs": 0.0,
                  "lat": 26.20,
                  "lon": -80.17
                }
              ]
            }
            """;

    @Mock
    private MetarLocationsConfig metarLocationsConfig;

    @Mock
    private RestTemplateBuilder restTemplateBuilder;

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private IndicationServiceV3 indicationServiceV3;

    @Mock
    private AirspaceActivityRepository airspaceActivityRepository;

    @Mock
    private MessageSenderService messageSenderService;

    private final Executor directExecutor = Runnable::run;

    private MetarService metarService;
    private Instant currentInstant;

    @BeforeEach
    void setUp() {
        lenient().when(restTemplateBuilder.connectTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.readTimeout(any())).thenReturn(restTemplateBuilder);
        lenient().when(restTemplateBuilder.build()).thenReturn(restTemplate);

        metarService = new MetarService(
                metarLocationsConfig,
                restTemplateBuilder,
                indicationServiceV3,
                airspaceActivityRepository,
                messageSenderService,
                directExecutor
        );

        currentInstant = Instant.parse("2026-11-02T12:00:00Z");
        updateClock();
    }

    private void updateClock() {
        metarService.setClock(Clock.fixed(currentInstant, ZoneId.of("UTC")));
    }

    private void advanceTime(Duration duration) {
        currentInstant = currentInstant.plus(duration);
        updateClock();
    }

    @Test
    void readAircraftNumber_successfulResponse_savesFilteredAirspaceActivity() {
        when(restTemplate.exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(SAMPLE_PAYLOAD));

        metarService.readAircraftNumber();

        ArgumentCaptor<AirspaceActivity> captor = ArgumentCaptor.forClass(AirspaceActivity.class);
        verify(airspaceActivityRepository).save(captor.capture());

        AirspaceActivity saved = captor.getValue();
        assertThat(saved.getAirspace(), is("FXE"));
        assertThat(saved.getAirborneAircrafts(), is(1));
        assertThat(saved.getAircrafts(), is("N123AB"));
    }

    @Test
    void readAircraftNumber_403Forbidden_tripsCircuitImmediatelyAndSkipsSubsequentCalls() {
        HttpClientErrorException forbidden = HttpClientErrorException.create(
                HttpStatus.FORBIDDEN, "Forbidden", HttpHeaders.EMPTY, new byte[0], StandardCharsets.UTF_8);

        when(restTemplate.exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenThrow(forbidden);

        // 1st call: 403 -> immediate trip for 15 minutes
        metarService.readAircraftNumber();
        verify(restTemplate, times(1)).exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class));
        verify(airspaceActivityRepository, never()).save(any());

        // Calls during the 15-minute cooldown are skipped without hitting RestTemplate
        clearInvocations(restTemplate);
        advanceTime(Duration.ofMinutes(1));
        metarService.readAircraftNumber();
        advanceTime(Duration.ofMinutes(13));
        metarService.readAircraftNumber();
        verify(restTemplate, never()).exchange(any(), any(), any(), eq(String.class));
    }

    @Test
    void readAircraftNumber_threeConsecutiveNetworkFailures_opensCircuitThenBacksOffAndRecovers() {
        when(restTemplate.exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenThrow(new ResourceAccessException("Connection timed out"));

        // Failures 1, 2, 3 -> trips circuit on 3rd failure (15m cooldown)
        metarService.readAircraftNumber();
        metarService.readAircraftNumber();
        metarService.readAircraftNumber();
        verify(restTemplate, times(3)).exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class));

        // 4th call before 15m cooldown expires -> skipped
        clearInvocations(restTemplate);
        advanceTime(Duration.ofMinutes(10));
        metarService.readAircraftNumber();
        verify(restTemplate, never()).exchange(any(), any(), any(), eq(String.class));

        // Advance past 15m cooldown -> HALF-OPEN probe allowed, still fails -> cooldown doubles to 30m
        advanceTime(Duration.ofMinutes(6));
        metarService.readAircraftNumber();
        verify(restTemplate, times(1)).exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class));

        // 20 minutes later (within 30m backoff) -> still skipped
        clearInvocations(restTemplate);
        advanceTime(Duration.ofMinutes(20));
        metarService.readAircraftNumber();
        verify(restTemplate, never()).exchange(any(), any(), any(), eq(String.class));

        // Advance past 30m backoff -> HALF-OPEN probe succeeds -> circuit closes and normal calls resume
        when(restTemplate.exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(SAMPLE_PAYLOAD));

        advanceTime(Duration.ofMinutes(11));
        metarService.readAircraftNumber();
        verify(restTemplate, times(1)).exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class));
        verify(airspaceActivityRepository, times(1)).save(any());

        // Subsequent call 1 minute later works normally (circuit is CLOSED)
        advanceTime(Duration.ofMinutes(1));
        metarService.readAircraftNumber();
        verify(restTemplate, times(2)).exchange(eq(MetarService.ADSB_URL), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class));
        verify(airspaceActivityRepository, times(2)).save(any());
    }
}
