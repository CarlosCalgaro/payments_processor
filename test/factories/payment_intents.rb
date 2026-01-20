FactoryBot.define do
  factory :payment_intent do
    amount_cents { 1000 }
    currency { "BRL" }
    status { PaymentIntent::PENDING }
    idempotency_key { SecureRandom.hex(8) }
  end
end
