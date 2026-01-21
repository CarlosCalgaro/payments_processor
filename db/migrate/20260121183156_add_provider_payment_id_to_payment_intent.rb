class AddProviderPaymentIdToPaymentIntent < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_intents, :provider_payment_id, :string
  end
end
