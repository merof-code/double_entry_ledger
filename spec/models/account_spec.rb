# typed: false

RSpec.describe Ledger::Account, type: :model do
  describe "setup" do
    describe "validations" do
      it { is_expected.to validate_presence_of(:id) }
      it { is_expected.to validate_uniqueness_of(:id) }

      it { is_expected.to validate_presence_of(:account_name) }
      it { is_expected.to validate_length_of(:account_name).is_at_most(255) }
      it { is_expected.to validate_length_of(:official_code).is_at_most(20) }

      it {
        expect(subject).to define_enum_for(:account_type)
          .with_values(%i[equity liability revenue expense asset])
      }
      # This was added in https://github.com/thoughtbot/shoulda-matchers/commit/3c88e1c3e85dbc51a75ae65a2cd6df5e8838655d
      # but not yet released after that. will uncomment then.
      # it do
      #   expect(subject).to define_enum_for(:account_type)
      #     .validating
      # end
    end

    describe "indexes" do
      it { is_expected.to have_db_index(:account_type) }
      it { is_expected.to have_db_index(:official_code) }
    end

    describe "associations" do
      it {
        expect(subject).to have_many(:person_account_balances)
          .class_name("Ledger::PersonAccountBalance")
          .with_foreign_key("ledger_account_id")
          .inverse_of(:ledger_account)
      }

      it {
        expect(subject).to have_many(:ledger_entries)
          .class_name("Ledger::Entry")
          .with_foreign_key("ledger_account_id")
          .inverse_of(:ledger_account)
      }
    end
  end

  describe "valid model" do
    # Assuming you have FactoryBot set up with a valid ledger_account factory
    let(:valid_account) do
      build(:account)
    end

    it "is valid with valid attributes" do
      expect(valid_account).to be_valid
      expect(valid_account.save).to be_truthy
    end
  end
end
