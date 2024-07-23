# typed: true
# frozen_string_literal: true

require "sorbet-runtime"

require "active_record"
require "active_record/locking_extensions"
require "active_record/locking_extensions/log_subscriber"
require "money-rails"
require "money"
# TODO: check if i even need this railtie
# require "rails/railtie"
# TODO: check if i even need this active_support/all
require "active_support/all"

require_relative "ledger/version"
require_relative "ledger/errors"
require_relative "ledger/account"
require_relative "ledger/transfer"
require_relative "ledger/transfer_logic"
require_relative "ledger/document"
require_relative "ledger/document_type"
require_relative "ledger/person_account_balance"
require_relative "ledger/entry"
require_relative "ledger/person"
require_relative "ledger/configurable"
require_relative "ledger/locking"
require_relative "ledger/transaction_result"

module Ledger
  class Error < StandardError; end
  class << self
    extend T::Sig
    # Transfer money from one account to another.
    #
    # Only certain transfers are allowed. Define legal transfers in your
    # configuration file.
    #
    # If you're doing other database operations along with your transfer, you'll need to use the
    # lock_accounts method.
    #
    # If you're doing more than one transaction in one hit, you need to put them into the transactions array.
    #
    # @example Single transaction without a person
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     amount: Money.new(20_00, 'USD'),
    #     debit: Ledger::Account.find_by(111),
    #     credit: 222
    #   )
    #
    # @example Single transaction with a person
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     amount: Money.new(20_00, 'USD'),
    #     debit: ledger_account_a,
    #     credit: ledger_account_b,
    #     person: person_a
    #   )
    #
    # @example Complex transfer with multiple transactions
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     transactions: [
    #       {amount: Money.new(20_00, 'USD'), debit: account_a, credit: account_b},
    #       {amount: Money.new(20_00, 'USD'), debit: account_a, credit: account_c}
    #     ]
    #   )
    #
    # @param [Ledger::Transfer::Instance] transfer is a prepared object that is _not_ saved in the db!
    # With all the fields filled out, like :document, :date, :description.
    # @option options [Money] :amount The quantity of money to transfer in this transaction.
    # @option options [Ledger::Account::Instance, Integer] :debit The debit side. If an Integer, the respective Ledger::Account::Instance must already exist.
    # @option options [Ledger::Account::Instance, Integer] :credit The credit side. Same as debit.
    # @option options [Ledger::Person::Instance] :person The person whose balance will be updated.
    # @option options [Array<Hash>] :transactions Array of transaction hashes with :debit, :credit, :amount, and optional :person.
    # @return [Array<Line, Line>] The credit and debit (in that order) created by the transfer.
    # @raise [Ledger::TransferIsNegative] The amount is less than zero.
    # @raise [Ledger::TransferAlreadyExists] The provided transfer instance is already recorded in the db.
    # @raise [Ledger::InsufficientMoney] The amount in the person's account is not enough.
    # @raise [Ledger::TransferNotAllowed] Transfer is not allowed.
    sig { params(transfer: Transfer, options: Hash).returns(T::Array[TransactionResult]) }
    def transfer(transfer, options = {})
      transactions = options[:transactions] || [{
        amount: options[:amount],
        credit: options[:credit],
        debit: options[:debit],
        person: options[:person]
      }]
      Transfer.transfer(transfer, transactions)
    end

    # This is for proper location of tables, there is no rails here to take care of this for us
    # @api private
    def table_name_prefix
      "ledger_"
    end
  end
end
