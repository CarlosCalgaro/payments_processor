require "test_helper"

class Api::V1::PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "creates payment intent and returns created" do
    payload = {
      payment_intent: {
        amount_cents: 1500,
        currency: "BRL",
        idempotency_key: "idem-#{SecureRandom.hex(4)}"
      }
    }

    assert_difference -> { PaymentIntent.count }, +1 do
      post "/api/v1/payments", params: payload, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal 1500, body["amount_cents"]
    assert_equal "BRL", body["currency"]
    assert_equal PaymentIntent::PENDING, body["status"]
  end

  test "returns unprocessable entity when validation fails" do
    payload = {
      payment_intent: {
        amount_cents: nil,
        currency: "BRL",
        idempotency_key: "idem-#{SecureRandom.hex(4)}"
      }
    }

    assert_no_difference -> { PaymentIntent.count } do
      post "/api/v1/payments", params: payload, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "prevents duplicate idempotency key insert" do
    idempotency_key = "idem-#{SecureRandom.hex(4)}"
    
    payload = {
      payment_intent: {
        amount_cents: 1500,
        currency: "BRL"
      }
    }

    # First request should succeed
    assert_difference -> { PaymentIntent.count }, +1 do
      post "/api/v1/payments", params: payload, headers: { "Idempotency-Key" => idempotency_key }, as: :json
    end
    assert_response :created
    first_response = JSON.parse(response.body)

    # Second request with same idempotency key should not create a new record
    assert_no_difference -> { PaymentIntent.count } do
      post "/api/v1/payments", params: payload, headers: { "Idempotency-Key" => idempotency_key }, as: :json
    end
    
    # Should return the original payment intent
    assert_response :ok
    second_response = JSON.parse(response.body)
    assert_equal first_response["id"], second_response["id"]
    assert_equal first_response["idempotency_key"], second_response["idempotency_key"]
  end

  test "confirm initiates payment confirmation" do
    payment_intent = create(:payment_intent, status: PaymentIntent::PENDING)
    idempotency_key = "confirm-#{SecureRandom.hex(4)}"

    assert_no_difference -> { PaymentIntent.count } do
      post "/api/v1/payments/#{payment_intent.id}/confirm", 
            headers: { "Idempotency-Key" => idempotency_key }, 
            as: :json
    end

    assert_response :accepted
    payment_intent.reload
    assert_equal PaymentIntent::PROCESSING, payment_intent.status
    assert_equal idempotency_key, payment_intent.confirmation_idempotency_key
  end

  test "confirm creates outbox event for payment confirmation" do
    payment_intent = create(:payment_intent, status: PaymentIntent::PENDING)
    idempotency_key = "confirm-#{SecureRandom.hex(4)}"

    assert_difference -> { OutboxEvent.count }, +1 do
      post "/api/v1/payments/#{payment_intent.id}/confirm", 
            headers: { "Idempotency-Key" => idempotency_key }, 
            as: :json
    end

    assert_response :accepted
    outbox_event = OutboxEvent.last
    assert_equal "PaymentIntentConfirmed", outbox_event.event_type
    assert_equal OutboxEvent::PENDING, outbox_event.status
    assert_equal payment_intent.id, outbox_event.aggregate_id
  end

  test "confirm is idempotent with same idempotency key" do
    payment_intent = create(:payment_intent, status: PaymentIntent::PENDING)
    idempotency_key = "confirm-#{SecureRandom.hex(4)}"

    # First confirm
    assert_difference -> { OutboxEvent.count }, +1 do
      post "/api/v1/payments/#{payment_intent.id}/confirm", 
            headers: { "Idempotency-Key" => idempotency_key }, 
            as: :json
    end
    assert_response :accepted

    # Second confirm with same idempotency key should not create new outbox event
    assert_no_difference -> { OutboxEvent.count } do
      post "/api/v1/payments/#{payment_intent.id}/confirm", 
            headers: { "Idempotency-Key" => idempotency_key }, 
            as: :json
    end
    assert_response :accepted
  end

  test "confirm returns 404 for non-existent payment intent" do
    idempotency_key = "confirm-#{SecureRandom.hex(4)}"

    assert_no_difference -> { OutboxEvent.count } do
      post "/api/v1/payments/99999/confirm", 
            headers: { "Idempotency-Key" => idempotency_key }, 
            as: :json
    end

    assert_response :not_found
  end

  test "confirm without idempotency key still returns accepted" do
    payment_intent = create(:payment_intent, status: PaymentIntent::PENDING)

    post "/api/v1/payments/#{payment_intent.id}/confirm", as: :json

    assert_response :accepted
    payment_intent.reload
    assert_nil payment_intent.confirmation_idempotency_key
  end
end
