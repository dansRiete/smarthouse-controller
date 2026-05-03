package com.alexsoft.smarthouse.repository;

import com.alexsoft.smarthouse.entity.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface FcmTokenRepository extends JpaRepository<FcmToken, Long> {

    Optional<FcmToken> findByToken(String token);

    @Query("SELECT t.token FROM FcmToken t")
    List<String> findAllTokens();

    void deleteByToken(String token);
}
