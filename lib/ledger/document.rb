# frozen_string_literal: true
# typed: true

module Ledger
  # Connects events in form of a document to transfer, a "physical" reason for the transfer
  # Has a polymorph filed and api_id field for integration
  class Document < ActiveRecord::Base
    # Associations
    belongs_to :documentable, polymorphic: true, optional: true
    belongs_to :document_type, class_name: "Ledger::DocumentType", foreign_key: "ledger_document_type_id", required: true,
                               inverse_of: :documents
    has_many :transfers, class_name: "Ledger::Transfer", foreign_key: "ledger_document_id"

    # Validations
    validates :date, presence: true
    validates :number, length: { maximum: 100 }
    validates :description, length: { maximum: 300 }, presence: true
    validates :external_id, length: { maximum: 255 }
  end
end
