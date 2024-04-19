-- Table for Character Assets
CREATE TABLE IF NOT EXISTS character_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Generated UUID for primary key
    character_id int64 NOT NULL, -- Character ID associated with the asset
    is_blueprint_copy bool NOT NULL,
    is_singleton bool NOT NULL,
    item_id int64 NOT NULL,
    location_flag text NOT NULL,
    location_id int64 NOT NULL,
    location_type text NOT NULL,
    quantity int32 NOT NULL,
    type_id int32 NOT NULL
);

-- Index on character_id for quick access to character's assets
CREATE INDEX IF NOT EXISTS idx_character_assets_character_id ON character_assets (character_id);

-- Additional index for item_id for efficient lookups by item ID
CREATE INDEX IF NOT EXISTS idx_character_assets_item_id ON character_assets (item_id);

-- Table for Corporate Assets
CREATE TABLE IF NOT EXISTS corporate_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Generated UUID for primary key
    corporation_id int64 NOT NULL, -- Corporation ID associated with the asset
    is_blueprint_copy bool NOT NULL,
    is_singleton bool NOT NULL,
    item_id int64 NOT NULL,
    location_flag text NOT NULL,
    location_id int64 NOT NULL,
    location_type text NOT NULL,
    quantity int32 NOT NULL,
    type_id int32 NOT NULL
);

-- Index on corporation_id for quick access to corporate assets
CREATE INDEX IF NOT EXISTS idx_corporate_assets_corporation_id ON corporate_assets (corporation_id);

-- Additional index for location_id for efficient lookups by location ID
CREATE INDEX IF NOT EXISTS idx_corporate_assets_location_id ON corporate_assets (location_id);