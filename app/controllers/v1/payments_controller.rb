class V1::PaymentsController < ApplicationController


  def post

    render "Creating"
  end


  def confirm
    render "Confirming"
    
  end


  def refund
    render "Refunding"
    
  end
end
