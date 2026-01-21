
class TransactionalService < Service
  def call
    ActiveRecord::Base.transaction do
      yield
    end
  end
end