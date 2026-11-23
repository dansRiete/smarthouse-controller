package com.alexsoft.smarthouse.environment;

import com.alexsoft.smarthouse.environment.internal.InfluxRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Service
@RequiredArgsConstructor
public class IndicationServiceV3 {

    private final IndicationRepositoryV3 indicationRepositoryV3;
    private final Optional<InfluxRepository> influxRepository;
    private final ConcurrentMap<String, IndicationV3> latestCache = new ConcurrentHashMap<>();
    private final ConcurrentMap<String, LocalDateTime> missUntilCache = new ConcurrentHashMap<>();

    public IndicationV3 save(IndicationV3 indication) {
        cacheLatest(indication);
        influxRepository.ifPresent(r -> r.saveAll(List.of(indication)));
        return indicationRepositoryV3.save(indication);
    }

    public void saveAll(Iterable<IndicationV3> indications) {
        for (IndicationV3 indication : indications) {
            cacheLatest(indication);
        }
        indicationRepositoryV3.saveAll(indications);
        influxRepository.ifPresent(r -> r.saveAll((List) indications));
    }

    public Optional<IndicationV3> findLatestRecent(String locationId, String measurementType, LocalDateTime sinceUtc) {
        String key = cacheKey(locationId, measurementType);
        IndicationV3 cached = latestCache.get(key);
        if (cached != null) {
            return Optional.of(cached);
        }
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime missUntil = missUntilCache.get(key);
        if (missUntil != null && now.isBefore(missUntil)) {
            return Optional.empty();
        }
        Optional<IndicationV3> fromDb = indicationRepositoryV3
                .findTopByLocationIdAndMeasurementTypeAndUtcTimeAfterOrderByUtcTimeDesc(locationId, measurementType, sinceUtc);
        if (fromDb.isPresent()) {
            cacheLatest(fromDb.get());
        } else {
            missUntilCache.put(key, now.plusSeconds(60));
        }
        return fromDb;
    }

    private void cacheLatest(IndicationV3 indication) {
        if (indication == null || indication.getLocationId() == null || indication.getMeasurementType() == null) {
            return;
        }
        String key = cacheKey(indication.getLocationId(), indication.getMeasurementType());
        missUntilCache.remove(key);
        latestCache.merge(key, indication, (existing, incoming) -> {
            if (existing.getUtcTime() == null || incoming.getUtcTime() == null) {
                return incoming;
            }
            return incoming.getUtcTime().isBefore(existing.getUtcTime()) ? existing : incoming;
        });
    }

    private static String cacheKey(String locationId, String measurementType) {
        return locationId + "|" + measurementType;
    }
}
