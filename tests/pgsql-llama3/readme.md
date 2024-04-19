# Character and Corporate Assets Database

## Table of Contents

* [Overview](#overview)
* [Tables](#tables)
	+ [Character Assets](#character-assets)
	+ [Corporate Assets](#corporate-assets)
* [Indexing](#indexing)
* [Usage Notes](#usage-notes)

## Overview
The `character_assets` and `corporate_assets` tables are designed to store information about assets owned by characters or corporations in a virtual economy. Each row represents an asset, with columns for the asset's ID, location, quantity, and type.

## Tables

### Character Assets
```sql
CREATE TABLE IF NOT EXISTS character_assets (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    character_id int64 NOT NULL,
    is_blueprint_copy bool NOT NULL,
    is_singleton bool NOT NULL,
    item_id int64 NOT NULL,
    location_flag text NOT NULL,
    location_id int64 NOT NULL,
    location_type text NOT NULL,
    quantity int32 NOT NULL,
    type_id int32 NOT NULL
);
```

### Corporate Assets
```sql
CREATE TABLE IF NOT EXISTS corporate_assets (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporation_id int64 NOT NULL,
    is_blueprint_copy bool NOT NULL,
    is_singleton bool NOT NULL,
    item_id int64 NOT NULL,
    location_flag text NOT NULL,
    location_id int64 NOT NULL,
    location_type text NOT NULL,
    quantity int32 NOT NULL,
    type_id int32 NOT NULL
);
```

## Indexing

The `idx_character_id` and `idx_corporation_id` indexes are created on the `character_assets` and `corporate_assets` tables, respectively, to facilitate fast lookups by character or corporation ID.

Additionally, the `idx_character_item` and `idx_corporation_item` unique indexes ensure that each character or corporation can only have one instance of a given asset.

## Usage Notes

* The `uuid_generate_v4()` function is used to generate a unique UUID for each row in both tables.
* The `item_id` column stores the actual asset ID, which may change over time.
* The `location_flag`, `location_id`, and `location_type` columns store additional information about the asset's location.
* The unique indexes ensure that each character or corporation can only have one instance of a given asset.