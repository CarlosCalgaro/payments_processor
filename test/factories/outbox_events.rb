FactoryBot.define do
  factory :outbox_event do
    event_id { nil }
    association :aggregate, factory: :payment_intent
    published_at { Time.current }
    status { "pending" }
    retry_count { 0 }
  end
end
