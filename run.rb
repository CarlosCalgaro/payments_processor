

pi = PaymentIntent.create!(amount_cents: 1000, currency: 'usd', idempotency_key: 'akey_123')
OutboxEvent.create!(aggregate: pi, status: OutboxEvent::PENDING)

# First thread holds the lock
thread1 = Thread.new do
  OutboxEvent.transaction do
    oe = OutboxEvent.lock.first
    puts "Thread 1: Locked record #{oe.id}"
    sleep(5)  # Hold lock for 5 seconds
    oe.update!(status: OutboxEvent::PROCESSED)
    puts "Thread 1: Updated record"
  end
end

sleep(0.5)  # Ensure thread1 acquires lock first

# Second thread tries to acquire the same lock - this will fail/timeout
thread2 = Thread.new do
  begin
    OutboxEvent.transaction do
      puts "Thread 2: Attempting to lock record"
      oe = OutboxEvent.lock.first  # This will block waiting for thread1's lock
      puts "Thread 2: Locked record #{oe.id}"
      oe.update!(status: OutboxEvent::FAILED)
    end
  rescue ActiveRecord::StatementInvalid => e
    puts "Thread 2: Lock failure! #{e.message}"
  end
end

thread1.join
thread2.join
