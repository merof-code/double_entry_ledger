# frozen_string_literal: true
# typed: true

ActiveRecord::Schema.define(version: 20_240_701_000_001) do # rubocop:disable Metrics/BlockLength
  self.verbose = false

  create_table "ledger_documents", force: :cascade do |t|
    t.date "date", null: false
    t.string "number", limit: 100, default: "", null: false
    t.string "description", limit: 300, default: "", null: false
    t.text "comments"
    t.text "internal_comments"
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.string "external_id", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ledger_document_type_id", null: false
    t.index ["ledger_document_type_id"], name: "index_ledger_documents_on_ledger_document_type_id"
    t.index ["date"], name: "index_ledger_documents_on_date"
    t.index %w[documentable_type documentable_id], name: "index_ledger_documents_on_documentable"
  end

  create_table "ledger_document_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false, default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ledger_document_types_on_name", unique: true
  end

  create_table "ledger_accounts", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
    t.integer "account_type", limit: 2, default: 0, null: false
    t.string "official_code", limit: 20, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type"], name: "index_ledger_accounts_on_account_type"
    t.index ["official_code"], name: "index_ledger_accounts_on_official_code"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "ledger_transfer_id", null: false
    t.bigint "ledger_account_id", null: false
    t.bigint "ledger_person_id"
    t.boolean "is_debit", default: false, null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", limit: 3, default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_debit"], name: "index_ledger_entries_on_is_debit"
    t.index ["ledger_account_id"], name: "index_ledger_entries_on_ledger_account_id"
    t.index ["ledger_transfer_id"], name: "index_ledger_entries_on_ledger_transfer_id"
    t.index ["ledger_person_id"], name: "index_ledger_entries_on_ledger_person_id"
  end

  create_table "ledger_transfers", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "ledger_document_id", null: false
    t.string "description", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_ledger_transfers_on_date"
  end

  create_table "ledger_people", force: :cascade do |t|
    t.string "personable_type", null: false
    t.bigint "personable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index %w[personable_type personable_id], name: "index_ledger_people_on_personable"
  end

  create_table "ledger_account_balances", force: :cascade do |t|
    t.bigint "ledger_person_id", null: false
    t.integer "balance_cents", default: 0, null: false
    t.string "balance_currency", default: "USD", null: false
    t.bigint "ledger_account_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_ledger_account_balances_on_date"
    t.index ["ledger_account_id"], name: "index_ledger_account_balances_on_ledger_account_id"
    t.index ["ledger_person_id"], name: "index_ledger_account_balances_on_ledger_person_id"
    t.index %w[ledger_account_id ledger_person_id date balance_currency],
            unique: true, name: "index_ledger_account_balances_on_account_person_date"
    column_name = "date"
    constraint_command =
      case ActiveRecord::Base.connection.adapter_name
      when "PostgreSQL"
        "EXTRACT(DAY FROM #{column_name}) = 1"
      when "Mysql2"
        "DAY(#{column_name}) = 1"
      when "SQLServer"
        "DATEPART(DAY, #{column_name}) = 1"
      else
        raise "Unsupported database adapter"
      end
    t.check_constraint constraint_command, name: "check_first_day"
  end

  add_foreign_key "ledger_documents", "ledger_document_types"
  add_foreign_key "ledger_transfers", "ledger_documents"
  add_foreign_key "ledger_entries", "ledger_accounts"
  add_foreign_key "ledger_entries", "ledger_transfers"
  add_foreign_key "ledger_account_balances", "ledger_people", column: "ledger_person_id"
  add_foreign_key "ledger_account_balances", "ledger_accounts"
  add_foreign_key "ledger_entries", "ledger_people", column: "ledger_person_id"

  # test table only
  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.timestamps null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", unique: true
end
