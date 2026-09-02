# Push Notifications (FCM)

Backend push notifications use **Firebase Cloud Messaging** via `firebase-admin`. The module is injectable anywhere in the NestJS app.

## Setup

1. In Firebase Console, create a service account key (Project settings → Service accounts).
2. Add to `.env`:

```env
PUSH_NOTIFICATIONS_ENABLED=true
FIREBASE_CREDENTIALS=<base64-encoded-service-account-json>
```

Encode your Firebase service account JSON file:

```bash
base64 -w 0 path/to/service-account.json
```

3. Restart the API. When `PUSH_NOTIFICATIONS_ENABLED=false`, send methods return gracefully without throwing.

## Device registration

Mobile clients must register FCM tokens (see `docs/MOBILE_AUTH.md`):

- `PUT /devices/register` after login and on FCM token refresh
- Or include optional `device` / `devices` on auth endpoints

Each new `deviceId` is stored automatically; existing ones get token/metadata updates.

## User preferences

Authenticated users manage preferences at:

- `GET /notification-preferences/me`
- `PATCH /notification-preferences/me`

```json
{
  "pushEnabled": true,
  "marketingEnabled": true,
  "orderEnabled": true,
  "topics": {
    "offers": true,
    "order_updates": true
  }
}
```

- `pushEnabled` — master switch
- `marketingEnabled` — marketing category + `marketing` topic
- `orderEnabled` — order category + `order_updates` topic
- `topics` — per-topic booleans (e.g. `offers`)

Topic subscriptions are synced to Firebase when preferences change or a device is registered.

FCM topic names use the prefix `user_topic_` (e.g. `offers` → `user_topic_offers`).

## Inject and send from any module

```typescript
import { PushNotificationService } from 'src/infra/push-notification/push-notification.service';

@Injectable()
export class OrderService {
  constructor(private readonly push: PushNotificationService) {}

  async notifyOrderReady(userId: string, orderId: string) {
    await this.push.sendToUser(
      userId,
      {
        title: 'Order ready',
        body: 'Your order is ready for pickup.',
        data: { orderId, type: 'order_ready' },
      },
      { category: 'order', topic: 'order_updates' },
    );
  }
}
```

Import `PushNotificationModule` in your feature module:

```typescript
@Module({
  imports: [PushNotificationModule],
  // ...
})
export class OrderModule {}
```

## Send APIs

| Method | Description |
|--------|-------------|
| `sendToUser(userId, payload, options?)` | One user (all enabled devices) |
| `sendToUsers(userIds, payload, options?)` | Multiple users |
| `sendToTopic(topic, payload, options?)` | Users opted into topic |
| `sendBroadcast(payload, filter?)` | All users (optional `userIds` filter) |
| `syncUserTopicSubscriptions(userId)` | Re-sync FCM topic subscriptions |

### Payload

```typescript
{
  title: string;
  body: string;
  imageUrl?: string;
  data?: Record<string, string>;
  androidChannelId?: string;
  badge?: number;
}
```

### Options

```typescript
{
  category?: 'marketing' | 'order' | 'general';
  topic?: string;           // preference key, e.g. 'offers'
  bypassPreferences?: boolean; // critical alerts only
}
```

### Examples

**Marketing to topic subscribers:**

```typescript
await push.sendToTopic(
  'offers',
  { title: 'Weekend deal', body: '20% off today only' },
  { category: 'marketing', topic: 'offers' },
);
```

**Broadcast to all opted-in users:**

```typescript
await push.sendBroadcast(
  { title: 'Maintenance', body: 'App back online shortly' },
  { category: 'general' },
);
```

**Critical alert (ignore preferences):**

```typescript
await push.sendToUser(
  userId,
  { title: 'Security alert', body: 'New login detected' },
  { bypassPreferences: true },
);
```

## Invalid tokens

When FCM reports `registration-token-not-registered` or `invalid-registration-token`, the token is automatically disabled in `user_device`.

## Integrated backend events

`CustomerPushNotificationService` sends pushes automatically from these flows (best-effort; never blocks the main transaction):

| Domain | Trigger | Recipient | Category |
|--------|---------|-----------|----------|
| Orders | Order created (`notifyOrderCreated`) | Customer | `order` / `order_updates` |
| Orders | Status change (`update`, `notifyOrderStatusChanged`) | Customer | `order` / `order_updates` |
| Refunds | Status → APPROVED / REFUNDED / REJECTED | Requesting user | `order` / `order_updates` |
| Disputes | Status → RESOLVED / REJECTED | User who opened dispute | `order` / `order_updates` |
| Bookings | Status → CONFIRMED / CANCELLED / COMPLETED | Booking user | `order` / `order_updates` |
| Loyalty | Registration welcome bonus | New user | `marketing` |
| Loyalty | Points earned on delivered order | Customer | `order` / `order_updates` |
| Loyalty | Birthday bonus | Customer | `marketing` |
| Referrals | Referrer/referred bonus on first completed order | Both users | `marketing` / `offers` |
| Loyalty offers | New or newly active offer | Topic `offers` broadcast | `marketing` / `offers` |

**Not pushed:** auth OTP, password reset, franchise dashboard WebSocket events, print jobs, subscriber emails.

To add custom pushes in new features, inject `CustomerPushNotificationService` or `PushNotificationService` and import `PushNotificationModule`.
