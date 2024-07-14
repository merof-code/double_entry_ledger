RSpec.describe Ledger::DocumentType, type: :model do
  describe "associations" do
    it {
      expect(subject).to have_many(:documents).class_name("Ledger::Document").with_foreign_key("ledger_document_type_id")
    }
  end

  describe "validations" do
    subject { create(:document_type) } # Ensure an existing record is created

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end
end
