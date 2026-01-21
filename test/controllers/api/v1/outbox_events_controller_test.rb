require "test_helper"

class Api::V1::OutboxEventsControllerTest < ActionDispatch::IntegrationTest
  test "index returns all outbox events" do
    payment_intent = create(:payment_intent)
    event1 = create(:outbox_event, aggregate: payment_intent, status: OutboxEvent::PENDING)
    event2 = create(:outbox_event, aggregate: payment_intent, status: OutboxEvent::PROCESSED)

    get "/api/v1/outbox_events", as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body.length
  end

  test "index filters by aggregate_id" do
    payment_intent1 = create(:payment_intent)
    payment_intent2 = create(:payment_intent)
    
    event1 = create(:outbox_event, aggregate: payment_intent1)
    event2 = create(:outbox_event, aggregate: payment_intent2)

    get "/api/v1/outbox_events?aggregate_id=#{payment_intent1.id}", as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 1, body.length
    assert_equal event1.id, body[0]["id"]
  end

  test "index returns empty array when no events match filter" do
    payment_intent = create(:payment_intent)

    get "/api/v1/outbox_events?aggregate_id=#{payment_intent.id}", as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 0, body.length
  end
end
