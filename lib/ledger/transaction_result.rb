# File: ledger/transaction_result.rb
require_relative "entry"
require_relative "account_balance"

module Ledger
  # Store a result from a single transaction in a typed object
  class TransactionResult
    attr_reader :debit, :credit
    attr_accessor :balance_debit, :balance_credit

    def initialize(debit:, credit:, balance_debit: nil, balance_credit: nil)
      @debit = debit
      @credit = credit
      @balance_debit = balance_debit
      @balance_credit = balance_credit
    end
  end
end
