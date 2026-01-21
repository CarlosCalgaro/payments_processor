import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { fetchPaymentById, fetchOutboxEventsByPaymentId } from "@/lib/api"
import { formatDistanceToNow } from "date-fns"
import Link from "next/link"
import { ArrowLeft } from "lucide-react"

export const dynamic = "force-dynamic"

const statusColors: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
  pending: "secondary",
  processing: "outline",
  succeeded: "default",
  failed: "destructive",
}

function formatCurrency(cents: number, currency: string): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: currency,
    minimumFractionDigits: 2,
  }).format(cents / 100)
}

export default async function PaymentDetailPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const payment = await fetchPaymentById(id)
  const outboxEvents = await fetchOutboxEventsByPaymentId(id)

  if (!payment) {
    return (
      <div className="space-y-6 p-6">
        <Link href="/payments">
          <Button variant="outline" size="sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Payments
          </Button>
        </Link>
        <Card>
          <CardContent className="py-8">
            <div className="text-center text-muted-foreground">
              Payment not found
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6 p-6">
      <Link href="/payments">
        <Button variant="outline" size="sm">
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to Payments
        </Button>
      </Link>

      <Card>
        <CardHeader>
          <CardTitle>Payment Details</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-muted-foreground">Payment ID</p>
              <p className="font-mono text-sm">{payment.id}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Status</p>
              <Badge variant={statusColors[payment.status] || "outline"}>
                {payment.status}
              </Badge>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Amount</p>
              <p className="font-semibold">
                {formatCurrency(payment.amount_cents, payment.currency)}
              </p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Currency</p>
              <p className="font-semibold">{payment.currency}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Idempotency Key</p>
              <p className="font-mono text-sm">{payment.idempotency_key}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Confirmation Idempotency Key</p>
              <p className="font-mono text-sm">
                {payment.confirmation_idempotency_key || <span className="text-muted-foreground">—</span>}
              </p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Provider Payment ID</p>
              <p className="font-mono text-sm">
                {payment.provider_payment_id || <span className="text-muted-foreground">—</span>}
              </p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Created</p>
              <p className="text-sm">
                {formatDistanceToNow(new Date(payment.created_at), { addSuffix: true })}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Related Outbox Events</CardTitle>
        </CardHeader>
        <CardContent>
          {outboxEvents.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              No outbox events found for this payment
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Event ID</TableHead>
                  <TableHead>Event Type</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Retries</TableHead>
                  <TableHead>Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {outboxEvents.map((event) => (
                  <TableRow key={event.id}>
                    <TableCell className="font-mono text-sm">
                      {event.event_id.substring(0, 8)}...
                    </TableCell>
                    <TableCell className="font-medium">
                      {event.event_type}
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusColors[event.status] || "outline"}>
                        {event.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-center">
                      {event.retry_count > 0 && (
                        <Badge variant="outline">{event.retry_count}</Badge>
                      )}
                      {event.retry_count === 0 && (
                        <span className="text-muted-foreground">0</span>
                      )}
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {formatDistanceToNow(new Date(event.created_at), { addSuffix: true })}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
