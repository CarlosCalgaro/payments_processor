import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { fetchOutboxEvents } from "@/lib/api"
import { formatDistanceToNow } from "date-fns"

export const dynamic = "force-dynamic"

const statusColors: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
  pending: "secondary",
  processing: "outline",
  processed: "default",
  failed: "destructive",
}

export default async function OutboxEventsPage() {
  const events = await fetchOutboxEvents()

  return (
    <div className="space-y-6 p-6">
      <Card>
        <CardHeader>
          <CardTitle>Outbox Events</CardTitle>
        </CardHeader>
        <CardContent>
          {events.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              No outbox events found
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Event ID</TableHead>
                  <TableHead>Event Type</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Aggregate ID</TableHead>
                  <TableHead>Retries</TableHead>
                  <TableHead>Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {events.map((event) => (
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
                    <TableCell className="font-mono text-sm">
                      {event.aggregate_id}
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
