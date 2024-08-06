# frozen_string_literal: true

FactoryBot.define do
  factory :document_type, class: "Ledger::DocumentType" do
    sequence(:name) { |n| "DOC#{n}" }
    description { "Invoice documents" }
  end
end
