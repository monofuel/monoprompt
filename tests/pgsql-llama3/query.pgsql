SELECT 
  COALESCE((CASE WHEN ca.character_id IS NOT NULL THEN 'Character' ELSE 'Corporation' END), '?') AS "Type",
  COALESCE(ca.character_id, ca.corporation_id) AS "ID",
  ca.item_id AS "Item ID",
  ca.location_flag AS "Location Flag",
  ca.location_id AS "Location ID",
  ca.location_type AS "Location Type",
  ca.quantity AS "Quantity",
  ca.type_id AS "Type ID"
FROM 
  character_assets ca
UNION ALL
SELECT 
  'Corporation' AS "Type",
  ca.corporation_id AS "ID",
  ca.item_id AS "Item ID",
  ca.location_flag AS "Location Flag",
  ca.location_id AS "Location ID",
  ca.location_type AS "Location Type",
  ca.quantity AS "Quantity",
  ca.type_id AS "Type ID"
FROM 
  corporate_assets ca
WHERE 
  ca.location_flag = ? AND 
  ca.location_id = ?;