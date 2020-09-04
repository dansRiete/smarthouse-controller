package com.alexsoft.smarthouse.dto.mapper;

import com.alexsoft.smarthouse.db.entity.Temp;
import com.alexsoft.smarthouse.dto.TempDto;
import org.mapstruct.Mapper;

@Mapper
public interface TempDtoMapper {
    TempDto toDto(Temp temp);
}
