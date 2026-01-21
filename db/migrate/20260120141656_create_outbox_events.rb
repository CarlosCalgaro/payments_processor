class CreateOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outbox_events do |t|
      t.string :event_id
      t.references :aggregate, polymorphic: true, null: false
      t.string :status
      t.integer :retry_count, default: 0

      t.timestamps
    end
  end
end
