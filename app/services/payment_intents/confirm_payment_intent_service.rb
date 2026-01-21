
class PaymentIntents::ConfirmPaymentIntentService
  
  def initialize(payment_intent_id:, idempotency_key:)
    @payment_intent = PaymentIntent.find(payment_intent_id)
    @idempotency_key = idempotency_key
  end


  def call
    PaymentIntent.transaction do
      outbox_event = OutboxEvent.lock.find_by!(aggregate: @payment_intent)
      outbox_event.update!(status: OutboxEvent::PENDING)
    end
  end
end