CREATE TABLE IF NOT EXISTS character_assets (
    id SERIAL PRIMARY KEY,
    -- Character ID for the asset owner
    character_id INT64 NOT NULL,
    -- Unique identifier of the asset in-game
    item_id INT64 NOT NULL,
    -- Type of asset (e.g. blueprint, ship, etc.)
    type_id INT32 NOT NULL,
    -- Quantity of the asset
    quantity INT32 NOT NULL,
    -- Location where the asset is stored (e.g. cargo hold, hangar, etc.)
    location_type VARCHAR(50) NOT NULL,
    -- Flag indicating whether this is a blueprint copy or not
    is_blueprint_copy BOOLEAN NOT NULL,
    -- Singleton flag, indicates if this asset is unique in-game
    is_singleton BOOLEAN NOT NULL,
    -- Timestamp when the asset was last updated
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CREATE INDEX IF NOT EXISTS character_id_idx ON character_assets (character_id);
    CREATE INDEX IF NOT EXISTS item_id_idx ON character_assets (item_id);
);

CREATE TABLE IF NOT EXISTS corporate_assets (
    id SERIAL PRIMARY KEY,
    -- Corporation ID for the asset owner
    corporation_id INT64 NOT NULL,
    -- Unique identifier of the asset in-game
    item_id INT64 NOT NULL,
    -- Type of asset (e.g. blueprint, ship, etc.)
    type_id INT32 NOT NULL,
    -- Quantity of the asset
    quantity INT32 NOT NULL,
    -- Location where the asset is stored (e.g. cargo hold, hangar, etc.)
    location_type VARCHAR(50) NOT NULL,
    -- Flag indicating whether this is a blueprint copy or not
    is_blueprint_copy BOOLEAN NOT NULL,
    -- Singleton flag, indicates if this asset is unique in-game
    is_singleton BOOLEAN NOT NULL,
    -- Timestamp when the asset was last updated
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CREATE INDEX IF NOT EXISTS corporation_id_idx ON corporate_assets (corporation_id);
    CREATE INDEX IF NOT EXISTS item_id_idx ON corporate_assets (item_id);
);

-- Indexes to speed up queries by type and location
CREATE INDEX IF NOT EXISTS character_type_idx ON character_assets (type_id, location_type);
CREATE INDEX IF NOT EXISTS corporation_type_idx ON corporate_assets (type_id, location_type);