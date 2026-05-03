package com.alexsoft.smarthouse.controller;

import com.alexsoft.smarthouse.service.FcmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/fcm")
@RequiredArgsConstructor
public class FcmController {

    private final FcmService fcmService;

    @PostMapping("/register")
    public ResponseEntity<Void> registerToken(@RequestBody Map<String, String> body) {
        String token = body.get("token");
        String deviceName = body.getOrDefault("deviceName", "unknown");
        if (token == null || token.isBlank()) return ResponseEntity.badRequest().build();
        fcmService.registerToken(token, deviceName);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/send")
    public ResponseEntity<String> sendAlert(@RequestBody Map<String, String> body) {
        String result = fcmService.sendAlert(
                body.getOrDefault("title", "Smarthouse Alert"),
                body.getOrDefault("body", "")
        );
        return ResponseEntity.ok(result);
    }
}
