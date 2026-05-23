package com.alexsoft.smarthouse.watchdog.resolver;

import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class HttpStateResolver implements StateResolver {

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public boolean supports(String scheme) {
        return "http".equalsIgnoreCase(scheme) || "https".equalsIgnoreCase(scheme);
    }

    @Override
    public String resolve(String url) {
        try {
            return restTemplate.getForObject(url, String.class);
        } catch (Exception e) {
            throw new RuntimeException("HTTP State Query failed: " + e.getMessage(), e);
        }
    }
}
