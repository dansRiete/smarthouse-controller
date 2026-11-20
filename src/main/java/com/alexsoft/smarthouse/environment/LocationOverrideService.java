package com.alexsoft.smarthouse.environment;

import com.alexsoft.smarthouse.core.GlobalSetting;
import com.alexsoft.smarthouse.core.GlobalSettingRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Map;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class LocationOverrideService {

  public static final String SETTING_KEY = "location_id_overrides";
  private static final int CACHE_TTL_MINUTES = 1;

  private final GlobalSettingRepository globalSettingRepository;
  private final ObjectMapper objectMapper = new ObjectMapper();

  private volatile Map<String, String> cachedOverrides = Collections.emptyMap();
  private volatile LocalDateTime cacheExpiry = LocalDateTime.MIN;

  public String resolve(String locationId) {
    if (locationId == null) {
      return null;
    }
    if (LocalDateTime.now().isAfter(cacheExpiry)) {
      refreshCache();
    }
    return cachedOverrides.getOrDefault(locationId, locationId);
  }

  private synchronized void refreshCache() {
    if (!LocalDateTime.now().isAfter(cacheExpiry)) {
      return;
    }
    try {
      Optional<GlobalSetting> settingOpt = globalSettingRepository.findById(SETTING_KEY);
      if (settingOpt.isPresent() && settingOpt.get().getValue() != null && !settingOpt.get().getValue().isBlank()) {
        Map<String, String> parsed = objectMapper.readValue(settingOpt.get().getValue(), new TypeReference<>() {});
        cachedOverrides = parsed != null ? Map.copyOf(parsed) : Collections.emptyMap();
      } else {
        cachedOverrides = Collections.emptyMap();
      }
    } catch (Exception e) {
      log.error("Failed to parse {} from global_settings", SETTING_KEY, e);
    } finally {
      cacheExpiry = LocalDateTime.now().plusMinutes(CACHE_TTL_MINUTES);
    }
  }
}
