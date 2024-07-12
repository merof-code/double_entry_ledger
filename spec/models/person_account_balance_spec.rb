RSpec.describe Ledger::PersonAccountBalance, type: :model do
  describe "associations" do
    it {
      expect(subject).to belong_to(:ledger_person).class_name("Ledger::Person").with_foreign_key("ledger_person_id").required
    }

    it {
      expect(subject).to belong_to(:ledger_account).class_name("Ledger::Account").with_foreign_key("ledger_account_id").required
    }
  end

  describe "validations" do
    it { is_expected.to monetize(:balance).with_model_currency(:balance_currency) }
    it { is_expected.to validate_presence_of(:date) }

    it "validates uniqueness of date scoped to ledger_account_id and ledger_person_id" do
      ledger_person = create(:person)
      ledger_account = create(:account)
      create(:ledger_person_account_balance, date: "2023-01-01", ledger_person:,
                                             ledger_account:)
      new_balance = build(:ledger_person_account_balance, date: "2023-01-01", ledger_person:,
                                                          ledger_account:)
      expect(new_balance).not_to be_valid
      expect(new_balance.errors[:date]).to include("should be unique within the scope of ledger account and person")
    end

    it "does not allow date to be earlier than the last entry's date within the same ledger account and person" do
      ledger_person = create(:person)
      ledger_account = create(:account)
      create(:ledger_person_account_balance, date: "2023-01-01", ledger_person:,
                                             ledger_account:)
      new_balance = build(:ledger_person_account_balance, date: "2022-12-01", ledger_person:,
                                                          ledger_account:)
      expect(new_balance).not_to be_valid
      expect(new_balance.errors[:date]).to include("cannot be earlier than the last entry's date within the same ledger account and person")
    end
  end

  describe "callbacks" do
    it "sets date to the first day of the month before validation" do
      balance = build(:ledger_person_account_balance, date: "2023-01-15")
      balance.valid?
      expect(balance.date).to eq(Date.new(2023, 1, 1))
    end
  end
end
