class PaymentProviders::Factory
  PROVIDERS = {
    stripe: PaymentProviders::Stripe::Gateway,
    pagseguro: PaymentProviders::Pagseguro::Gateway
  }

  def self.create
    provider = ENV.fetch('PAYMENT_PROVIDER', :stripe).downcase.to_sym
    
    gateway_class = PROVIDERS[provider]
    raise "Unsupported payment provider: #{provider}" unless gateway_class
    
    gateway_class.new
  end
end