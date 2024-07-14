FactoryBot.define do
  factory :person_account_balance, class: "Ledger::PersonAccountBalance" do
    association :person, factory: :person
    association :account, factory: :account
    date { "2023-01-01" }
    balance_cents { 1000 }
    balance_currency { "USD" }
  end
end
