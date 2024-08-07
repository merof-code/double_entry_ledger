# frozen_string_literal: true
# typed: true

require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module Ledger
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      MissingPersonClassError = Class.new(Thor::Error)
      MissingTenantClassError = Class.new(Thor::Error)

      class_option :person_class, type: :string, default: nil
      class_option :tenant_class, type: :string, default: nil

      desc "Creates a Ledger initializer and the migration"

      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/ledger.rb", options:
      end

      def self.next_migration_number(path)
        ActiveRecord::Generators::Base.next_migration_number(path)
      end

      def copy_migrations
        migration_version = "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        migration_template "migration.rb", "db/migrate/create_double_entry_ledger_tables.rb", migration_version:
      end

      def insert_association_into_classes
        return unless options[:person_class]

        insert_into_file(
          destination,
          "\n#{person_class_code}",
          after: "class #{options[:person_class]}.+$"
        )
      end

      def add_methods_to_person_class
        return unless options[:person_class]

        person_class = options[:person_class].constantize
        inject_into_class person_class_path(person_class), person_class do
          person_class_code
        end
      end

      def add_methods_to_tenant_class
        return unless options[:tenant_class]

        tenant_class = options[:tenant_class].constantize
        inject_into_class tenant_class_path(tenant_class), tenant_class do
          tenant_class_code
        end
      end

      def no_person_class
        return if options[:person_class]

        raise MissingPersonClassError, <<-ERROR.strip_heredoc
          Should be connected to a person model, for that must be provided with a person class name
          Have not been provided a person class, for what it is refer to the readme of ledger gem.

          Be sure to have a Person class. Configure it in `config/initializers/ledger.rb`

          Add this to your person model
          #{person_class_code}
        ERROR
      end

      def no_tenant_class
        return if options[:tenant_class]

        raise MissingTenantClassError, <<-ERROR.strip_heredoc
          Should be connected to a tenant model, for that must be provided with a tenant class name
          Have not been provided a tenant class.

          Be sure to have a Tenant class. Configure it in `config/initializers/ledger.rb`

          Add this to your person model
          #{tenant_class_code}
        ERROR
      end

      private

      def person_class_path(person_class)
        File.join("app/models", "#{person_class.to_s.underscore}.rb")
      end

      def tenant_class_path(tenant_class)
        File.join("app/models", "#{tenant_class.to_s.underscore}.rb")
      end

      def tenant_class_code
        <<-RUBY.strip_heredoc
          has_many :account_balances, class_name: "Ledger::AccountBalance", foreign_key: "person_id"
          has_many :entries, class_name: "Ledger::Entry", foreign_key: "person_id", inverse_of: :person
          has_many :transfers, through: :entries, source: :ledger_transfer
          has_many :documents, through: :transfers, source: :ledger_document
        RUBY
      end

      def person_class_code
        <<-RUBY.strip_heredoc
          has_many :account_balances, class_name: "Ledger::AccountBalance", foreign_key: "person_id"
          has_many :entries, class_name: "Ledger::Entry", foreign_key: "person_id", inverse_of: :person
          has_many :transfers, through: :entries, source: :ledger_transfer
          has_many :documents, through: :transfers, source: :ledger_document
        RUBY
      end
    end
  end
end
