# typed: false

FactoryBot.define do
  factory :document, class: "Ledger::Document" do
    date { Date.today }
    sequence(:number) { |n| "DOC#{n}" }
    description { "Test Description" }
    comments { "Some comments" }
    internal_comments { "Some internal comments" }
    documentable_type { nil }
    documentable_id { nil }
    external_id { "EXT123" }
    document_type { 0 } # Assuming 0 is a valid value for one of the enum types
  end
end
