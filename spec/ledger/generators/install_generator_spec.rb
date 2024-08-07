# frozen_string_literal: true
# typed: false

require "generator_spec"
require "generators/ledger/install_generator"

RSpec.describe Ledger::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../tmp/dummy", __FILE__)
  arguments %w(--person_class User --tenant_class Company)

  before do
    prepare_destination
    run_generator
  end

  it "creates the migration file" do
    assert_migration "db/migrate/create_double_entry_ledger_tables.rb" do |migration|
      expect(migration).to contain "class CreateLedgerDoubleEntryTables < ActiveRecord::Migration"
      expect(migration).to contain "create_table \"ledger_documents\", force: :cascade do |t|"
      # Add more assertions here for other tables and fields
    end
  end

  it "creates the initializer" do
    assert_file "config/initializers/ledger.rb"
  end
end
