# spec/factories/entries.rb
FactoryBot.define do
  factory :entry, class: "Ledger::Entry" do
    association :ledger_transfer, factory: :transfer
    association :ledger_account, factory: :account
    association :ledger_person, factory: :person
    is_debit { false }
    amount_cents { 1000 }
    amount_currency { "USD" }
  end
end
