require "factory_bot"

User = Class.new(ActiveRecord::Base)

# TODO: replace with something more to test integration, maybe. strictly speaking, we don`t need this.
FactoryBot.define do
  factory :user do
    username { "user#{__id__}" }
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.find_definitions
