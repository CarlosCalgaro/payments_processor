class CreateOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outbox_events do |t|
      t.string :event_id
      t.references :aggregate, polymorphic: true, null: false
      t.datetime :published_at
      t.string :status
      t.integer :retry_count

      t.timestamps
    end
  end
end
