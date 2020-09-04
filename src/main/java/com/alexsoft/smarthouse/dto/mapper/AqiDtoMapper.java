package com.alexsoft.smarthouse.dto.mapper;

import com.alexsoft.smarthouse.db.entity.Aqi;
import com.alexsoft.smarthouse.dto.AqiDto;
import org.mapstruct.Mapper;

@Mapper
public interface AqiDtoMapper {
    AqiDto toDto(Aqi aqi);
}
