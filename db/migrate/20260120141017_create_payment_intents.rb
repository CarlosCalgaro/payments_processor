class CreatePaymentIntents < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_intents do |t|
      t.integer :amount_cents, required: true
      t.string :currency, required: true, default: 'BRL'
      t.string :status, required: true, default: 'pending'
      t.string :idempotency_key, required: false

      t.timestamps
    end
  end
end
