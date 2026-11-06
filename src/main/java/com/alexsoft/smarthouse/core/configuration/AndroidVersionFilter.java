package com.alexsoft.smarthouse.core.configuration;

import com.alexsoft.smarthouse.core.Event;
import com.alexsoft.smarthouse.core.EventRepository;
import com.alexsoft.smarthouse.core.GlobalSetting;
import com.alexsoft.smarthouse.core.GlobalSettingRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static com.alexsoft.smarthouse.core.util.DateUtils.getUtc;

@Component
@RequiredArgsConstructor
public class AndroidVersionFilter extends OncePerRequestFilter {

    private static final Logger LOGGER = LoggerFactory.getLogger(AndroidVersionFilter.class);
    public static final String MIN_ANDROID_VERSION_KEY = "min_android_app_version";
    public static final String HEADER_CLIENT_PLATFORM = "X-Client-Platform";
    public static final String HEADER_APP_VERSION = "X-App-Version";

    private final GlobalSettingRepository globalSettingRepository;
    private final EventRepository eventRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (!isAndroidClient(request)) {
            filterChain.doFilter(request, response);
            return;
        }

        Optional<GlobalSetting> minVersionSetting = globalSettingRepository.findById(MIN_ANDROID_VERSION_KEY);
        if (minVersionSetting.isEmpty() || minVersionSetting.get().getValue() == null
                || minVersionSetting.get().getValue().isBlank()) {
            filterChain.doFilter(request, response);
            return;
        }

        String minVersion = minVersionSetting.get().getValue().trim();
        String clientVersion = request.getHeader(HEADER_APP_VERSION);

        if (clientVersion == null || clientVersion.isBlank() || compareVersions(clientVersion.trim(), minVersion) < 0) {
            String ip = extractIp(request);
            LOGGER.warn("Rejecting outdated Android app request: method={} uri={} clientVersion={} minVersion={} ip={}",
                    request.getMethod(), request.getRequestURI(), clientVersion, minVersion, ip);

            Map<String, Object> eventData = new HashMap<>();
            eventData.put("method", request.getMethod());
            eventData.put("uri", request.getRequestURI());
            eventData.put("clientVersion", clientVersion != null ? clientVersion : "missing");
            eventData.put("minVersion", minVersion);
            eventData.put("ip", ip);
            String requesterId = request.getParameter("requesterId");
            if (requesterId != null) {
                eventData.put("requesterId", requesterId);
            }
            eventRepository.save(Event.builder()
                    .utcTime(getUtc())
                    .type("http.rejected.outdated_version")
                    .device(null)
                    .data(eventData)
                    .build());

            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/json");

            if ("GET".equalsIgnoreCase(request.getMethod()) && request.getRequestURI().endsWith("/appliances")) {
                response.setStatus(HttpServletResponse.SC_OK);
                String placeholderJson = String.format(
                        "[{\"code\":\"UPDATE\",\"description\":\"⚠️ App version is outdated. Please update SmartHouse to v%s+\",\"state\":\"OFF\",\"locked\":false}]",
                        minVersion
                );
                response.getWriter().write(placeholderJson);
            } else {
                response.setStatus(426); // Upgrade Required
                String errorJson = String.format(
                        "{\"error\":\"Outdated Android app version. Please update SmartHouse to v%s+\"}",
                        minVersion
                );
                response.getWriter().write(errorJson);
            }
            return;
        }

        filterChain.doFilter(request, response);
    }

    private boolean isAndroidClient(HttpServletRequest request) {
        String platform = request.getHeader(HEADER_CLIENT_PLATFORM);
        if ("android".equalsIgnoreCase(platform)) {
            return true;
        }
        String userAgent = request.getHeader("User-Agent");
        return userAgent != null && userAgent.toLowerCase().startsWith("okhttp/");
    }

    public static int compareVersions(String v1, String v2) {
        String[] parts1 = v1.replaceAll("[^0-9.]", "").split("\\.");
        String[] parts2 = v2.replaceAll("[^0-9.]", "").split("\\.");
        int length = Math.max(parts1.length, parts2.length);
        for (int i = 0; i < length; i++) {
            int p1 = (i < parts1.length && !parts1[i].isEmpty()) ? Integer.parseInt(parts1[i]) : 0;
            int p2 = (i < parts2.length && !parts2[i].isEmpty()) ? Integer.parseInt(parts2[i]) : 0;
            if (p1 != p2) {
                return Integer.compare(p1, p2);
            }
        }
        return 0;
    }

    private static String extractIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        return (forwarded != null && !forwarded.isBlank()) ? forwarded.split(",")[0].trim() : request.getRemoteAddr();
    }
}
