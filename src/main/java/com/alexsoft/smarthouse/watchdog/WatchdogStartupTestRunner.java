package com.alexsoft.smarthouse.watchdog;

import com.alexsoft.smarthouse.entity.WatchdogJob;
import com.alexsoft.smarthouse.repository.WatchdogJobRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class WatchdogStartupTestRunner implements CommandLineRunner {

    private final WatchdogJobRepository jobRepository;
    private final WatchdogScheduler watchdogScheduler;

    @Override
    public void run(String... args) {
        log.info("Watchdog Startup Test Runner initialized. Will trigger test execution in 15 seconds...");
        
        // Execute in a separate thread to prevent blocking main Spring Boot startup lifecycle
        new Thread(() -> {
            try {
                Thread.sleep(15000); // Wait 15 seconds for subsystems and routes to stabilize
                
                log.info("Searching for an active Watchdog job to run startup sanity test...");
                List<WatchdogJob> activeJobs = jobRepository.findByEnabledTrue();
                
                if (!activeJobs.isEmpty()) {
                    // Pick the first job (e.g. the TV LED Verification job) for the sanity test
                    WatchdogJob testJob = activeJobs.get(0);
                    log.info("Triggering autonomous Watchdog round-trip test for job: '{}'", testJob.getName());
                    watchdogScheduler.executeJob(testJob);
                    log.info("Watchdog startup test round-trip completed successfully. Check your phone and watchdog_log table!");
                } else {
                    log.warn("No active Watchdog jobs found in database. Skipping startup sanity test.");
                }
            } catch (InterruptedException e) {
                log.warn("Watchdog startup test runner was interrupted: {}", e.getMessage());
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                log.error("Watchdog startup test execution encountered an error: {}", e.getMessage(), e);
            }
        }).start();
    }
}
