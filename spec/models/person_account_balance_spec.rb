RSpec.describe Ledger::PersonAccountBalance, type: :model do
  describe "associations" do
    it {
      expect(subject).to belong_to(:person).class_name("Ledger::Person").with_foreign_key("ledger_person_id").required
    }

    it {
      expect(subject).to belong_to(:account).class_name("Ledger::Account").with_foreign_key("ledger_account_id").required
    }
  end

  describe "validations" do
    it { is_expected.to monetize(:balance).with_model_currency(:balance_currency) }
    it { is_expected.to validate_presence_of(:date) }

    it "validates uniqueness of date scoped to ledger_account_id and ledger_person_id" do
      person = create(:person)
      account = create(:account)
      create(:person_account_balance, date: "2023-01-01", person:,
                                      account:)
      new_balance = build(:person_account_balance, date: "2023-01-01", person:,
                                                   account:)
      expect(new_balance).not_to be_valid
      expect(new_balance.errors[:date]).to include("should be unique within the scope of ledger account and person")
    end

    it "does not allow date to be earlier than the last entry's date within the same ledger account and person" do
      person = create(:person)
      account = create(:account)
      create(:person_account_balance, date: "2023-01-01", person:,
                                      account:)
      new_balance = build(:person_account_balance, date: "2022-12-01", person:,
                                                   account:)
      expect(new_balance).not_to be_valid
      expect(new_balance.errors[:date]).to include("cannot be earlier than the last entry's date within the same ledger account and person")
    end
  end

  describe "callbacks" do
    it "sets date to the first day of the month before validation" do
      balance = build(:person_account_balance, date: "2023-01-15")
      balance.valid?
      expect(balance.date).to eq(Date.new(2023, 1, 1))
    end
  end
end
