package com.alexsoft.smarthouse.repository;

import com.alexsoft.smarthouse.entity.WatchdogJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WatchdogJobRepository extends JpaRepository<WatchdogJob, Long> {
    List<WatchdogJob> findByEnabledTrue();
}
