-- Table: character_assets
CREATE TABLE IF NOT EXISTS character_assets (
    -- Primary key: uuid for the asset
    id UUID PRIMARY KEY,
    -- Foreign key: references the character that owns this asset
    character_id INT64 NOT NULL,
    -- Whether this is a blueprint copy or not
    is_blueprint_copy BOOLEAN NOT NULL,
    -- Whether this is a singleton or not
    is_singleton BOOLEAN NOT NULL,
    -- Item ID
    item_id INT64 NOT NULL,
    -- Location flag (e.g. "station", "space")
    location_flag VARCHAR(50) NOT NULL,
    -- Location ID
    location_id INT64 NOT NULL,
    -- Type of location (e.g. "station", "planet")
    location_type VARCHAR(50) NOT NULL,
    -- Quantity of the item
    quantity INT32 NOT NULL,
    -- Type ID of the item
    type_id INT32 NOT NULL,

    -- Index for efficient lookup by character ID
    CREATE INDEX IF NOT EXISTS idx_character_assets_on_character_id ON character_assets (character_id);

    COMMENT ON TABLE character_assets IS 'Represents an asset owned by a character';
    COMMENT ON COLUMN character_assets.character_id IS 'Foreign key referencing the character that owns this asset';
) WITH (oids = false);

-- Table: corporate_assets
CREATE TABLE IF NOT EXISTS corporate_assets (
    -- Primary key: uuid for the asset
    id UUID PRIMARY KEY,
    -- Foreign key: references the corporation that owns this asset
    corporation_id INT64 NOT NULL,
    -- Whether this is a blueprint copy or not
    is_blueprint_copy BOOLEAN NOT NULL,
    -- Whether this is a singleton or not
    is_singleton BOOLEAN NOT NULL,
    -- Item ID
    item_id INT64 NOT NULL,
    -- Location flag (e.g. "station", "space")
    location_flag VARCHAR(50) NOT NULL,
    -- Location ID
    location_id INT64 NOT NULL,
    -- Type of location (e.g. "station", "planet")
    location_type VARCHAR(50) NOT NULL,
    -- Quantity of the item
    quantity INT32 NOT NULL,
    -- Type ID of the item
    type_id INT32 NOT NULL,

    -- Index for efficient lookup by corporation ID
    CREATE INDEX IF NOT EXISTS idx_corporate_assets_on_corporation_id ON corporate_assets (corporation_id);

    COMMENT ON TABLE corporate_assets IS 'Represents an asset owned by a corporation';
    COMMENT ON COLUMN corporate_assets.corporation_id IS 'Foreign key referencing the corporation that owns this asset';
) WITH (oids = false);