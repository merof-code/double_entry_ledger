# typed: true

module Ledger
  # This is not the ledger itself, this is a transaction, which may have 2 or more lines in the ledger,
  # so that all lines in the ledger under the same transaction have total credit - debit = 0.
  # Connects to (source) documents, and
  # based on https://www.codeproject.com/Articles/5163401/Database-for-Financial-Accounting-Application-II
  class Transfer < ActiveRecord::Base
    belongs_to :document, class_name: "Ledger::Document", foreign_key: "ledger_document_id", required: true
    has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_transfer_id", inverse_of: :transfer

    validates :date, presence: true
    validates :description, presence: true, length: { in: 5..255 }
  end
end
