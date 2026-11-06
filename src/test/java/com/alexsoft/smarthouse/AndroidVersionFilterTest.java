package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.core.Event;
import com.alexsoft.smarthouse.core.EventRepository;
import com.alexsoft.smarthouse.core.GlobalSetting;
import com.alexsoft.smarthouse.core.GlobalSettingRepository;
import com.alexsoft.smarthouse.core.configuration.AndroidVersionFilter;
import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.Optional;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AndroidVersionFilterTest {

    @Mock
    private GlobalSettingRepository globalSettingRepository;

    @Mock
    private EventRepository eventRepository;

    @Mock
    private FilterChain filterChain;

    @InjectMocks
    private AndroidVersionFilter androidVersionFilter;

    private GlobalSetting minVersionSetting;

    @BeforeEach
    public void setUp() {
        minVersionSetting = GlobalSetting.builder()
                .key(AndroidVersionFilter.MIN_ANDROID_VERSION_KEY)
                .value("2.0")
                .build();
    }

    @Test
    public void testOldAndroidAppWithoutVersionHeaderGetAppliancesReturnsPlaceholderCard() throws Exception {
        when(globalSettingRepository.findById(AndroidVersionFilter.MIN_ANDROID_VERSION_KEY))
                .thenReturn(Optional.of(minVersionSetting));

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/smarthouse/appliances");
        request.addHeader("User-Agent", "okhttp/4.12.0");
        MockHttpServletResponse response = new MockHttpServletResponse();

        androidVersionFilter.doFilter(request, response, filterChain);

        verify(filterChain, never()).doFilter(any(), any());
        verify(eventRepository).save(any(Event.class));
        assertThat(response.getStatus(), is(200));
        assertThat(response.getContentAsString(), containsString("App version is outdated. Please update SmartHouse to v2.0+"));
    }

    @Test
    public void testOldAndroidAppPatchApplianceReturns426() throws Exception {
        when(globalSettingRepository.findById(AndroidVersionFilter.MIN_ANDROID_VERSION_KEY))
                .thenReturn(Optional.of(minVersionSetting));

        MockHttpServletRequest request = new MockHttpServletRequest("PATCH", "/smarthouse/appliances/AC");
        request.addHeader("X-Client-Platform", "android");
        request.addHeader("X-App-Version", "1.13");
        MockHttpServletResponse response = new MockHttpServletResponse();

        androidVersionFilter.doFilter(request, response, filterChain);

        verify(filterChain, never()).doFilter(any(), any());
        verify(eventRepository).save(any(Event.class));
        assertThat(response.getStatus(), is(426));
        assertThat(response.getContentAsString(), containsString("Outdated Android app version"));
    }

    @Test
    public void testCurrentAndroidAppVersionPassesThrough() throws Exception {
        when(globalSettingRepository.findById(AndroidVersionFilter.MIN_ANDROID_VERSION_KEY))
                .thenReturn(Optional.of(minVersionSetting));

        MockHttpServletRequest request = new MockHttpServletRequest("PATCH", "/smarthouse/appliances/AC");
        request.addHeader("X-Client-Platform", "android");
        request.addHeader("X-App-Version", "2.0");
        MockHttpServletResponse response = new MockHttpServletResponse();

        androidVersionFilter.doFilter(request, response, filterChain);

        verify(filterChain, times(1)).doFilter(request, response);
        verify(eventRepository, never()).save(any(Event.class));
    }

    @Test
    public void testNonAndroidClientPassesThroughWithoutVersionHeader() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/smarthouse/appliances");
        request.addHeader("User-Agent", "python-requests/2.31.0");
        MockHttpServletResponse response = new MockHttpServletResponse();

        androidVersionFilter.doFilter(request, response, filterChain);

        verify(filterChain, times(1)).doFilter(request, response);
        verify(globalSettingRepository, never()).findById(any());
    }
}
