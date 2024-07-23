# typed: true

module Ledger
  class Transfer
    class << self
      extend T::Sig

      # @param [Ledger::Transfer::Instance] transfer A prepared object that is _not_ saved in the db!
      # With all the fields filled out, like :document, :date, :description.
      # @param [Array<Hash>] transactions An array of hashes with :debit, :credit, :amount, and optional :person keys.
      # @return [[Line, Line]] The credit & debit (in that order) created by the transfer.
      # @raise [Ledger::TransactionNegative] If the amount is less than zero.
      # @raise [Ledger::TransferAlreadyExists] If the provided transfer instance is already recorded in the db.
      # @raise [Ledger::InsufficientFunds] If the amount in the person's account is not enough.
      # @raise [Ledger::TransactionNotAllowed] If the transfer is not allowed.
      # @raise [Ledger::MismatchedCurrencies]
      sig { params(transfer: Ledger::Transfer, transactions: T::Array[Hash]).returns(T::Array[TransactionResult]) }
      def transfer(transfer, transactions)
        raise Ledger::TransferAlreadyExists if transfer.persisted?
        raise Ledger::DuplicateTransactions if transactions.uniq.length != transactions.length

        result = T.let([], T::Array[Ledger::TransactionResult])
        # may be empty
        account_balances = find_or_create_account_balances_for(transactions, transfer.date)
        Locking.lock_accounts(account_balances) do
          transfer.save!
          result = transactions.map { |transaction| create_entry(transfer, transaction) }
        end
        result
      end

      # Finds or creates account balances for all transactions in the provided array and adds (debit, credit)_account_balance to each hash that has a person.
      sig { params(transfer: Transfer, transactions: T::Array[Hash]).returns(T::Array[Ledger::PersonAccountBalance]) }
      def find_or_create_account_balances_for(transfer, transactions)
        all_account_balances = []

        transactions.each do |transaction|
          all_account_balances << process_person_account_balance(transfer, transaction, :credit)
          all_account_balances << process_person_account_balance(transfer, transaction, :debit)
        end

        all_account_balances.uniq
      end

      # Processes the account balance for a person based on the accounting side key (debit or credit).
      def process_person_account_balance(transaction, transfer, accounting_side_key)
        key = "person_#{accounting_side_key}".to_sym
        person = transaction[key]
        return unless person

        account_balance = PersonAccountBalance.find_or_create_for(person, transaction[accounting_side_key], transfer)
        transaction["#{key}_balance".to_sym] = account_balance
        account_balance
      end

      # @param [Hash] transactions with :debit, :credit, :amount and optional :person
      # @param [Ledger::Transfer::Instance] transfer persisted record, need only id
      sig { params(transfer: Transfer, transaction: Hash).returns(TransactionResult) }
      def create_entry(transfer, transaction)
        raise Ledger::TransactionNegative unless transaction[:amount].positive?

        result = create_ledger_entries(transfer, transaction)
        return result unless transaction[:person]

        balances = update_person_balance(transaction)
        result.person_balance_debit = balances[:debit]
        result.person_balance_credit = balances[:credit]
        result
      end

      # Whenever there is a transaction with a person, both entries of the ledger are affected, and so are the
      # 2 balances. For example we have balance and savings, with each, both are affected.
      sig { params(transaction: Hash).returns(Hash) }
      def update_person_balance(transaction)
        debit = Locking.balance_for_locked_account(transaction[:debit_account_balance])
        credit = Locking.balance_for_locked_account(transaction[:credit_account_balance])
        amount = transaction[:amount]
        # TODO: test currency different, insufficient funds
        unless debit.balance.currency == credit.balance.currency && debit.balance.currency == amount.currency
          raise Ledger::MismatchedCurrencies
        end

        begin
          debit.balance -= amount
          debit.save!
          credit.balance += amount
          credit.save!
        rescue ActiveRecord::RecordInvalid => e
          if e.record.errors.details[:balance].any?
            raise Ledger::InsufficientFunds, "Insufficient funds in the #{debit} or #{credit}"
          end

          raise e
        end

        { debit:, credit: }
      end

      # @param [Hash] transactions with :debit, :credit, :amount and optional :person
      # @param [Ledger::Transfer::Instance] transfer persisted record, need only id
      sig { params(transfer: Transfer, transaction: Hash).returns(TransactionResult) }
      def create_ledger_entries(transfer, transaction)
        base_entry = Entry.new(amount: transaction[:amount], transfer:, person: transaction[:person])
        # TODO: test this dup, associations
        debit = base_entry.dup
        credit = base_entry.dup
        debit.account = transaction[:debit]
        debit.debit!

        credit.account = transaction[:credit]
        credit.save!

        TransactionResult.new(credit:, debit:)
      end
    end
  end
end
