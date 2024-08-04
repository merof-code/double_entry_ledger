# spec/models/ledger/person_spec.rb
RSpec.describe Ledger::Person, type: :model do
  describe "setup" do
    describe "indexes" do
      it { is_expected.to have_db_index(%i[personable_type personable_id]) }
    end

    describe "associations" do
      it {
        expect(subject).to belong_to(:personable).required
      }

      it {
        expect(subject).to have_many(:account_balances)
          .class_name("Ledger::AccountBalance")
          .with_foreign_key("ledger_person_id")
          .inverse_of(:person)
      }

      it {
        expect(subject).to have_many(:entries)
          .class_name("Ledger::Entry")
          .with_foreign_key("ledger_person_id")
          .inverse_of(:person)
      }
    end
  end

  describe "valid model" do
    let(:valid_person) do
      build(:person)
    end

    it "is valid with valid attributes" do
      expect(valid_person).to be_valid
      expect(valid_person.save).to be_truthy
    end
  end
end
