class Payments::BaseJob < ApplicationJob
  retry_on ActiveRecord::Deadlocked

end