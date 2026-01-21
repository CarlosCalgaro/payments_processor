class Api::V1::OutboxEventsController < ApplicationController
  def index
    outbox_events = OutboxEvent.all
    
    # Filter by aggregate_id if provided
    if params[:aggregate_id].present?
      outbox_events = outbox_events.where(aggregate_id: params[:aggregate_id])
    end
    
    outbox_events = outbox_events.order(created_at: :desc)
    render json: outbox_events
  end
end
