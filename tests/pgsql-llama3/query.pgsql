SELECT 
    ca.id,
    ca.character_id,
    ca.is_blueprint_copy,
    ca.is_singleton,
    ca.item_id,
    ca.location_flag,
    ca.location_id,
    ca.location_type,
    ca.quantity,
    ca.type_id
FROM 
    character_assets ca
WHERE 
    ca.location_id = ?
UNION ALL
SELECT 
    ca.id,
    ca.corporation_id,
    ca.is_blueprint_copy,
    ca.is_singleton,
    ca.item_id,
    ca.location_flag,
    ca.location_id,
    ca.location_type,
    ca.quantity,
    ca.type_id
FROM 
    corporate_assets ca
WHERE 
    ca.location_id = ?