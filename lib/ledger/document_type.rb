# typed: true

class Ledger::DocumentType < ActiveRecord::Base
  has_many :documents, class_name: "Ledger::Document", foreign_key: "ledger_document_type_id",
                       inverse_of: :document_type

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
