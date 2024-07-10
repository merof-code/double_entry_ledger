# spec/models/ledger/transfer_spec.rb
RSpec.describe Ledger::Transfer, type: :model do
  describe "setup" do
    describe "validations" do
      it { is_expected.to validate_presence_of(:date) }
      it { is_expected.to validate_presence_of(:description) }
      it { is_expected.to validate_length_of(:description).is_at_most(255) }
    end

    describe "indexes" do
      it { is_expected.to have_db_index(:date) }
    end

    describe "associations" do
      it {
        expect(subject).to belong_to(:ledger_document)
          .class_name("Ledger::Document")
          .with_foreign_key("ledger_document_id")
          .required
      }

      it {
        expect(subject).to have_many(:entries)
          .class_name("Ledger::Entry")
          .with_foreign_key("ledger_transfer_id")
          .inverse_of(:ledger_transfer)
      }
    end
  end

  describe "valid model" do
    let(:valid_transfer) do
      build(:transfer)
    end

    it "is valid with valid attributes" do
      expect(valid_transfer).to be_valid
      expect(valid_transfer.save).to be_truthy
    end
  end

  describe "external interaction" do
    it "does not allow to save transfer by user" do
      transfer = build(:transfer)
      expect { transfer.save }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not allow to create transfer by user" do
      expect { create(:transfer) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
