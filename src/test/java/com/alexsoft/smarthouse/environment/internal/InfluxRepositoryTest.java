package com.alexsoft.smarthouse.environment.internal;

import com.alexsoft.smarthouse.environment.IndicationV3;
import com.influxdb.client.write.Point;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class InfluxRepositoryTest {

  @Test
  void convertToPointIncludesUnitTagWhenPresent() {
    InfluxRepository repository = new InfluxRepository(null);
    IndicationV3 indication = IndicationV3.builder()
        .locationId("pc-cpu-fan")
        .publisherId("i9-12900k")
        .mqttTopic("mqtt.smarthouse")
        .measurementType("speed")
        .unit("rpm")
        .value(920.0)
        .utcTime(LocalDateTime.of(2026, 10, 17, 19, 0, 0))
        .build();

    Point point = repository.convertToPoint(indication);
    String lineProtocol = point.toLineProtocol();

    assertThat(lineProtocol).contains("location_id=pc-cpu-fan");
    assertThat(lineProtocol).contains("unit=rpm");
    assertThat(lineProtocol).contains("speed=920.0");
  }
}
