require "test_helper"

class OutboxEventTest < ActiveSupport::TestCase
  test "generates event_id when blank" do
    outbox_event = build(:outbox_event, event_id: nil)

    outbox_event.save!

    assert_match(/[0-9a-f\-]{36}/i, outbox_event.event_id)
  end

  test "keeps provided event_id" do
    provided_id = "custom-id-123"
    outbox_event = build(:outbox_event, event_id: provided_id)

    outbox_event.save!

    assert_equal provided_id, outbox_event.event_id
  end

  test "requires aggregate presence" do
    outbox_event = build(:outbox_event, aggregate: nil)

    assert_raises(ActiveRecord::RecordInvalid) do
      outbox_event.save!
    end
  end
end
