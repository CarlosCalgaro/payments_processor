require "test_helper"

class PaymentIntents::CreatePaymentIntentServiceTest < ActiveSupport::TestCase
  test "creates a payment intent" do
    idempotency_key = "idem-#{SecureRandom.hex(4)}"

    assert_difference -> { PaymentIntent.count }, +1 do
      @payment_intent = PaymentIntents::CreatePaymentIntentService.call(
        amount_cents: 2000,
        currency: "USD",
        idempotency_key: idempotency_key
      )
    end

    assert_equal 2000, @payment_intent.amount_cents
    assert_equal "USD", @payment_intent.currency
    assert_equal idempotency_key, @payment_intent.idempotency_key
  end

  test "raises when validation fails" do
    assert_raises(ActiveRecord::RecordInvalid) do
      PaymentIntents::CreatePaymentIntentService.call(
        amount_cents: nil,
        currency: "USD",
        idempotency_key: "idem-#{SecureRandom.hex(4)}"
      )
    end
  end
end
