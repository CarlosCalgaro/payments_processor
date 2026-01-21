"use client"

import { Badge } from "@/components/ui/badge"
import { TableCell, TableRow } from "@/components/ui/table"
import { PaymentIntent } from "@/lib/api"
import { useRouter } from "next/navigation"
import { formatDistanceToNow } from "date-fns"

interface PaymentRowProps {
  payment: PaymentIntent
  statusColors: Record<string, "default" | "secondary" | "destructive" | "outline">
}

function formatCurrency(cents: number, currency: string): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: currency,
    minimumFractionDigits: 2,
  }).format(cents / 100)
}

export default function PaymentRow({
  payment,
  statusColors,
}: PaymentRowProps) {
  const router = useRouter()

  const handleRowClick = () => {
    router.push(`/payments/${payment.id}`)
  }

  return (
    <TableRow
      onClick={handleRowClick}
      className="cursor-pointer hover:bg-muted/50 transition-colors"
    >
      <TableCell className="font-mono text-sm">{payment.id}</TableCell>
      <TableCell>
        {formatCurrency(payment.amount_cents, payment.currency)}
      </TableCell>
      <TableCell>
        <Badge variant={statusColors[payment.status] || "outline"}>
          {payment.status}
        </Badge>
      </TableCell>
      <TableCell className="font-mono text-sm">
        {payment.provider_payment_id ? (
          <span>{payment.provider_payment_id.substring(0, 12)}...</span>
        ) : (
          <span className="text-muted-foreground">—</span>
        )}
      </TableCell>
      <TableCell className="text-sm text-muted-foreground">
        {formatDistanceToNow(new Date(payment.created_at), { addSuffix: true })}
      </TableCell>
    </TableRow>
  )
}
