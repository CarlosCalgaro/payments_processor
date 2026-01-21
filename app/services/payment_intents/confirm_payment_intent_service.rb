class PaymentIntents::ConfirmPaymentIntentService < Service
  def initialize(payment_intent_id:, idempotency_key:)
    @payment_intent_id = payment_intent_id
    @idempotency_key = idempotency_key
  end


  def call
    ActiveRecord::Base.transaction do
      payment_intent = PaymentIntent.lock.find(@payment_intent_id)

      return payment_intent if payment_intent.confirmation_idempotency_key == @idempotency_key


      payment_intent.update!(
        status: PaymentIntent::PROCESSING,
        confirmation_idempotency_key: @idempotency_key
      )

      @outbox_event = OutboxEvent.create!(
        aggregate: payment_intent,
        event_type: "PaymentIntentConfirmed",
        status: OutboxEvent::PENDING
      )
    end

    Payments::ConfirmPaymentJob.perform_later(@payment_intent_id, @idempotency_key)
    @outbox_event
  end
end