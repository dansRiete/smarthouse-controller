package com.alexsoft.smarthouse.repository;

import com.alexsoft.smarthouse.entity.WatchdogLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WatchdogLogRepository extends JpaRepository<WatchdogLog, Long> {
}
