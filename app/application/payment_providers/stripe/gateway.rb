class PaymentProviders::Stripe::Gateway < PaymentProviders::Gateway
  
  FAILURE_RATE = 0.01
  
  def process_payment(payment_intent)
    # mocked implementation for processing payment with Stripe

    if rand < FAILURE_RATE
      raise Errors::PaymentError, "Stripe payment processing failed"
    end

    sleep(rand(1..5))

    {
      provider_payment_id: "stripe_#{SecureRandom.hex(10)}"
    }
  end
end