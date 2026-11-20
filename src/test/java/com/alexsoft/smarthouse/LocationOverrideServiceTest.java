package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.core.GlobalSetting;
import com.alexsoft.smarthouse.core.GlobalSettingRepository;
import com.alexsoft.smarthouse.environment.LocationOverrideService;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LocationOverrideServiceTest {

  @Mock
  private GlobalSettingRepository globalSettingRepository;

  @InjectMocks
  private LocationOverrideService service;

  @Test
  void resolvesConfiguredOverrideAndCachesResult() {
    GlobalSetting setting = GlobalSetting.builder()
        .key(LocationOverrideService.SETTING_KEY)
        .value("{\"935-CORKWOOD-B\":\"BEDROOM\"}")
        .build();
    when(globalSettingRepository.findById(LocationOverrideService.SETTING_KEY)).thenReturn(Optional.of(setting));

    assertThat(service.resolve("935-CORKWOOD-B")).isEqualTo("BEDROOM");
    assertThat(service.resolve("LIVING-ROOM")).isEqualTo("LIVING-ROOM");
    verify(globalSettingRepository, times(1)).findById(LocationOverrideService.SETTING_KEY);
  }

  @Test
  void returnsOriginalWhenSettingMissingOrNull() {
    when(globalSettingRepository.findById(LocationOverrideService.SETTING_KEY)).thenReturn(Optional.empty());

    assertThat(service.resolve("935-CORKWOOD-B")).isEqualTo("935-CORKWOOD-B");
    assertThat(service.resolve(null)).isNull();
  }

  @Test
  void returnsOriginalWhenJsonInvalid() {
    GlobalSetting setting = GlobalSetting.builder()
        .key(LocationOverrideService.SETTING_KEY)
        .value("not-valid-json")
        .build();
    when(globalSettingRepository.findById(LocationOverrideService.SETTING_KEY)).thenReturn(Optional.of(setting));

    assertThat(service.resolve("935-CORKWOOD-B")).isEqualTo("935-CORKWOOD-B");
  }
}
