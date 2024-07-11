# frozen_string_literal: true

# load the db and turn on the monetize:, this should be before MoneyRails::Hooks.init
require "./config/database"
require "money-rails"
MoneyRails::Hooks.init

require "ledger"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require "shoulda-matchers"
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    # Keep as many of these lines as are necessary:
    with.library :active_record
    with.library :active_model
  end
end

require "money-rails/test_helpers"
