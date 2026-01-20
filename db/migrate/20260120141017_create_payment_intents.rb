class CreatePaymentIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_intents do |t|
      t.integer :amount_cents
      t.string :currency
      t.string :status
      t.string :idempotency_key

      t.timestamps
    end
  end
end
