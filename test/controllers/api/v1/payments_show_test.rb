require "test_helper"

class Api::V1::PaymentsControllerTest < ActionDispatch::IntegrationTest

  test "get single payment returns payment details" do
    payment_intent = create(:payment_intent, status: PaymentIntent::PENDING)

    get "/api/v1/payments/#{payment_intent.id}", as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal payment_intent.id, body["id"]
    assert_equal payment_intent.amount_cents, body["amount_cents"]
    assert_equal payment_intent.currency, body["currency"]
  end

  test "get non-existent payment returns 404" do
    get "/api/v1/payments/invalid_id", as: :json

    assert_response :not_found
  end
end
