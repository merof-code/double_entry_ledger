# spec/models/ledger/entry_spec.rb
RSpec.describe Ledger::Entry, type: :model do
  describe "setup" do
    describe "validations" do
      it { is_expected.to validate_presence_of(:ledger_transfer_id) }
      it { is_expected.to validate_presence_of(:ledger_account_id) }
      it { is_expected.to validate_presence_of(:ledger_person_id) }
      it { is_expected.to validate_inclusion_of(:is_debit).in_array([true, false]) }
      it { is_expected.to validate_presence_of(:amount_cents) }
      it { is_expected.to validate_numericality_of(:amount_cents).only_integer.is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_presence_of(:amount_currency) }
      it { is_expected.to validate_length_of(:amount_currency).is_equal_to(3) }
    end

    describe "indexes" do
      it { is_expected.to have_db_index(:is_debit) }
      it { is_expected.to have_db_index(:ledger_account_id) }
      it { is_expected.to have_db_index(:ledger_transfer_id) }
      it { is_expected.to have_db_index(:ledger_person_id) }
    end

    describe "associations" do
      it {
        expect(subject).to belong_to(:ledger_transfer)
          .class_name("Ledger::Transfer")
          .with_foreign_key("ledger_transfer_id")
          .required
      }

      it {
        expect(subject).to belong_to(:ledger_account)
          .class_name("Ledger::Account")
          .with_foreign_key("ledger_account_id")
          .required
      }

      it {
        expect(subject).to belong_to(:ledger_person)
          .class_name("Ledger::Person")
          .with_foreign_key("ledger_person_id")
          .required
      }
    end
  end

  describe "valid model" do
    let(:valid_entry) do
      build(:entry)
    end

    it "is valid with valid attributes" do
      expect(valid_entry).to be_valid
      expect(valid_entry.save).to be_truthy
    end
  end
end
