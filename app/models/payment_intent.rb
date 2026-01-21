class PaymentIntent < ApplicationRecord

  PENDING = 'pending'.freeze
  SUCCEEDED = 'succeeded'.freeze
  FAILED = 'failed'.freeze
  STATUSES = [PENDING, SUCCEEDED, FAILED].freeze

  has_one :outbox_event, as: :aggregate, dependent: :destroy
  attribute :status, :string, default: PENDING

  validates_uniqueness_of :idempotency_key
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true
  validates :status, inclusion: { in: STATUSES }

end
