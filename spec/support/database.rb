# frozen_string_literal: true

require "database_cleaner/active_record"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.clean
  end
end
