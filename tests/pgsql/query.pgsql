SELECT *
FROM character_assets
WHERE location_id = ? 
AND location_type = 'region'

UNION ALL

SELECT *
FROM corporate_assets
WHERE location_id = ? 
AND location_type = 'region';