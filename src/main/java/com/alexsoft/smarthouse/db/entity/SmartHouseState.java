package com.alexsoft.smarthouse.db.entity;


import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import lombok.ToString;

@Entity
@Table(schema = "main")
public class SmartHouseState {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "smart_house_state_sq")
    @SequenceGenerator(schema = "main", sequenceName = "smart_house_state_sq", name = "smart_house_state_sq", allocationSize = 1)
    @ToString.Include
    private Integer id;

    private double pm25;

    private double pm10;


}
