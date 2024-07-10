# typed: true

module Ledger
  class Document < ActiveRecord::Base
    # Associations
    belongs_to :documentable, polymorphic: true, optional: true
    has_many :ledger_transfers, class_name: "Ledger::Transfer", foreign_key: "ledger_document_id"

    # Validations
    validates :date, presence: true
    validates :number, length: { maximum: 100 }
    validates :description, length: { maximum: 300 }
    validates :external_id, length: { maximum: 255 }
  end
end
