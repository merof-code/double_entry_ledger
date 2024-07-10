require "database_cleaner/active_record"

 require "./config/database"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.clean
  end
end
