# typed: true

module Ledger
  # This is not the ledger itself, this is a transaction, which may have 2 or more lines in the ledger,
  # so that all lines in the ledger under the same transaction have total credit - debit = 0.
  # Connects to (source) documents, and
  # based on https://www.codeproject.com/Articles/5163401/Database-for-Financial-Accounting-Application-II
  class Transfer < ActiveRecord::Base
    # TODO: test this
    # TODO: add relation to ledger, and perhaps some checking of the fact that debit - credit = 0.
    # This is the point around which locking could be done

    belongs_to :ledger_document, class_name: "Ledger::Document", foreign_key: "ledger_document_id", required: true
    has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_transfer_id", inverse_of: :ledger_transfer

    validates :date, presence: true
    validates :description, presence: true, length: { in: 5..255 }

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
      sig { params(transfer: Transfer, transactions: T::Array[Hash]).returns(T.untyped) }
      def transfer(transfer, transactions)
        raise Ledger::TransferAlreadyExists if transfer.persisted?
        raise Ledger::DuplicateTransactions if transactions.uniq.length != transactions.length

        # may be empty
        people = transactions.map { |tr| tr[:person] }.compact
        Locking.lock_accounts(people) do
          transfer.save
          # for each transaction set
          transactions.each do |transaction|
            create_entry(transfer, transaction)
          end
        end
      end

      # @param [Hash] transactions with :debit, :credit, :amount and optional :person
      # @param [Ledger::Transfer::Instance] transfer persisted record, need only id
      sig { params(transfer: Transfer, transaction: Hash).returns(Hash) }
      def create_entry(transfer, transaction)
        raise Ledger::TransactionNegative unless transaction[:amount].positive?

        person = transaction[person]
        amount = transaction[:amount]
        base_entry = Entry.new(amount:, transfer:, person:)

        result = create_ledger_entries(base_entry, transaction)
        return result unless person

        result[:person_balance] = update_person_balance(amount, person)

        result
      end

      def update_person_balance(amount, person)
        # TODO: date? closed?
        person_balance = Locking.balance_for_locked_account(person)
        # TODO: the + or - depending on the side
        person_balance.amount += amount
        person_balance.save!
        person_balance
      end

      # @param [Hash] transactions with :debit, :credit, :amount and optional :person
      # @param [Ledger::Transfer::Instance] transfer persisted record, need only id
      sig { params(base_entry: Entry, transaction: Hash).returns(Hash) }
      def create_ledger_entries(base_entry, transaction)
        # TODO: test this dup, associations
        debit = base_entry.dup
        credit = base_entry.dup
        debit.account = transaction[:debit]
        debit.debit!

        credit.account = transaction[:credit]
        credit.save!

        { debit:, credit: }
      end
    end
  end
end
