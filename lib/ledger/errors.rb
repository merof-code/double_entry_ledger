# typed: true

module Ledger
  class LedgerError < RuntimeError; end
  class TransferAlreadyExists < LedgerError; end
  class DuplicateTransactions < LedgerError; end
  class TransactionNegative < LedgerError; end
  class InsufficientFunds < LedgerError; end
  class TransactionNotAllowed < LedgerError; end
  # class UnknownAccount < DoubleEntryError; end
  # class AccountIdentifierTooLongError < DoubleEntryError; end
  # class ScopeIdentifierTooLongError < DoubleEntryError; end
  # class TransferNotAllowed < DoubleEntryError; end
  # class TransferIsNegative < DoubleEntryError; end
  # class TransferCodeTooLongError < DoubleEntryError; end
  # class DuplicateAccount < DoubleEntryError; end
  # class DuplicateTransfer < DoubleEntryError; end
  # class AccountWouldBeSentNegative < DoubleEntryError; end
  # class AccountWouldBeSentPositiveError < DoubleEntryError; end
  # class MismatchedCurrencies < DoubleEntryError; end
  # class MissingAccountError < DoubleEntryError; end
end
