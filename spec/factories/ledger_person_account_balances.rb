FactoryBot.define do
  factory :ledger_person_account_balance, class: "Ledger::PersonAccountBalance" do
    association :ledger_person, factory: :person
    association :ledger_account, factory: :account
    date { "2023-01-01" }
    balance_cents { 1000 }
    balance_currency { "USD" }
  end
end
