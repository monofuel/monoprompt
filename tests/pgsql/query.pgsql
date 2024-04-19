SELECT * 
FROM (
    SELECT 
        'character' AS entity_type,
        character_id AS entity_id,
        asset_id,
        is_blueprint_copy,
        is_singleton,
        item_id,
        location_flag,
        location_id,
        location_type,
        quantity,
        type_id
    FROM character_assets
    WHERE location_id = ?
    
    UNION ALL
    
    SELECT 
        'corporation' AS entity_type,
        corporation_id AS entity_id,
        asset_id,
        is_blueprint_copy,
        is_singleton,
        item_id,
        location_flag,
        location_id,
        location_type,
        quantity,
        type_id
    FROM corporate_assets
    WHERE location_id = ?
) AS all_assets;