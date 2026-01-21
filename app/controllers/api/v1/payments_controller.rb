class Api::V1::PaymentsController < ApplicationController

  before_action :set_idempotency_key, only: [:post, :confirm, :refund]
  before_action :set_payment_intent, only: [:confirm, :refund, :show]

  def index
    payment_intents = PaymentIntent.all.order(created_at: :desc)
    render json: payment_intents
  end

  def show
    render json: @payment_intent
  end

  def post
    payment_intent = PaymentIntent.find_by(idempotency_key: @idempotency_key)

    return render json: payment_intent, status: :ok if payment_intent.present?

    payment_intent = PaymentIntents::CreatePaymentIntentService.call(
      amount_cents: payment_intent_params[:amount_cents],
      currency: payment_intent_params[:currency],
      idempotency_key: @idempotency_key
    )

    render json: payment_intent, status: :created
  end


  def confirm
    if @payment_intent && @idempotency_key && @payment_intent.confirmation_idempotency_key.nil?
      PaymentIntents::ConfirmPaymentIntentService.call(
        payment_intent_id: @payment_intent.id,
        idempotency_key: @idempotency_key
      )
    end

    render status: :accepted
  end

  def refund
    render "Refunding"
  end


  private

  def set_payment_intent
    @payment_intent = PaymentIntent.find(params[:id])
  end

  def set_idempotency_key
    @idempotency_key = request.headers["Idempotency-Key"]
  end

  def payment_intent_params
    params.require(:payment_intent).permit(
      :amount_cents,
      :currency,
    )
  end
end
