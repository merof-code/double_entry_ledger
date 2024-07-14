# typed: false

FactoryBot.define do
  factory :document, class: "Ledger::Document" do
    association :document_type, factory: :document_type
    date { Date.today }
    sequence(:number) { |n| "DOC#{n}" }
    description { "Test Description" }
    comments { "Some comments" }
    internal_comments { "Some internal comments" }
    documentable_type { nil }
    documentable_id { nil }
    external_id { "EXT123" }
  end
end
