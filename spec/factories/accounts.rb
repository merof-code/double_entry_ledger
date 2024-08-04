# spec/factories/accounts.rb
FactoryBot.define do
  factory :account, class: "Ledger::Account" do
    sequence(:id) { |n| n }
    name { "Test Account" }
    account_type { 0 } # Assuming 0 is a valid value for one of the enum types
    official_code { "ACC123" }
  end
end
