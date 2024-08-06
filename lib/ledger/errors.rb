# frozen_string_literal: true
# typed: true

module Ledger
  class LedgerError < RuntimeError; end
  class TransferAlreadyExists < LedgerError; end
  class DuplicateTransactions < LedgerError; end
  class TransactionNegative < LedgerError; end
  class InsufficientFunds < LedgerError; end
  class TransactionNotAllowed < LedgerError; end
  class MismatchedCurrencies < LedgerError; end
  # class UnknownAccount < DoubleEntryError; end
  # class TransferNotAllowed < DoubleEntryError; end
  # class DuplicateAccount < DoubleEntryError; end
  # class DuplicateTransfer < DoubleEntryError; end
end
