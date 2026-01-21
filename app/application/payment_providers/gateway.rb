class PaymentProviders::Gateway
  def process_payment(payment_intent)
    raise NotImplementedError, "Subclasses must implement the process_payment method"
  end
end