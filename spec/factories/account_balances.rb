FactoryBot.define do
  factory :account_balance, class: "Ledger::AccountBalance" do
    association :person, factory: :person
    association :account, factory: :account
    date { "2023-01-01" }
    balance_cents { 1000 }
    balance_currency { "USD" }
  end
end
