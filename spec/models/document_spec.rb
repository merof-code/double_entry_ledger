# spec/models/ledger/document_spec.rb
RSpec.describe Ledger::Document, type: :model do
  describe "setup" do
    describe "validations" do
      it { is_expected.to validate_presence_of(:date) }
      it { is_expected.to validate_presence_of(:description) }
      it { is_expected.to validate_length_of(:number).is_at_most(100) }
      it { is_expected.to validate_length_of(:description).is_at_most(300) }
      it { is_expected.to validate_length_of(:external_id).is_at_most(255) }
    end

    describe "indexes" do
      it { is_expected.to have_db_index(:ledger_document_type_id) }
      it { is_expected.to have_db_index(:date) }
      it { is_expected.to have_db_index(%i[documentable_type documentable_id]) }
    end

    describe "associations" do
      it {
        expect(subject).to belong_to(:documentable).optional
      }

      it {
        expect(subject).to belong_to(:document_type)
          .class_name("Ledger::DocumentType").with_foreign_key("ledger_document_type_id")
      }

      it {
        expect(subject).to have_many(:ledger_transfers)
          .class_name("Ledger::Transfer")
          .with_foreign_key("ledger_document_id")
      }
    end
  end

  describe "valid model" do
    let(:valid_document) do
      build(:document)
    end

    it "is valid with valid attributes" do
      expect(valid_document).to be_valid
      expect(valid_document.save).to be_truthy
    end
  end
end
