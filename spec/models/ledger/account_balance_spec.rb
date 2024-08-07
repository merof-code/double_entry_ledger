# frozen_string_literal: true

RSpec.describe Ledger::AccountBalance, type: :model do
  describe "associations" do
    it {
      expect(subject).to belong_to(:person).class_name("Ledger::Person").with_foreign_key("person_id").required
    }

    it {
      expect(subject).to belong_to(:account).class_name("Ledger::Account").with_foreign_key("ledger_account_id").required
    }
  end

  describe "validations" do
    it { is_expected.to monetize(:balance).with_model_currency(:balance_currency) }
    it { is_expected.to validate_presence_of(:date) }

    it {
      create(:account_balance)
      expect(subject).to validate_uniqueness_of(:date)
        .scoped_to(%i[ledger_account_id person_id balance_currency])
    }

    it "does not allow date to be earlier than the last entry's date within the same ledger account and person" do
      person = create(:person)
      account = create(:account)
      create(:account_balance, date: "2023-01-01", person:,
                               account:)
      new_balance = build(:account_balance, date: "2022-12-01", person:,
                                            account:)
      expect(new_balance).not_to be_valid
      expect(new_balance.errors[:date])
        .to include("cannot be earlier than the last entry's date within the same ledger account and person")
    end
  end

  describe "callbacks" do
    it "sets date to the first day of the month before validation" do
      balance = build(:account_balance, date: "2023-01-15")
      balance.valid?
      expect(balance.date).to eq(Date.new(2023, 1, 1))
    end
  end
end
