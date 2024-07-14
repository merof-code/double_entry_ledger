# typed: true

module Ledger
  # Lock financial accounts to ensure consistency.
  #
  # In order to ensure financial transactions always keep track of balances
  # consistently, database-level locking is needed. This module takes care of
  # it.
  #
  # TODO: fix this docs
  # See Ledger.lock_accounts and Ledger.transfer for the public interface
  # to this stuff.
  #
  # Locking is done on Ledger::PersonAccountBalance records. If an PersonAccountBalance
  # record for an account doesn't exist when you try to lock it, the locking
  # code will create one.
  #
  # script/jack_hammer can be used to run concurrency tests on the ledger to
  # validates that locking works properly.
  module Locking
    # TODO: Configuration
    include Configurable
    class Configuration
      # Set this in your tests if you're using transactional_fixtures, so we know
      # not to complain about a containing transaction when you call lock_accounts.
      attr_accessor :running_inside_transactional_fixtures

      def initialize # :nodoc:
        @running_inside_transactional_fixtures = false
      end
    end

    # Run the passed in block in a transaction with the given accounts locked for update.
    #
    # The transaction must be the outermost transaction to ensure data integrity. A
    # LockMustBeOutermostTransaction will be raised if it isn't.
    def self.lock_accounts(*accounts, &block)
      lock = Lock.new(accounts)

      if lock.in_a_locked_transaction?
        lock.ensure_locked!
        yield
      else
        lock.perform_lock(&block)
      end
    rescue ActiveRecord::StatementInvalid => e
      raise LockWaitTimeout if /lock wait timeout/i.match?(e.message)

      raise
    end

    # Return the PersonAccountBalance record if there's a
    # lock on it, or raise a LockNotHeld if there isn't.
    def self.balance_for_locked_account(account)
      Lock.new([account]).balance_for(account)
    end

    class Lock
      @@locks = {}

      def initialize(accounts)
        # Make sure we always lock in the same order, to avoid deadlocks.
        @accounts = accounts.flatten.sort
      end

      # Lock the given accounts, creating account balance records for them if
      # needed.
      def perform_lock(&block)
        ensure_outermost_transaction!

        return if lock_and_call(&block)

        create_missing_account_balances
        raise LockDisaster unless lock_and_call(&block)
      end

      # Return true if we're inside a lock_accounts block.
      def in_a_locked_transaction?
        !locks.nil?
      end

      def ensure_locked!
        @accounts.each do |account|
          unless lock?(account)
            raise LockNotHeld,
                  "No lock held for account: person: #{account.person}, ledger_account #{account.account}"
          end
        end
      end

      def balance_for(account)
        ensure_locked!

        locks[account]
      end

      private

      def locks
        @@locks[Thread.current.object_id]
      end

      def locks=(locks)
        @@locks[Thread.current.object_id] = locks
      end

      def remove_locks
        @@locks.delete(Thread.current.object_id)
      end

      # Return true if there's a lock on the given account.
      def lock?(account)
        in_a_locked_transaction? && locks.key?(account)
      end

      # Raise an exception unless we're outside any transactions.
      def ensure_outermost_transaction!
        minimum_transaction_level = Locking.configuration.running_inside_transactional_fixtures ? 1 : 0
        return if PersonAccountBalance.connection.open_transactions <= minimum_transaction_level

        raise LockMustBeOutermostTransaction
      end

      # Start a transaction, grab locks on the given accounts, then call the block
      # from within the transaction.
      #
      # If any account can't be locked (because there isn't a corresponding account
      # balance record), don't call the block, and return false.
      def lock_and_call
        locks_succeeded = nil
        PersonAccountBalance.restartable_transaction do
          locks_succeeded = PersonAccountBalance.with_restart_on_deadlock { grab_locks }
          if locks_succeeded
            begin
              yield
            ensure
              remove_locks
            end
          end
        end
        locks_succeeded
      end

      # TODO: im here
      # Grab a lock on the account balance record for each account.
      #
      # If all the account balance records exist, set locks to a hash mapping
      # accounts to account balances, and return true.
      #
      # If one or more account balance records don't exist, set
      # accounts_with_balances to the corresponding accounts, and return false.
      def grab_locks
        account_balances = @accounts.map { |account| PersonAccountBalance.find_by_account(account, lock: true) }

        if account_balances.any?(&:nil?)
          @accounts_without_balances =
            @accounts
            .zip(account_balances)
            .select { |_account, account_balance| account_balance.nil? }
            .collect { |account, _account_balance| account }
          false
        else
          self.locks = Hash[*@accounts.zip(account_balances).flatten]
          true
        end
      end

      # Create all the account_balances for the given accounts.
      def create_missing_account_balances
        @accounts_without_balances.each do |account|
          # Get the initial balance from the lines table.
          balance = account.balance
          # Try to create the balance record, but ignore it if someone else has done it in the meantime.
          PersonAccountBalance.create_ignoring_duplicates!(account:, balance:)
        end
      end
    end

    # Raised when lock_accounts is called inside an existing transaction.
    class LockMustBeOutermostTransaction < RuntimeError; end

    # Raised when attempting a transfer on an account that's not locked.
    class LockNotHeld < RuntimeError; end

    # Raised if things go horribly, horribly wrong. This should never happen.
    class LockDisaster < RuntimeError; end

    # Raised if waiting for locks times out.
    class LockWaitTimeout < RuntimeError; end
  end
end
