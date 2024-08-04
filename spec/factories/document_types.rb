FactoryBot.define do
  factory :document_type, class: "Ledger::DocumentType" do
    name { "Invoice" }
    description { "Invoice documents" }
  end
end
