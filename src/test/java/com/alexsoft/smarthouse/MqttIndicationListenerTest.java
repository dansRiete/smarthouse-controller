package com.alexsoft.smarthouse;

import com.alexsoft.smarthouse.environment.IndicationServiceV3;
import com.alexsoft.smarthouse.environment.IndicationV3;
import com.alexsoft.smarthouse.environment.listener.MqttIndicationListener;
import com.alexsoft.smarthouse.mqtt.MqttMessageReceivedEvent;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class MqttIndicationListenerTest {

  @Mock
  private IndicationServiceV3 indicationServiceV3;

  @InjectMocks
  private MqttIndicationListener listener;

  @Captor
  private ArgumentCaptor<List<IndicationV3>> indicationsCaptor;

  @Test
  void handleMqttMessageSavesTempAndCo2Indications() {
    String payload = """
        {
          "publisherId": "ESP32-A8:46:74:45:F4:6C",
          "measurePlace": "LIVING-ROOM",
          "inOut": "IN",
          "air": {
            "temp": { "celsius": 25.21, "rh": 53.93, "ah": 12.60 },
            "co2": { "ppm": 1500 }
          }
        }
        """;
    MqttMessageReceivedEvent event = new MqttMessageReceivedEvent(this, "mqtt.smarthouse", payload);

    listener.handleMqttMessage(event);

    verify(indicationServiceV3).saveAll(indicationsCaptor.capture());
    List<IndicationV3> saved = indicationsCaptor.getValue();

    assertThat(saved)
        .hasSize(4)
        .allSatisfy(indication -> {
          assertThat(indication.getLocationId()).isEqualTo("LIVING-ROOM");
          assertThat(indication.getPublisherId()).isEqualTo("ESP32-A8:46:74:45:F4:6C");
          assertThat(indication.getMqttTopic()).isEqualTo("mqtt.smarthouse");
          assertThat(indication.getLocalTime()).isNotNull();
          assertThat(indication.getUtcTime()).isNotNull();
        })
        .extracting(IndicationV3::getMeasurementType, IndicationV3::getUnit, IndicationV3::getValue)
        .containsExactly(
            tuple("temp", "c", 25.21),
            tuple("rh", "%", 53.93),
            tuple("ah", "g/m3", 12.60),
            tuple("co2", "ppm", 1500.0)
        );
  }
}
