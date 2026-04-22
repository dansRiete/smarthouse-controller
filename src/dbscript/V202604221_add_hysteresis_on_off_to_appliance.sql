ALTER TABLE main.appliance
    ADD COLUMN hysteresis_on  DOUBLE PRECISION,
    ADD COLUMN hysteresis_off DOUBLE PRECISION;

UPDATE main.appliance
SET hysteresis_on  = hysteresis,
    hysteresis_off = hysteresis + CASE WHEN code = 'AC' THEN 0.5 ELSE 0 END;

ALTER TABLE main.appliance
    DROP COLUMN hysteresis;
