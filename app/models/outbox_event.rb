class OutboxEvent < ApplicationRecord
  belongs_to :aggregate, polymorphic: true
end
