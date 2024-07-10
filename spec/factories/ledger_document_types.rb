FactoryBot.define do
  factory :ledger_document_type, class: "Ledger::DocumentType" do
    name { "Invoice" }
    description { "Invoice documents" }
  end
end
