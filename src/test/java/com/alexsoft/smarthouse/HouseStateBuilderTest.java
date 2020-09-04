package com.alexsoft.smarthouse;

import java.util.List;

import com.alexsoft.smarthouse.db.entity.Aqi;
import com.alexsoft.smarthouse.db.entity.HouseState;
import com.alexsoft.smarthouse.db.entity.Temp;
import org.junit.Test;

import static com.alexsoft.smarthouse.db.entity.MeasurePlace.LIVING_ROOM;
import static com.alexsoft.smarthouse.db.entity.MeasurePlace.TERRACE;
import static com.alexsoft.smarthouse.db.entity.MeasurePlace.TERRACE_WINDOW;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class HouseStateBuilderTest {

    @Test
    public void HouseStateBuildingWithSettingParentsTest() {
        HouseState houseState = HouseState.builder()
            .temperatures(List.of(
                Temp.builder().measurePlace(LIVING_ROOM).temperature(0.0).rh(0.0).ah(0.0).build(),
                Temp.builder().measurePlace(TERRACE).temperature(0.0).rh(0.0).ah(0.0).build(),
                Temp.builder().measurePlace(TERRACE_WINDOW).temperature(0.0).rh(0.0).ah(0.0).build()
            ))
            .aqis(List.of(
                Aqi.builder().measurePlace(TERRACE).pm10(0.0).pm25(0.0).build()
            ))
            .build();
        houseState.getAqis().forEach(aqi -> assertEquals(aqi.getHouseState(), houseState));
        houseState.getTemperatures().forEach(temp -> assertEquals(temp.getHouseState(), houseState));

    }


}
