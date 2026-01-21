class Payments::ConfirmPaymentJob < Payments::BaseJob
  queue_as :payment_confirmation

  def perform(outbox_event_id, idempotency_key)
    Rails.logger.info("Starting ConfirmPaymentJob for OutboxEvent ID: #{outbox_event_id}")
    outbox_event = OutboxEvent.find(outbox_event_id)
    payment_intent = outbox_event.aggregate

    return if payment_intent.provider_payment_id.present? || payment_intent.confirmation_idempotency_key != idempotency_key

    gateway = PaymentProviders::Factory.create

    OutboxEvent.transaction do
      payment_intent.reload.lock!
      outbox_event.reload.lock!

      provider_payment = gateway.process_payment(payment_intent)

      payment_intent.update!(
        status: PaymentIntent::SUCCEEDED,
        provider_payment_id: provider_payment[:provider_payment_id]
      )

      outbox_event.update!(status: OutboxEvent::PROCESSED)
    end
  rescue => e
    payment_intent.update!(status: PaymentIntent::FAILED)
    outbox_event.update!(
      status: OutboxEvent::FAILED,
      retry_count: outbox_event.retry_count + 1,
      )
  end
end
