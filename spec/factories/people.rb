# spec/factories/people.rb
FactoryBot.define do
  factory :person, class: "Ledger::Person" do
    personable_type { "User" }
    personable_id { 1 }
  end
end
