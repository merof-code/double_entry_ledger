# typed: true

module Ledger
  class TransactionProcessor
    extend T::Sig
    class << self
      extend T::Sig

      @transfer = T.let(nil, T.nilable(Transfer))

      # @param [Ledger::Transfer::Instance] transfer A prepared object that is _not_ saved in the db!
      # With all the fields filled out, like :document, :date, :description.
      # @param [Array<Hash>] transactions An array of hashes with :debit, :credit, :amount, and optional :person keys.
      # @return [[Line, Line]] The credit & debit (in that order) created by the transfer.
      # @raise [Ledger::TransactionNegative] If the amount is less than zero.
      # @raise [Ledger::TransferAlreadyExists] If the provided transfer instance is already recorded in the db.
      # @raise [Ledger::InsufficientFunds] If the amount in the person's account is not enough.
      # @raise [Ledger::TransactionNotAllowed] If the transfer is not allowed.
      # @raise [Ledger::MismatchedCurrencies]
      sig do
        params(transfer: Transfer,
               transactions: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[TransactionResult])
      end
      def transfer(transfer, transactions)
        raise Ledger::TransferAlreadyExists if transfer.persisted?
        raise Ledger::DuplicateTransactions if transactions.uniq.length != transactions.length

        @transfer = transfer
        result = T.let([], T::Array[Ledger::TransactionResult])
        # may be empty
        account_balances = find_or_create_account_balances_for(transactions)
        Locking.lock_accounts(account_balances) do
          transfer.save!
          t = TransactionProcessor.new(transfer)
          result = transactions.map { |transaction| t.create_entry(transaction) }
        end
        result
      end

      private

      # Finds or creates account balances for all transactions in the provided array and adds (debit, credit)_account_balance to each hash that has a person.
      sig { params(transactions: T::Array[Hash]).returns(T::Array[Ledger::AccountBalance]) }
      def find_or_create_account_balances_for(transactions)
        all_account_balances = []

        transactions.each do |transaction|
          all_account_balances << process_account_balance(transaction, :credit)
          all_account_balances << process_account_balance(transaction, :debit)
        end

        all_account_balances.uniq.compact
      end

      # Processes the account balance for a person based on the accounting side key (debit or credit).
      def process_account_balance(transaction, accounting_side_key)
        key = "person_#{accounting_side_key}".to_sym
        person = transaction[key]
        return unless person

        search_or_create_keys = {
          person:, account: transaction[accounting_side_key],
          date: @transfer.date.beginning_of_month,
          balance_currency: transaction[:amount].currency
        }
        account_balance = AccountBalance.find_or_create_by(search_or_create_keys)

        transaction["#{key}_balance".to_sym] = account_balance
        account_balance
      end
    end

    @transaction = T.let({}, T::Hash[Symbol, T.untyped])
    @transfer = T.let(nil, T.nilable(Transfer))

    sig { params(transfer: Transfer).void }
    def initialize(transfer)
      @transfer = transfer
    end

    sig { params(transaction: T::Hash[Symbol, T.untyped]).returns(TransactionResult) }
    def create_entry(transaction)
      @transaction = transaction
      raise Ledger::TransactionNegative unless @transaction[:amount].positive?

      result = create_ledger_entries
      update_person_balance(result)
      # we can also do account_balances without person, also can make it optional
      # That would require creating and maintaining balance records for those accounts.
    end

    private

    # Whenever there is a transaction with a person, both entries of the ledger are affected, and so are the
    # 2 balances. For example we have balance and savings, with each, both are affected.
    def update_person_balance(result)
      result.balance_debit = handle_person_side(:debit)
      result.balance_credit = handle_person_side(:credit)
      result
    end

    def handle_person_side(side)
      key = "person_#{side}_balance".to_sym
      balance_account = @transaction[key]
      return unless balance_account

      balance_account = Locking.balance_for_locked_account(balance_account)
      amount = @transaction[:amount]
      raise Ledger::MismatchedCurrencies unless balance_account.balance.currency == amount.currency

      multiplier = 1
      multiplier = -1 if side == :debit
      balance_account.balance += multiplier * amount
      if balance_account.balance.negative?
        raise Ledger::InsufficientFunds,
              "Insufficient funds in #{side}, #{balance_account.balance}"
      end

      balance_account.save!
      balance_account
    end

    sig { returns(TransactionResult) }
    def create_ledger_entries
      base_entry = Entry.new(amount: @transaction[:amount], transfer: @transfer)
      # TODO: test this dup, associations
      debit = base_entry.dup
      debit.account = @transaction[:debit]
      debit.person = @transaction[:person_debit]
      debit.debit!

      credit = base_entry.dup
      credit.account = @transaction[:credit]
      credit.person = @transaction[:person_credit]
      credit.save!

      TransactionResult.new(credit:, debit:)
    end
  end
end
