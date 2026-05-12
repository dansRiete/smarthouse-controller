package com.alexsoft.smarthouse.controller;

import com.alexsoft.smarthouse.entity.IndicationV3;
import com.alexsoft.smarthouse.repository.IndicationRepositoryV3;
import com.alexsoft.smarthouse.repository.InfluxRepository;
import com.alexsoft.smarthouse.service.IndicationServiceV3;
import com.alexsoft.smarthouse.utils.DateUtils;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

import static com.alexsoft.smarthouse.utils.DateUtils.toLocalDateTime;
import static com.alexsoft.smarthouse.utils.DateUtils.toUtc;

@RestController
@RequestMapping("/indications")
@AllArgsConstructor
public class IndicationsController {

  private final InfluxRepository influxRepository;
  private final IndicationServiceV3 indicationServiceV3;
  private final IndicationRepositoryV3 indicationRepositoryV3;

  @PostMapping
  public ResponseEntity<String> createIndication(@RequestBody IndicationV3 indication) {
    indicationServiceV3.saveAll(createMbsIndication(indication));
    return ResponseEntity.ok(indicationServiceV3.getMbsStatus());
  }

  @PostMapping("/mbs/reprocess")
  public ResponseEntity<String> reprocessMbs() {

    ClassLoader classLoader = getClass().getClassLoader();
    try (InputStream inputStream = classLoader.getResourceAsStream("init_mbs.csv");
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
      DateTimeFormatter twoDigitYearFormatter = DateTimeFormatter.ofPattern("dd/MM/yy");
      DateTimeFormatter fourDigitYearFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

      reader.lines()
          .skip(1)
          .forEach(line -> {
            String[] columns = line.split(",");
            String dateStr = columns[0];
            if (!dateStr.isBlank()) {
              LocalDateTime localTime = null;
              try {
                localTime = LocalDate.parse(dateStr, fourDigitYearFormatter).atStartOfDay();
              } catch (DateTimeParseException e) {
                localTime = LocalDate.parse(dateStr, twoDigitYearFormatter).atStartOfDay();
              }

              String[] measurementTypes = {"milato", "bellion", "suitan", "whelmet", "batrumt"};
              for (int i = 2; i < columns.length; i++) {
                if (!columns[i].isBlank()) {
                  double value = Double.parseDouble(columns[i]);
                  String measurementType = measurementTypes[i - 2];
                  IndicationV3 indication = IndicationV3.builder()
                      .locationId("mbs")
                      .localTime(localTime)
                      .utcTime(toUtc(localTime))
                      .measurementType(measurementType)
                      .value(value)
                      .build();
                  indicationServiceV3.saveAll(createMbsIndication(indication));
                }
              }
            }
          });

      return ResponseEntity.ok("CSV data successfully parsed and inserted.");
    } catch (IOException e) {
      e.printStackTrace();
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body("Error reading or parsing CSV file.");
    }
  }

  @PostMapping("/influx-sync")
  public ResponseEntity<String> filterByDate(@RequestParam(required = false) LocalDateTime startDate, @RequestParam(required = false) LocalDateTime endDate) {
    influxRepository.syncAllFromPostgresBy1Days(startDate, endDate);
    return null;
  }

  private List<IndicationV3> createMbsIndication(IndicationV3 indication) {
    indicationRepositoryV3.save(indication);
    String measurementType = indication.getMeasurementType();
    LocalDateTime localTime = indication.getLocalTime();
    LocalDateTime utc = indication.getUtcTime();
    if (indication.getUtcTime() == null && localTime != null) {
      indication.setUtcTime(toUtc(localTime));
    }
    if (localTime == null && indication.getUtcTime() != null) {
      indication.setLocalTime(toLocalDateTime(indication.getUtcTime()));
    }
    if (indication.getUtcTime() == null) {
      indication.setUtcTime(utc);
    }
    if (localTime == null) {
      indication.setLocalTime(toLocalDateTime(utc));
    }
    IndicationV3 mbs30d = IndicationV3.builder().locationId("mbs").localTime(localTime).utcTime(utc).measurementType(measurementType + "-30d")
        .value(indicationRepositoryV3.findByLocalTimeBetweenAndMeasurementType(localTime.minusMonths(1).plusSeconds(1), localTime.plusSeconds(1), measurementType).stream().mapToDouble(IndicationV3::getValue).sum()).build();
    IndicationV3 mbs1d = IndicationV3.builder().locationId("mbs").localTime(localTime).utcTime(utc).measurementType(measurementType + "-1d")
        .value(indicationRepositoryV3.findByLocalTimeBetweenAndMeasurementType(localTime.minusDays(1).plusSeconds(1), localTime.plusSeconds(1), measurementType).stream().mapToDouble(IndicationV3::getValue).sum()).build();
    return List.of(indication, mbs30d, mbs1d);
  }
}
