CREATE TABLE IF NOT EXISTS character_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id INT64 NOT NULL,
    is_blueprint_copy BOOLEAN NOT NULL,
    is_singleton BOOLEAN NOT NULL,
    item_id INT64 NOT NULL,
    location_flag VARCHAR(255) NOT NULL,
    location_id INT64 NOT NULL,
    location_type VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    CONSTRAINT fk_character_id FOREIGN KEY (character_id) REFERENCES characters(id)
);

CREATE INDEX IF NOT EXISTS idx_character_id ON character_assets(character_id);

CREATE TABLE IF NOT EXISTS corporate_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporation_id INT64 NOT NULL,
    is_blueprint_copy BOOLEAN NOT NULL,
    is_singleton BOOLEAN NOT NULL,
    item_id INT64 NOT NULL,
    location_flag VARCHAR(255) NOT NULL,
    location_id INT64 NOT NULL,
    location_type VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    CONSTRAINT fk_corporation_id FOREIGN KEY (corporation_id) REFERENCES corporations(id)
);

CREATE INDEX IF NOT EXISTS idx_corporation_id ON corporate_assets(corporation_id);

-- SQL comment explaining the use of UUIDs
-- Using a UUID as the primary key ensures unique IDs for each asset, making it easier to identify and manage them.
-- The uuid_generate_v4() function generates a random UUID.

-- SQL comment explaining the NOT NULL constraint
-- Requiring that every field is NOT NULL ensures that there are no null values in the table, which can cause issues when querying or joining data.