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
require_relative "ledger/transaction_processor"
require_relative "ledger/document"
require_relative "ledger/document_type"
require_relative "ledger/account_balance"
require_relative "ledger/entry"
require_relative "ledger/person"
require_relative "ledger/configurable"
require_relative "ledger/locking"
require_relative "ledger/transaction_result"

# Read Ledger readme. Access point for the ledger entities
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
    # @example Single transaction without a person on either side
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     amount: Money.new(20_00, 'USD'),
    #     debit: Ledger::Account.find_by(111),
    #     credit: 222
    #   )
    #
    # :person_debit and :person_credit fields are optional
    #
    # A person may be on either side of a single transaction, from the debit or credit side. the keys are person_debit
    # and :person_debit and a :person_credit. The transactions will find or create a person_balance_account entry with
    # the respective :debit, or :credit account and month.
    # TODO: make month optional
    # TODO: handle creating a balance record when there existed one before or after
    #
    # @example Single transaction with a person on debit side
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     amount: Money.new(20_00, 'USD'),
    #     debit: ledger_account_a,
    #     credit: ledger_account_b,
    #     person_debit: person_a
    #   )
    # This will create or find account_balance record with person_a, ledger_account_a, and date from transfer.
    #
    # using both sides:
    # @example Single transaction with a person on debit side
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     amount: Money.new(20_00, 'USD'),
    #     debit: ledger_account_a,
    #     credit: ledger_account_b,
    #     person_debit: person_a
    #     person_credit: person_b
    #   )
    #
    # A transfer with multiple transactions will look like th following.
    # @example Complex transfer with multiple transactions
    #   transfer = Transfer.new(document: document, date: Date.today, description: 'Transfer description')
    #   Ledger.transfer(
    #     transfer: transfer,
    #     transactions: [
    #       {amount: Money.new(20_00, 'USD'), debit: account_a, credit: account_b},
    #       {amount: Money.new(20_00, 'USD'), debit: account_a, credit: account_c, person_debit: person_a}
    #     ]
    #   )
    #
    # @param [Ledger::Transfer::Instance] transfer is a prepared object that is _not_ saved in the db!
    # @option options [Money] :amount The quantity of money to transfer in this transaction.
    # @option options [Ledger::Account::Instance, Integer] :debit The debit side. If an Integer,
    # the respective Ledger::Account::Instance must already exist.
    # @option options [Ledger::Account::Instance, Integer] :credit The credit side. Same as debit.
    # @option options [Ledger::Person::Instance] :person The person whose balance will be updated.
    # @option options [Array<Hash>] :transactions Array of transaction hashes with :debit, :credit, :amount, and optional :person.
    # @return [Array<TransactionResult>] The credit and debit (in that order) created by the transfer.
    # @raise [Ledger::TransferIsNegative] The amount is less than zero.
    # @raise [Ledger::TransferAlreadyExists] The provided transfer instance is already recorded in the db.
    # @raise [Ledger::InsufficientMoney] The amount in the person's account is not enough.
    # @raise [Ledger::TransferNotAllowed] Transfer is not allowed.
    sig { params(transfer: Transfer, options: Hash).returns(T::Array[TransactionResult]) }
    def transfer(transfer, options = {})
      transactions = options[:transactions] ||=
        [options.slice(:amount, :credit, :debit, :person_debit, :person_credit).compact]

      TransactionProcessor.transfer(transfer, transactions)
    end

    # This is for proper location of tables, there is no rails here to take care of this for us
    # @api private
    def table_name_prefix
      "ledger_"
    end
  end
end
