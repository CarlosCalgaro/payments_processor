
class PaymentIntents::CreatePaymentIntentService < TransactionalService
  def initialize(amount_cents:, currency:, idempotency_key:)
    @amount_cents = amount_cents
    @currency = currency
    @idempotency_key = idempotency_key
  end

  def call
    PaymentIntent.create!(
      amount_cents: @amount_cents,
      currency: @currency,
      idempotency_key: @idempotency_key,
      status: PaymentIntent::PENDING
    )
  end
end