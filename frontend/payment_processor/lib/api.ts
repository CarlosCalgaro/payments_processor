const API_BASE_URL = process.env.API_URL || "http://localhost:9001/api/v1"

export interface PaymentIntent {
  id: string
  amount_cents: number
  currency: string
  status: string
  idempotency_key: string
  confirmation_idempotency_key: string | null
  provider_payment_id: string | null
  created_at: string
  updated_at: string
}

export interface OutboxEvent {
  id: string
  event_id: string
  aggregate_id: string
  aggregate_type: string
  event_type: string
  status: string
  retry_count: number
  created_at: string
  updated_at: string
}

export async function fetchPayments(): Promise<PaymentIntent[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/payments`, {
      cache: "no-store",
    })
    if (!response.ok) throw new Error("Failed to fetch payments: " + response.statusText)
    const data = await response.json()
    return Array.isArray(data) ? data : []
  } catch (error) {
    console.error("Error fetching payments:", error)
    return []
  }
}

export async function fetchOutboxEvents(): Promise<OutboxEvent[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/outbox_events`, {
      cache: "no-store",
    })
    if (!response.ok) throw new Error("Failed to fetch outbox events")
    const data = await response.json()
    return Array.isArray(data) ? data : []
  } catch (error) {
    console.error("Error fetching outbox events:", error)
    return []
  }
}

export async function fetchPaymentById(id: string): Promise<PaymentIntent | null> {
  try {
    const response = await fetch(`${API_BASE_URL}/payments/${id}`, {
      cache: "no-store",
    })
    if (!response.ok) return null
    return await response.json()
  } catch (error) {
    console.error("Error fetching payment:", error)
    return null
  }
}

export async function fetchOutboxEventsByPaymentId(paymentId: string): Promise<OutboxEvent[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/outbox_events?aggregate_id=${paymentId}`, {
      cache: "no-store",
    })
    if (!response.ok) throw new Error("Failed to fetch outbox events")
    const data = await response.json()
    return Array.isArray(data) ? data : []
  } catch (error) {
    console.error("Error fetching outbox events:", error)
    return []
  }
}
