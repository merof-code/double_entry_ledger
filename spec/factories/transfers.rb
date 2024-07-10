# spec/factories/transfers.rb
FactoryBot.define do
  factory :transfer, class: "Ledger::Transfer" do
    date { Date.today }
    association :ledger_document, factory: :document
    description { "Test Transfer Description" }
  end
end
