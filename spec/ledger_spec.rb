# frozen_string_literal: true
# typed:ignore

RSpec.describe Ledger do
  T.bind(self, T.untyped)
  it "has a version number" do
    expect(Ledger::VERSION).not_to be_nil
  end

  describe ".transfer" do
    let(:account_a) { create(:account) }
    let(:account_b) { create(:account) }
    let(:account_c) { create(:account) }
    let(:transfer) { build(:transfer) }

    context "without a person" do
      let(:transactions) do
        [
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_b },
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_c }
        ]
      end

      it "works with one transaction" do
        result = described_class.transfer(
          transfer,
          amount: Money.new(2000, "USD"),
          debit: account_a,
          credit: account_b
        )

        expect(result).to be_an(Array)
        expect(result[0]).to be_an(Ledger::TransactionResult)
        expect(result.size).to eq(1)
        expect(result[0].balance_credit).to be_nil
        expect(result[0].balance_debit).to be_nil
      end

      it "works fine with many transactions" do
        result = Ledger.transfer(
          transfer,
          transactions:
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)

        result.each do |transaction|
          expect(transaction).to be_an(Ledger::TransactionResult)
        end
      end
    end

    context "with a person" do
      let(:person_a) { create(:person) }
      let(:person_b) { create(:person) }

      def preset_balance(balance, person, account)
        acb = build(:account_balance)
        acb.balance = balance
        acb.update!(person:, account:, date: transfer.date)
      end

      it "works with one transaction" do
        result = described_class.transfer(
          transfer,
          amount: Money.new(2000, "USD"),
          debit: account_a,
          credit: account_b,
          person_credit: person_a
        )

        expect(result[0].balance_credit).to be_present
        expect(result[0].balance_debit).to be_nil
      end

      # TODO: add active-passive accoutn can only transfer within the same account
      it "transfers from one person to another" do
        preset_balance Money.new(2100, "USD"), person_b, account_a

        result = described_class.transfer(
          transfer,
          amount: Money.new(2000, "USD"),
          debit: account_a,
          person_debit: person_b,
          credit: account_a,
          person_credit: person_a
        )

        expect(result[0].balance_credit).to be_present
        expect(result[0].balance_debit).to be_present
        expect(result[0].balance_debit.balance).to eq Money.new(100, "USD")
      end

      it "works with multiple transactions" do
        acb = build(:account_balance)
        preset_balance Money.new(1000, "USD"), person_b, account_a

        result = described_class.transfer(
          transfer,
          transactions: [
            { amount: Money.new(1000, "USD"), debit: account_a, credit: account_b, person_debit: person_b },
            { amount: Money.new(1000, "USD"), debit: account_b, credit: account_c, person_credit: person_b }
          ]
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)

        expect(result[1].balance_credit.balance).to eq Money.new(1000, "USD")
      end

      it "works fine multiple fully person-ed transactions" do
        preset_balance Money.new(1000, "USD"), person_b, account_a
        preset_balance Money.new(1000, "USD"), person_b, account_b

        result = described_class.transfer(
          transfer,
          transactions: [
            { amount: Money.new(500, "USD"), debit: account_a, credit: account_b, person_debit: person_b,
              person_credit: person_a },
            { amount: Money.new(600, "USD"), debit: account_b, credit: account_c, person_debit: person_b,
              person_credit: person_a },
            { amount: Money.new(500, "USD"), debit: account_b, credit: account_c, person_debit: person_a,
              person_credit: person_a }
          ]
        )

        expect(result).to be_an Array
        expect(result.size).to eq 3

        expect(result[2].balance_credit.balance).to eq Money.new(1100, "USD")
      end

      it "Throws when transfer results in negative funds" do
        expect do
          described_class.transfer(
            transfer,
            amount: Money.new(2000, "USD"),
            debit: account_a,
            credit: account_b,
            person_debit: person_a
          )
        end.to raise_error(Ledger::InsufficientFunds)
      end

      it "actually persists account balance records" do
        expect do
          result = described_class.transfer(
            transfer,
            amount: Money.new(2000, "USD"),
            debit: account_a,
            credit: account_b,
            person_credit: person_a
          )
        end.to change(Ledger::AccountBalance, :count).by(1)
      end

      it "actually persists account balance records" do
        expect do
          result = described_class.transfer(
            transfer,
            amount: Money.new(2000, "USD"),
            debit: account_a,
            credit: account_b,
            person_credit: person_a
          )
        end.to change(Ledger::AccountBalance, :count).by(1)
      end
    end

    context "when sending a fully created transfer object" do
      let(:saved_transfer) { create(:transfer) }

      it "raises a Ledger::TransferAlreadyExists error" do
        expect do
          described_class.transfer(
            saved_transfer,
            amount: Money.new(2000, "USD"),
            debit: account_a,
            credit: account_b
          )
        end.to raise_error(Ledger::TransferAlreadyExists)
      end
    end
  end
end
