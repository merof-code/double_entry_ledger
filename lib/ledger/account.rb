# frozen_string_literal: true
# typed: true

module Ledger
  # All bookkeeping accounts that the application will use.
  # Id is not a auto increment, it is the account in question, like account 300.
  # account_type is enum equity, liability, revenue, expense, asset.
  # you may assign the official account name in official_code.
  class Account < ActiveRecord::Base
    self.primary_key = "id"
    has_many :account_balances, class_name: "Ledger::AccountBalance", foreign_key: "ledger_account_id",
                                inverse_of: :account
    has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_account_id", inverse_of: :account
    enum :account_type, %i[active passive mixed], validate: true, presence: true

    validates :id, presence: true, uniqueness: true
    validates :name, presence: true, length: { maximum: 255 }
    validates :official_code, length: { maximum: 20 }
  end
end
