# spec/models/ledger/entry_spec.rb
RSpec.describe Ledger::Entry, type: :model do
  describe "setup" do
    describe "validations" do
      it { is_expected.to validate_presence_of(:amount_cents) }
      it { is_expected.to validate_numericality_of(:amount_cents).only_integer.is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_presence_of(:amount_currency) }
      it { is_expected.to validate_length_of(:amount_currency).is_equal_to(3) }
      it { is_expected.to monetize(:amount).with_model_currency(:amount_currency) }
    end

    describe "indexes" do
      it { is_expected.to have_db_index(:is_debit) }
      it { is_expected.to have_db_index(:ledger_account_id) }
      it { is_expected.to have_db_index(:ledger_transfer_id) }
      it { is_expected.to have_db_index(:ledger_person_id) }
    end

    describe "associations" do
      it {
        expect(subject).to belong_to(:transfer)
          .class_name("Ledger::Transfer")
          .with_foreign_key("ledger_transfer_id")
          .required
      }

      it {
        expect(subject).to belong_to(:account)
          .class_name("Ledger::Account")
          .with_foreign_key("ledger_account_id")
          .required
      }

      it {
        expect(subject).to belong_to(:person)
          .class_name("Ledger::Person")
          .with_foreign_key("ledger_person_id")
          .optional
      }
    end
  end

  describe "valid model" do
    it "is valid with valid attributes" do
      valid_entry = create(:entry)
      expect(valid_entry).to be_valid
      expect(valid_entry.save).to be_truthy
    end
  end
end
