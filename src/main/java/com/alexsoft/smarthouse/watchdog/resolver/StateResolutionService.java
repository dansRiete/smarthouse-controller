package com.alexsoft.smarthouse.watchdog.resolver;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class StateResolutionService {

    private final List<StateResolver> resolvers;

    public String gatherState(String url) {
        if (url == null || url.isBlank()) {
            return "{}";
        }

        try {
            String scheme;
            if (url.contains("://")) {
                scheme = url.split("://")[0].toLowerCase();
            } else {
                scheme = "http"; // Default fallback
            }

            return resolvers.stream()
                    .filter(resolver -> resolver.supports(scheme))
                    .findFirst()
                    .map(resolver -> resolver.resolve(url))
                    .orElseThrow(() -> new IllegalArgumentException("No StateResolver found for scheme: " + scheme));
        } catch (Exception e) {
            log.error("Failed to resolve state URL '{}': {}", url, e.getMessage());
            return "{\"error\": \"Failed to resolve state: " + e.getMessage() + "\"}";
        }
    }
}
