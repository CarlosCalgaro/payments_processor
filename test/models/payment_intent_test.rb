require "test_helper"

class PaymentIntentTest < ActiveSupport::TestCase
  test "should not save payment intent without currency" do
    payment_intent = build(:payment_intent, currency: nil)
    assert_not payment_intent.save, "Saved the payment intent without currency"
  end

  test "should not save payment intent without status" do
    payment_intent = build(:payment_intent, status: nil)
    assert_not payment_intent.save, "Saved the payment intent without status"
  end

  test "should save payment intent with valid attributes" do
    payment_intent = build(:payment_intent)
    assert payment_intent.save, "Failed to save the payment intent with valid attributes"
  end

  test "should not save payment intent without amount_cents" do
    payment_intent = build(:payment_intent, amount_cents: nil)
    assert_not payment_intent.save, "Saved the payment intent without amount_cents"
  end

  test "should not save payment intent with non positive amount_cents" do
    payment_intent = build(:payment_intent, amount_cents: 0)
    assert_not payment_intent.save, "Saved the payment intent with non positive amount_cents"

    payment_intent.amount_cents = -100
    assert_not payment_intent.save, "Saved the payment intent with negative amount_cents"
  end

  test "should not save payment intent with invalid status" do
    payment_intent = build(:payment_intent, status: "invalid")
    assert_not payment_intent.save, "Saved the payment intent with an invalid status"
  end
end
