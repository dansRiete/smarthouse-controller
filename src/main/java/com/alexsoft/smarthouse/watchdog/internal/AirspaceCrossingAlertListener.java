package com.alexsoft.smarthouse.watchdog.internal;

import com.alexsoft.smarthouse.environment.AirspaceCrossingAlertEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class AirspaceCrossingAlertListener {

    private final FcmService fcmService;

    @EventListener
    public void onAirspaceCrossingAlert(AirspaceCrossingAlertEvent event) {
        log.info("Sending FCM gentle alert for KFXE crossing: {} — {}", event.title(), event.body());
        fcmService.sendAlert(event.title(), event.body(), "gentle");
    }
}
