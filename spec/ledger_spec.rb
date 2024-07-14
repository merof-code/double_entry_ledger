# frozen_string_literal: true
# typed:ignore

RSpec.describe Ledger do
  T.bind(self, T.untyped)
  it "has a version number" do
    expect(Ledger::VERSION).not_to be_nil
  end

  describe ".transfer" do
    let(:document) { create(:document) }
    let(:account_a) { create(:account, balance_cents: 10_000) }
    let(:account_b) { create(:account) }
    let(:account_c) { create(:account) }
    let(:person_a) { create(:person) }

    context "with a single transaction without a person" do
      let(:transfer) { Ledger.transfer.new(document:, date: Date.today, description: "Transfer description") }
      let(:amount) { Money.new(2000, "USD") }

      it "returns the correct result" do
        result = Ledger.transfer(
          transfer:,
          amount:,
          debit: account_a,
          credit: account_b
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to have_key(:credit)
        expect(result[0]).to have_key(:debit)
      end
    end

    context "with a single transaction with a person" do
      let(:transfer) { Ledger.transfer.new(document:, date: Date.today, description: "Transfer description") }
      let(:amount) { Money.new(2000, "USD") }

      it "returns the correct result" do
        result = Ledger.transfer(
          transfer:,
          amount:,
          debit: account_a,
          credit: account_b,
          person: person_a
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to have_key(:credit)
        expect(result[0]).to have_key(:debit)
      end
    end

    context "with multiple transactions" do
      let(:transfer) { Ledger.transfer.new(document:, date: Date.today, description: "Transfer description") }
      let(:transactions) do
        [
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_b },
          { amount: Money.new(2000, "USD"), debit: account_a, credit: account_c }
        ]
      end

      it "returns the correct result" do
        result = Ledger.transfer(
          transfer:,
          transactions:
        )

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)

        result.each do |transaction|
          expect(transaction).to have_key(:credit)
          expect(transaction).to have_key(:debit)
        end
      end
    end

    context "when sending a fully created transfer object" do
      let(:saved_transfer) do
        Ledger.transfer.create!(document:, date: Date.today, description: "Saved transfer")
      end

      it "raises a Ledger::TransferAlreadyExists error" do
        expect do
          Ledger.transfer(
            transfer: saved_transfer,
            amount: Money.new(2000, "USD"),
            debit: account_a,
            credit: account_b
          )
        end.to raise_error(Ledger::TransferAlreadyExists)
      end
    end
  end
end
