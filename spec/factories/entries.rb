# spec/factories/entries.rb
FactoryBot.define do
  factory :entry, class: "Ledger::Entry" do
    association :transfer, factory: :transfer
    association :account, factory: :account
    association :person, factory: :person
    is_debit { false }
    amount_cents { 1000 }
    amount_currency { "USD" }
  end
end
