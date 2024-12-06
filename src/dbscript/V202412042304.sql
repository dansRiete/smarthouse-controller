alter table main.indication_v2 alter column utc_time drop not null;
alter table main.indication_v2 alter column publisher_id drop not null;
alter table main.indication_v2 add aggregated_at timestamp;
alter table main.indication_v2 add created_at TIMESTAMP DEFAULT timezone('UTC', now());
alter table main.indication_v2 rename column temp_celsius to temp;
alter table main.indication_v2 rename column relative_humidity to rh;
alter table main.indication_v2 rename column pressure_mm_hg to mmhg;
alter table main.indication_v2 add ah double precision;
alter table main.indication_v2 add ah_min double precision;
alter table main.indication_v2 add ah_max double precision;
alter table main.indication_v2 add mmhg_min double precision;
alter table main.indication_v2 add mmhg_max double precision;
alter table main.indication_v2 add rh_min integer;
alter table main.indication_v2 add rh_max integer;
alter table main.indication_v2 add temp_min double precision;
alter table main.indication_v2 add temp_max double precision;
update indication_v2 set ah = ROUND(CAST(6.112 * POWER(2.71828, 17.67 * temp / (243.5 + temp)) * rh * 2.1674 / (273.15 + temp) AS NUMERIC), 1);

/*-- ROLLBACK
-- Revert column renaming
ALTER TABLE main.indication_v2 RENAME COLUMN temp TO temp_celsius;
ALTER TABLE main.indication_v2 RENAME COLUMN rh TO relative_humidity;
ALTER TABLE main.indication_v2 RENAME COLUMN mmhg TO pressure_mm_hg;

-- Drop added columns
ALTER TABLE main.indication_v2 DROP COLUMN aggregated_at;
ALTER TABLE main.indication_v2 DROP COLUMN created_at;
ALTER TABLE main.indication_v2 DROP COLUMN ah;
ALTER TABLE main.indication_v2 DROP COLUMN ah_min;
ALTER TABLE main.indication_v2 DROP COLUMN ah_max;
ALTER TABLE main.indication_v2 DROP COLUMN mmhg_min;
ALTER TABLE main.indication_v2 DROP COLUMN mmhg_max;
ALTER TABLE main.indication_v2 DROP COLUMN rh_min;
ALTER TABLE main.indication_v2 DROP COLUMN rh_max;
ALTER TABLE main.indication_v2 DROP COLUMN temp_min;
ALTER TABLE main.indication_v2 DROP COLUMN temp_max;

-- Reinstate NOT NULL constraints
ALTER TABLE main.indication_v2 ALTER COLUMN utc_time SET NOT NULL;
ALTER TABLE main.indication_v2 ALTER COLUMN publisher_id SET NOT NULL;*/
