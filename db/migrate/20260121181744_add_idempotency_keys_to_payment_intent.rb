class AddIdempotencyKeysToPaymentIntent < ActiveRecord::Migration[8.1]
  def change
    add_column :payment_intents, :confirmation_idempotency_key, :string
    add_column :payment_intents, :refund_idempotency_key, :string
  end
end
