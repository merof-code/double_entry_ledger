require_relative "entry"
require_relative "person_account_balance"

module Ledger
  # Store a result from a single transaction in a typed object
  class TransactionResult < T::Struct
    const :debit, Entry
    const :credit, Entry
    prop :person_balance_debit, T.nilable(PersonAccountBalance)
    prop :person_balance_credit, T.nilable(PersonAccountBalance)
  end
end
