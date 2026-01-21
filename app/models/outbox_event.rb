class OutboxEvent < ApplicationRecord
  before_create :maybe_set_event_id

  CREATED = 'created'
  PENDING = 'pending'
  PROCESSED = 'processed'
  FAILED = 'failed'
  STATUSES = [CREATED, PENDING, PROCESSED, FAILED].freeze

  validates :status, inclusion: { in: STATUSES }
  # Polymorphic link back to the aggregate root (e.g., PaymentIntent)
  belongs_to :aggregate, polymorphic: true

  private

  def maybe_set_event_id
    self.event_id = SecureRandom.uuid if self.event_id.blank?
  end
end
