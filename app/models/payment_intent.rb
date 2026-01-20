class PaymentIntent < ApplicationRecord

  has_one :outbox_event, as: :aggregate, dependent: :destroy

  PENDING = 'pending'.freeze
  SUCCEEDED = 'succeeded'.freeze
  FAILED = 'failed'.freeze
  STATUSES = [PENDING, SUCCEEDED, FAILED].freeze

  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
