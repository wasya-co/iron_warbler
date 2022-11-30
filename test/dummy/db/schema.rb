# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_22_233715) do

  create_table "active_admin_comments", charset: "latin1", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "iwa_option_price_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "putCall"
    t.string "symbol"
    t.string "description"
    t.string "exchangeName"
    t.string "bidAskSize"
    t.string "expirationType"
    t.float "bid"
    t.float "ask"
    t.float "last"
    t.float "mark"
    t.float "lastPrice"
    t.float "highPrice"
    t.float "lowPrice"
    t.float "openPrice"
    t.float "closePrice"
    t.float "netChange"
    t.float "volatility"
    t.float "delta"
    t.float "gamma"
    t.float "theta"
    t.float "vega"
    t.float "rho"
    t.float "timeValue"
    t.float "theoreticalOptionValue"
    t.float "theoreticalVolatility"
    t.float "strikePrice"
    t.float "percentChange"
    t.float "markChange"
    t.float "markPercentChange"
    t.float "intrinsicValue"
    t.float "multiplier"
    t.integer "bidSize"
    t.integer "askSize"
    t.bigint "totalVolume"
    t.integer "openInterest"
    t.integer "daysToExpiration"
    t.bigint "tradeTimeInLong"
    t.bigint "quoteTimeInLong"
    t.bigint "expirationDate"
    t.bigint "lastTradingDay"
    t.boolean "inTheMoney"
    t.boolean "nonStandard"
    t.boolean "isIndexOption"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.timestamp "timestamp"
    t.date "tradeDate"
    t.string "interval"
  end

  create_table "iwa_option_watches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "ticker"
    t.string "symbol"
    t.string "description"
    t.float "strike"
    t.string "contractType"
    t.date "date"
    t.string "direction"
    t.string "notificationType"
    t.string "email"
    t.string "phone"
    t.string "profile_id"
  end

  create_table "m3_email_campaign_leads", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.string "email_campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "rendered_str"
    t.timestamp "sent_at"
  end

  create_table "m3_leads", charset: "latin1", force: :cascade do |t|
    t.string "email"
    t.string "comment"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "m3_leadset_id"
    t.string "tag"
    t.string "name"
    t.string "full_name"
    t.index ["m3_leadset_id"], name: "index_m3_leads_on_m3_leadset_id"
  end

  create_table "m3_leadsets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "company_url"
    t.string "extra_url"
    t.string "comment"
    t.string "location"
    t.string "tag"
  end

  create_table "m3_users", charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_m3_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_m3_users_on_reset_password_token", unique: true
  end

  create_table "wp_actionscheduler_actions", primary_key: "action_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "hook", limit: 191, null: false
    t.string "status", limit: 20, null: false
    t.datetime "scheduled_date_gmt"
    t.datetime "scheduled_date_local"
    t.string "args", limit: 191
    t.text "schedule", size: :long
    t.bigint "group_id", default: 0, null: false, unsigned: true
    t.integer "attempts", default: 0, null: false
    t.datetime "last_attempt_gmt"
    t.datetime "last_attempt_local"
    t.bigint "claim_id", default: 0, null: false, unsigned: true
    t.string "extended_args", limit: 8000
    t.index ["args"], name: "args"
    t.index ["claim_id", "status", "scheduled_date_gmt"], name: "claim_id_status_scheduled_date_gmt"
    t.index ["group_id"], name: "group_id"
    t.index ["hook"], name: "hook"
    t.index ["last_attempt_gmt"], name: "last_attempt_gmt"
    t.index ["scheduled_date_gmt"], name: "scheduled_date_gmt"
    t.index ["status"], name: "status"
  end

  create_table "wp_actionscheduler_claims", primary_key: "claim_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "date_created_gmt"
    t.index ["date_created_gmt"], name: "date_created_gmt"
  end

  create_table "wp_actionscheduler_groups", primary_key: "group_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.index ["slug"], name: "slug", length: 191
  end

  create_table "wp_actionscheduler_logs", primary_key: "log_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "action_id", null: false, unsigned: true
    t.text "message", null: false
    t.datetime "log_date_gmt"
    t.datetime "log_date_local"
    t.index ["action_id"], name: "action_id"
    t.index ["log_date_gmt"], name: "log_date_gmt"
  end

  create_table "wp_as3cf_items", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "provider", limit: 18, null: false
    t.string "region", null: false
    t.string "bucket", null: false
    t.string "path", limit: 1024, null: false
    t.string "original_path", limit: 1024, null: false
    t.boolean "is_private", default: false, null: false
    t.string "source_type", limit: 18, null: false
    t.bigint "source_id", null: false, unsigned: true
    t.string "source_path", limit: 1024, null: false
    t.string "original_source_path", limit: 1024, null: false
    t.text "extra_info", size: :long
    t.integer "originator", limit: 1, default: 0, null: false, unsigned: true
    t.boolean "is_verified", default: true, null: false
    t.index ["is_verified", "originator", "id"], name: "uidx_is_verified_originator", unique: true
    t.index ["original_path", "id"], name: "uidx_original_path", unique: true, length: { original_path: 190 }
    t.index ["original_source_path", "id"], name: "uidx_original_source_path", unique: true, length: { original_source_path: 190 }
    t.index ["path", "id"], name: "uidx_path", unique: true, length: { path: 190 }
    t.index ["provider", "bucket", "id"], name: "uidx_provider_bucket", unique: true, length: { bucket: 190 }
    t.index ["source_path", "id"], name: "uidx_source_path", unique: true, length: { source_path: 190 }
    t.index ["source_type", "source_id"], name: "uidx_source", unique: true
  end

  create_table "wp_commentmeta", primary_key: "meta_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "comment_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", size: :long
    t.index ["comment_id"], name: "comment_id"
    t.index ["meta_key"], name: "meta_key", length: 191
  end

  create_table "wp_comments", primary_key: "comment_ID", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "comment_post_ID", default: 0, null: false, unsigned: true
    t.text "comment_author", size: :tiny, null: false
    t.string "comment_author_email", limit: 100, default: "", null: false
    t.string "comment_author_url", limit: 200, default: "", null: false
    t.string "comment_author_IP", limit: 100, default: "", null: false
    t.datetime "comment_date", null: false
    t.datetime "comment_date_gmt", null: false
    t.text "comment_content", null: false
    t.integer "comment_karma", default: 0, null: false
    t.string "comment_approved", limit: 20, default: "1", null: false
    t.string "comment_agent", default: "", null: false
    t.string "comment_type", limit: 20, default: "comment", null: false
    t.bigint "comment_parent", default: 0, null: false, unsigned: true
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.index ["comment_approved", "comment_date_gmt"], name: "comment_approved_date_gmt"
    t.index ["comment_author_email"], name: "comment_author_email", length: 10
    t.index ["comment_date_gmt"], name: "comment_date_gmt"
    t.index ["comment_parent"], name: "comment_parent"
    t.index ["comment_post_ID"], name: "comment_post_ID"
  end

  create_table "wp_e_events", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.text "event_data"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "created_at_index"
  end

  create_table "wp_links", primary_key: "link_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "link_url", default: "", null: false
    t.string "link_name", default: "", null: false
    t.string "link_image", default: "", null: false
    t.string "link_target", limit: 25, default: "", null: false
    t.string "link_description", default: "", null: false
    t.string "link_visible", limit: 20, default: "Y", null: false
    t.bigint "link_owner", default: 1, null: false, unsigned: true
    t.integer "link_rating", default: 0, null: false
    t.datetime "link_updated", null: false
    t.string "link_rel", default: "", null: false
    t.text "link_notes", size: :medium, null: false
    t.string "link_rss", default: "", null: false
    t.index ["link_visible"], name: "link_visible"
  end

  create_table "wp_options", primary_key: "option_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "option_name", limit: 191, default: "", null: false
    t.text "option_value", size: :long, null: false
    t.string "autoload", limit: 20, default: "yes", null: false
    t.index ["autoload"], name: "autoload"
    t.index ["option_name"], name: "option_name", unique: true
  end

  create_table "wp_postmeta", primary_key: "meta_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "post_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", size: :long
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["post_id"], name: "post_id"
  end

  create_table "wp_posts", primary_key: "ID", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "post_author", default: 0, null: false, unsigned: true
    t.datetime "post_date", null: false
    t.datetime "post_date_gmt", null: false
    t.text "post_content", size: :long, null: false
    t.text "post_title", null: false
    t.text "post_excerpt", null: false
    t.string "post_status", limit: 20, default: "publish", null: false
    t.string "comment_status", limit: 20, default: "open", null: false
    t.string "ping_status", limit: 20, default: "open", null: false
    t.string "post_password", default: "", null: false
    t.string "post_name", limit: 200, default: "", null: false
    t.text "to_ping", null: false
    t.text "pinged", null: false
    t.datetime "post_modified", null: false
    t.datetime "post_modified_gmt", null: false
    t.text "post_content_filtered", size: :long, null: false
    t.bigint "post_parent", default: 0, null: false, unsigned: true
    t.string "guid", default: "", null: false
    t.integer "menu_order", default: 0, null: false
    t.string "post_type", limit: 20, default: "post", null: false
    t.string "post_mime_type", limit: 100, default: "", null: false
    t.bigint "comment_count", default: 0, null: false
    t.index ["post_author"], name: "post_author"
    t.index ["post_name"], name: "post_name", length: 191
    t.index ["post_parent"], name: "post_parent"
    t.index ["post_type", "post_status", "post_date", "ID"], name: "type_status_date"
  end

  create_table "wp_redirection_404", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "created", null: false
    t.text "url", size: :medium, null: false
    t.string "domain"
    t.string "agent"
    t.string "referrer"
    t.integer "http_code", default: 0, null: false, unsigned: true
    t.string "request_method", limit: 10
    t.text "request_data", size: :medium
    t.string "ip", limit: 45
    t.index ["created"], name: "created"
    t.index ["ip"], name: "ip"
    t.index ["referrer"], name: "referrer", length: 191
  end

  create_table "wp_redirection_groups", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.integer "tracking", default: 1, null: false
    t.integer "module_id", default: 0, null: false, unsigned: true
    t.column "status", "enum('enabled','disabled')", default: "enabled", null: false
    t.integer "position", default: 0, null: false, unsigned: true
    t.index ["module_id"], name: "module_id"
    t.index ["status"], name: "status"
  end

  create_table "wp_redirection_items", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.text "url", size: :medium, null: false
    t.string "match_url", limit: 2000
    t.text "match_data"
    t.integer "regex", default: 0, null: false, unsigned: true
    t.integer "position", default: 0, null: false, unsigned: true
    t.integer "last_count", default: 0, null: false, unsigned: true
    t.datetime "last_access", default: "1970-01-01 00:00:00", null: false
    t.integer "group_id", default: 0, null: false
    t.column "status", "enum('enabled','disabled')", default: "enabled", null: false
    t.string "action_type", limit: 20, null: false
    t.integer "action_code", null: false, unsigned: true
    t.text "action_data", size: :medium
    t.string "match_type", limit: 20, null: false
    t.text "title"
    t.index ["group_id", "position"], name: "group_idpos"
    t.index ["group_id"], name: "group"
    t.index ["match_url"], name: "match_url", length: 191
    t.index ["regex"], name: "regex"
    t.index ["status"], name: "status"
    t.index ["url"], name: "url", length: 191
  end

  create_table "wp_redirection_logs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "created", null: false
    t.text "url", size: :medium, null: false
    t.string "domain"
    t.text "sent_to", size: :medium
    t.text "agent", size: :medium
    t.text "referrer", size: :medium
    t.integer "http_code", default: 0, null: false, unsigned: true
    t.string "request_method", limit: 10
    t.text "request_data", size: :medium
    t.string "redirect_by", limit: 50
    t.integer "redirection_id", unsigned: true
    t.string "ip", limit: 45
    t.index ["created"], name: "created"
    t.index ["ip"], name: "ip"
    t.index ["redirection_id"], name: "redirection_id"
  end

  create_table "wp_simply_static_pages", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "found_on_id", unsigned: true
    t.string "url", null: false
    t.text "redirect_url"
    t.string "file_path"
    t.integer "http_status_code", limit: 2
    t.string "content_type"
    t.binary "content_hash", limit: 20
    t.string "error_message"
    t.string "status_message"
    t.datetime "last_checked_at", null: false
    t.datetime "last_modified_at", null: false
    t.datetime "last_transferred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_checked_at"], name: "last_checked_at"
    t.index ["last_modified_at"], name: "last_modified_at"
    t.index ["last_transferred_at"], name: "last_transferred_at"
    t.index ["url"], name: "url"
  end

  create_table "wp_term_relationships", primary_key: ["object_id", "term_taxonomy_id"], charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "object_id", default: 0, null: false, unsigned: true
    t.bigint "term_taxonomy_id", default: 0, null: false, unsigned: true
    t.integer "term_order", default: 0, null: false
    t.index ["term_taxonomy_id"], name: "term_taxonomy_id"
  end

  create_table "wp_term_taxonomy", primary_key: "term_taxonomy_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "term_id", default: 0, null: false, unsigned: true
    t.string "taxonomy", limit: 32, default: "", null: false
    t.text "description", size: :long, null: false
    t.bigint "parent", default: 0, null: false, unsigned: true
    t.bigint "count", default: 0, null: false
    t.index ["taxonomy"], name: "taxonomy"
    t.index ["term_id", "taxonomy"], name: "term_id_taxonomy", unique: true
  end

  create_table "wp_termmeta", primary_key: "meta_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "term_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", size: :long
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["term_id"], name: "term_id"
  end

  create_table "wp_terms", primary_key: "term_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 200, default: "", null: false
    t.string "slug", limit: 200, default: "", null: false
    t.bigint "term_group", default: 0, null: false
    t.index ["name"], name: "name", length: 191
    t.index ["slug"], name: "slug", length: 191
  end

  create_table "wp_usermeta", primary_key: "umeta_id", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", size: :long
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["user_id"], name: "user_id"
  end

  create_table "wp_users", primary_key: "ID", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "user_login", limit: 60, default: "", null: false
    t.string "user_pass", default: "", null: false
    t.string "user_nicename", limit: 50, default: "", null: false
    t.string "user_email", limit: 100, default: "", null: false
    t.string "user_url", limit: 100, default: "", null: false
    t.datetime "user_registered", null: false
    t.string "user_activation_key", default: "", null: false
    t.integer "user_status", default: 0, null: false
    t.string "display_name", limit: 250, default: "", null: false
    t.index ["user_email"], name: "user_email"
    t.index ["user_login"], name: "user_login_key"
    t.index ["user_nicename"], name: "user_nicename"
  end

  create_table "wp_wpforms_tasks_meta", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "action", null: false
    t.text "data", size: :long, null: false
    t.datetime "date", null: false
  end

  create_table "wp_wpmailsmtp_debug_events", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.text "content"
    t.text "initiator"
    t.integer "event_type", limit: 1, default: 0, null: false, unsigned: true
    t.timestamp "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "wp_wpmailsmtp_tasks_meta", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "action", null: false
    t.text "data", size: :long, null: false
    t.datetime "date", null: false
  end

  create_table "wp_yoast_seo_links", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "url", null: false
    t.bigint "post_id", null: false, unsigned: true
    t.bigint "target_post_id", null: false, unsigned: true
    t.string "type", limit: 8, null: false
    t.index ["post_id", "type"], name: "link_direction"
  end

  create_table "wp_yoast_seo_meta", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "object_id", null: false, unsigned: true
    t.integer "internal_link_count", unsigned: true
    t.integer "incoming_link_count", unsigned: true
    t.index ["object_id"], name: "object_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "m3_leads", "m3_leadsets"
end
