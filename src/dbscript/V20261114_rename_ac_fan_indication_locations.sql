UPDATE main.indication_v3
SET location_id = 'AC'
WHERE location_id = '935-CORKWOOD-AC'
  AND measurement_type = 'state';

UPDATE main.indication_v3
SET location_id = 'FAN'
WHERE location_id = '935-CORKWOOD-FAN'
  AND measurement_type = 'state';
