class AddEventTypeToOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :outbox_events, :event_type, :string
  end
end
