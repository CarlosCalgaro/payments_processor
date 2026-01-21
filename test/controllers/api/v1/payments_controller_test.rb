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
end
