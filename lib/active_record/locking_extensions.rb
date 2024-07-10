require "active_support/notifications"

module ActiveRecord
  # These methods are available as class methods on ActiveRecord::Base.
  module LockingExtensions
    # Execute the given block within a database transaction, and retry the
    # transaction from the beginning if a RestartTransaction exception is raised.
    def restartable_transaction(&block)
      transaction(&block)
    rescue ActiveRecord::RestartTransaction
      retry
    end

    # Execute the given block, and retry the current restartable transaction if a
    # MySQL deadlock occurs.
    def with_restart_on_deadlock
      yield
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.message =~ /deadlock/i || e.message =~ /database is locked/i

      ActiveSupport::Notifications.publish("deadlock_restart.ledger", exception: e)

      raise ActiveRecord::RestartTransaction
    end

    # Create the record, but ignore the exception if there's a duplicate.
    # if there is a deadlock, retry
    def create_ignoring_duplicates!(*args)
      retry_deadlocks do
        ignoring_duplicates do
          create!(*args)
        end
      end
    end

    private

    def ignoring_duplicates
      # Error examples:
      #   PG::Error: ERROR:  duplicate key value violates unique constraint
      #   Mysql2::Error: Duplicate entry 'keith' for key 'index_users_on_username': INSERT INTO `users...
      #   ActiveRecord::RecordNotUnique  SQLite3::ConstraintException: column username is not unique: INSERT INTO "users"...
      yield
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotUnique => e
      raise unless e.message =~ /duplicate/i || e.message =~ /ConstraintException/

      ActiveSupport::Notifications.publish("duplicate_ignore.ledger", exception: e)

      # Just ignore it...someone else has already created the record.
    end

    def retry_deadlocks
      # Error examples:
      #   PG::Error: ERROR:  deadlock detected
      #   Mysql::Error: Deadlock found when trying to get lock
      yield
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotUnique => e
      raise unless e.message =~ /deadlock/i || e.message =~ /database is locked/i

      # Somebody else is in the midst of creating the record. We'd better
      # retry, so we ensure they're done before we move on.
      ActiveSupport::Notifications.publish("deadlock_retry.ledger", exception: e)

      retry
    end
  end

  # Raise this inside a restartable_transaction to retry the transaction from the beginning.
  class RestartTransaction < RuntimeError
  end
end

ActiveRecord::Base.extend(ActiveRecord::LockingExtensions)
