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
        expect(result[0].person_balance_credit).to be_nil
        expect(result[0].person_balance_debit).to be_nil
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
      let(:person) { create(:person) }
      let(:transactions) do
        [
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_b, person: create(:person) },
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_c, person: create(:person) }
        ]
      end

      it "works with one transaction" do
        result = described_class.transfer(
          transfer,
          amount: Money.new(2000, "USD"),
          debit: account_a,
          credit: account_b,
          person:
        )

        expect(result[0].person_balance_credit).to be_not_nil
        expect(result[0].person_balance_debit).to be_not_nil
      end

      it "works fine with many transactions" do
        result = Ledger.transfer(
          transfer,
          transactions:
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)

        result.each do |transaction|
          expect(transaction.person_balance_credit).to be_not_nil
          expect(transaction.person_balance_debit).to be_not_nil
        end
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
