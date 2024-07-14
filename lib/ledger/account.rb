# typed: true

module Ledger
  # All bookkeeping accounts that the application will use.
  # Id is not a auto increment, it is the account in question, like account 300.
  # account_type is enum equity, liability, revenue, expense, asset.
  # you may assign the official account name in official_code.
  class Account < ActiveRecord::Base
    # TODO: add associations
    self.primary_key = "id"
    has_many :person_account_balances, class_name: "Ledger::PersonAccountBalance", foreign_key: "ledger_account_id",
                                       inverse_of: :account
    has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_account_id", inverse_of: :account

    # TODO: use account ACCOUNT_TYPES
    enum :account_type, %i[equity liability revenue expense asset], validate: true, presence: true

    validates :id, presence: true, uniqueness: true
    validates :account_name, presence: true, length: { maximum: 255 }
    validates :official_code, length: { maximum: 20 }
  end

  # TODO: this
  # module idkyet
  #   ACCOUNT_TYPES = %i[equity liability revenue expense asset]
  #   ACTIVE_ACCOUNT_TYPES = %i[expense asset]
  #   PASSIVE_ACCOUNT_TYPES = %i[equity liability revenue]
  # end
end
