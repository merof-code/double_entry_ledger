# spec/factories/people.rb
FactoryBot.define do
  factory :person, class: "Ledger::Person" do
    association :personable, factory: :user
  end
end
