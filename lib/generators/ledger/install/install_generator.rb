# frozen_string_literal: true
# typed: true

require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module Ledger
  # :nodoc:
  module Generators
    # :nodoc:
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(path)
        ActiveRecord::Generators::Base.next_migration_number(path)
      end

      def copy_migrations
        # TODO: .erb to .rb files
        migration_template "migration.erb", "db/migrate/create_ledger_tables.rb", migration_version:
      end

      def create_initializer
        # template 'initializer.rb', 'config/initializers/double_entry.rb'
        # TODO: fix if i will need any or at all
      end

      def migration_version
        return unless ActiveRecord.version.version > "5"

        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
