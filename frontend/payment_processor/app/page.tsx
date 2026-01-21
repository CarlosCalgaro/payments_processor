import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import Link from "next/link"

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background">
      <main className="flex flex-col items-center justify-center gap-8 text-center">
        <div className="flex flex-col items-center gap-4">
          <h1 className="text-4xl font-bold tracking-tight text-foreground">
            Payment Processor
          </h1>
          <p className="text-lg text-muted-foreground">
            Monitor and manage payment intents and outbox events
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <Card className="w-full max-w-sm">
            <CardHeader>
              <CardTitle>Payments</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-4">
              <p className="text-sm text-muted-foreground">
                View all payment intents and their statuses
              </p>
              <Link href="/payments">
                <Button className="w-full">View Payments</Button>
              </Link>
            </CardContent>
          </Card>

          <Card className="w-full max-w-sm">
            <CardHeader>
              <CardTitle>Outbox Events</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-col gap-4">
              <p className="text-sm text-muted-foreground">
                View all outbox events and their processing status
              </p>
              <Link href="/outbox-events">
                <Button className="w-full">View Events</Button>
              </Link>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  )
}
