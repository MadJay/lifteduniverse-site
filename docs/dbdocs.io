Table "accounts" {
  "id" varchar
  "created_at" datetime
  "updated_at" datetime
}

Table "asset_category_fields" {
  "id" varchar
  "category_field_id" integer
  "cms_asset_id" integer
  "created_at" datetime
  "updated_at" datetime
}

Table "categories" {
  "id" varchar
  "title" string
  "description" string
  "created_at" datetime
  "updated_at" datetime
}

Table "category_fields" {
  "id" varchar
  "category_id" integer
  "created_at" datetime
  "updated_at" datetime
}

Table "cms_assets" {
  "id" varchar
  "name" string
  "description" text
  "account_id" integer
  "category_id" integer
  "status_id" integer
  "is_published" boolean
  "vod_streams_uid" string
  "recording_uid" string
  "transcoder_uid" string
  "state" string
  "uid" string
  "created_at" datetime
  "updated_at" datetime
}

Table "playlist_assets" {
  "id" varchar
  "playlist_id" integer
  "cms_asset_id" integer
  "order" integer
  "created_at" datetime
  "updated_at" datetime
}

Table "playlists" {
  "id" varchar
  "title" string
  "user_id" integer
  "created_at" datetime
  "updated_at" datetime
}

Table "profiles" {
  "id" varchar
  "uid" string
  "account_id" integer
  "created_at" datetime
  "updated_at" datetime
}

Ref "fk_rails_asset_category_fields_category_fields":"asset_category_fields"."category_field_id" - "category_fields"."id"

Ref "fk_rails_asset_category_fields_cms_assets":"asset_category_fields"."cms_asset_id" > "cms_assets"."id"

Ref "fk_rails_category_fields_categories":"category_fields"."category_id" > "categories"."id"

Ref "fk_rails_cms_assets_accounts":"cms_assets"."account_id" > "accounts"."id"

Ref "fk_rails_cms_assets_categories":"cms_assets"."category_id" - "categories"."id"

Ref "fk_rails_playlist_assets_playlists":"playlist_assets"."playlist_id" > "playlists"."id"

Ref "fk_rails_playlist_assets_cms_assets":"playlist_assets"."cms_asset_id" > "cms_assets"."id"

Ref "fk_rails_profiles_accounts":"profiles"."account_id" > "accounts"."id"
