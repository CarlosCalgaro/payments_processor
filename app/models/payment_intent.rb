class PaymentIntent < ApplicationRecord

  PENDING = 'pending'.freeze
  PROCESSING = 'processing'.freeze
  SUCCEEDED = 'succeeded'.freeze
  FAILED = 'failed'.freeze
  STATUSES = [PENDING, PROCESSING, SUCCEEDED, FAILED].freeze

  has_one :outbox_event, as: :aggregate, dependent: :destroy
  attribute :status, :string, default: PENDING

  validates_uniqueness_of :idempotency_key, allow_nil: true
  validates_uniqueness_of :confirmation_idempotency_key, allow_nil: true
  validates_uniqueness_of :refund_idempotency_key, allow_nil: true

  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true
  validates :status, inclusion: { in: STATUSES }
end
