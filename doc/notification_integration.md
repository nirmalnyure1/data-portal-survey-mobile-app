# Mobile push & notification inbox — integration guide

This guide is for **Android and iOS** apps integrating with the Data Portal API. It covers:

1. **FCM push delivery** (device registration + user preferences)
2. **In-app notification inbox** (persisted history, unread badge, mark-read)
3. **Deep linking** from push `data` payloads

For backend/server setup (Firebase credentials, NestJS modules), see [`PUSH_NOTIFICATIONS.md`](./PUSH_NOTIFICATIONS.md).  
For auth flows (Google/Apple token login), see [`MOBILE_AUTH.md`](./MOBILE_AUTH.md).

---

## Architecture at a glance

```
┌─────────────────┐     register token      ┌──────────────────┐
│  Mobile app     │ ───────────────────────▶│  PUT /devices/me │
│  (FCM SDK)      │                           │  + preferences   │
└────────┬────────┘                           └────────┬─────────┘
         │                                               │
         │  FCM push (title/body/data)                   │  persisted rows
         ▼                                               ▼
┌─────────────────┐                           ┌──────────────────┐
│  OS notification│                           │ user_notification │
│  tray           │                           │ (inbox API)       │
└─────────────────┘                           └──────────────────┘
```

**Important:** Push and inbox are separate:

| Layer | Gated by preferences? | Available when push off? |
|-------|----------------------|--------------------------|
| FCM push | Yes | No |
| In-app inbox | No | Yes — always saved for customer events |

Users who disable push still see order updates in the inbox.

---

## Prerequisites

### Mobile (Firebase)

1. Create/use the **same Firebase project** as the backend (`FIREBASE_CREDENTIALS` on the API).
2. Add your Android app (`google-services.json`) and/or iOS app (`GoogleService-Info.plist`).
3. Integrate **Firebase Cloud Messaging** in the native app or via React Native / Flutter FCM plugins.
4. Request notification permission (iOS; Android 13+).

### API

- Base URL: your API host (e.g. `https://api.example.com`).
- Auth: **`Authorization: Bearer <accessToken>`** on all endpoints below (mobile does not use cookies).
- Standard response envelope:

```json
{
  "statusCode": 200,
  "error": false,
  "message": "...",
  "data": { }
}
```

---

## Integration checklist

Use this as an implementation order:

- [ ] Generate a stable **`deviceId`** per app install (UUID in Keychain / EncryptedSharedPreferences).
- [ ] On login/register, send `device` with `fcmToken` **or** call `PUT /devices/me` immediately after auth.
- [ ] Listen for **FCM token refresh** → `PUT /devices/me` or `PATCH /devices/me`.
- [ ] On logout → `DELETE /devices/:deviceId`.
- [ ] Fetch **`GET /notification-preferences/me`** and expose toggles in Settings.
- [ ] On preference change → **`PATCH /notification-preferences/me`**.
- [ ] Build **inbox screen** using `GET /notifications/me` + unread badge from `GET /notifications/me/unread-count`.
- [ ] Handle push **`data.type`** for deep links (order detail, offer, etc.).
- [ ] When user opens a notification (push or inbox), call **`PATCH /notifications/me/:id/read`** when you have the inbox row id.

---

## 1. Device registration (FCM token)

One user can have **multiple devices** (phone + tablet). Each install needs its own `deviceId`.

### Device payload

| Field | Required | Description |
|-------|----------|-------------|
| `deviceId` | Yes | Stable UUID per install (you generate and persist) |
| `fcmToken` | Yes | FCM registration token from Firebase Messaging |
| `platform` | Yes | `"android"` or `"ios"` |
| `appVersion` | No | e.g. `"1.2.0"` |

### Option A — register during auth (recommended)

Include optional `device` (or `devices[]`) on:

- `POST /auth/verify-login`
- `POST /auth/register`
- `POST /auth/google/token`
- `POST /auth/apple/token`

```json
{
  "email": "user@example.com",
  "password": "...",
  "device": {
    "deviceId": "550e8400-e29b-41d4-a716-446655440000",
    "fcmToken": "<fcm-token>",
    "platform": "android",
    "appVersion": "1.0.0"
  }
}
```

New `deviceId` values are **appended**; existing ones get token/metadata updates.

### Option B — register after login

**Upsert (new install or full refresh):**

```http
PUT /devices/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "fcmToken": "<fcm-token>",
  "platform": "ios",
  "appVersion": "1.0.0"
}
```

**FCM token refresh only:**

```http
PATCH /devices/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "fcmToken": "<new-fcm-token>"
}
```

**List devices:**

```http
GET /devices/me
```

Response omits raw FCM tokens; each entry includes `deviceId`, `platform`, `enabled`, `hasFcmToken`, `lastSeenAt`.

**Unregister on logout:**

```http
DELETE /devices/:deviceId
```

Legacy alias: `PUT /devices/register` (same as `PUT /devices/me`).

After `PUT`/`PATCH` device, the backend syncs FCM **topic subscriptions** to match user preferences.

---

## 2. Notification preferences

Controls **FCM push only** (not the in-app inbox).

### Get preferences

```http
GET /notification-preferences/me
```

```json
{
  "data": {
    "pushEnabled": true,
    "marketingEnabled": true,
    "orderEnabled": true,
    "topics": {
      "offers": true,
      "order_updates": true
    }
  }
}
```

| Field | Effect |
|-------|--------|
| `pushEnabled` | Master switch — when `false`, no FCM to this user |
| `orderEnabled` | Order category + `order_updates` topic |
| `marketingEnabled` | Marketing category + `marketing` topic |
| `topics.offers` | Loyalty offers / promotional broadcasts |
| `topics.order_updates` | Order lifecycle pushes |

Known topic keys: `offers`, `order_updates`, `marketing`.

### Update preferences

```http
PATCH /notification-preferences/me
Content-Type: application/json

{
  "pushEnabled": true,
  "marketingEnabled": false,
  "topics": {
    "offers": false
  }
}
```

All fields are optional (partial update). Topic subscriptions are re-synced to Firebase automatically.

**Suggested Settings UI:**

- Master: “Push notifications” → `pushEnabled`
- Orders → `orderEnabled` (and/or `topics.order_updates`)
- Offers & promotions → `marketingEnabled` + `topics.offers`

---

## 3. In-app notification inbox

Persisted notification history. Use this for an in-app **Notifications** tab, bell icon, and unread badge — especially when the user has push disabled.

### List notifications

```http
GET /notifications/me?page=1&limit=20&unreadOnly=false
```

Query params:

| Param | Default | Description |
|-------|---------|-------------|
| `page` | `1` | Page number |
| `limit` | `20` | Page size |
| `unreadOnly` | `false` | When `true`, only unread rows |

```json
{
  "data": {
    "data": [
      {
        "id": "01932a1b-...",
        "userId": "...",
        "title": "Order confirmed",
        "body": "Your order ORD-1234 is confirmed.",
        "type": "order_status_changed",
        "category": "order",
        "data": {
          "type": "order_status_changed",
          "orderId": "...",
          "orderCode": "ORD-1234",
          "status": "CONFIRMED"
        },
        "readAt": null,
        "createdAt": "2026-06-23T10:00:00.000Z",
        "updatedAt": "2026-06-23T10:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 42,
      "currentPage": 1,
      "perpage": 20,
      "totalPages": 3
    }
  }
}
```

`readAt === null` means **unread**.

### Unread count (badge)

```http
GET /notifications/me/unread-count
```

```json
{
  "data": { "count": 3 }
}
```

Poll on app foreground or after handling a push. Suggested interval: 30–60s while app is active.

### Mark one read

```http
PATCH /notifications/me/:id/read
```

```json
{
  "data": {
    "id": "...",
    "readAt": "2026-06-23T10:05:00.000Z"
  }
}
```

### Mark all read

```http
PATCH /notifications/me/read-all
```

```json
{
  "data": { "updated": 3 }
}
```

---

## 4. FCM message shape

The backend sends **notification + data** messages:

| FCM field | Content |
|-----------|---------|
| `notification.title` | Human-readable title |
| `notification.body` | Human-readable body |
| `data` | String key/value map for routing (all values are strings) |

Android uses channel id `default` unless the backend sets `androidChannelId`.  
iOS uses default sound; badge is set when provided server-side.

### Handling in the app

**Foreground:** show an in-app banner or refresh inbox + unread count.  
**Background / killed:** OS shows the tray notification; handle tap in your FCM / notification-open handler.

Pseudo-flow:

```text
onMessageReceived(message):
  if app in foreground:
    show in-app UI OR rely on inbox poll
  else:
    OS displays notification (notification payload)

onNotificationOpened(message):
  route = deepLinkFromData(message.data)
  navigate(route)
  optionally refresh inbox
```

**Android:** create a `default` notification channel before displaying.  
**iOS:** request `UNUserNotificationCenter` authorization; handle `userNotificationCenter:didReceiveNotificationResponse:`.

---

## 5. Notification types & deep linking

Use `data.type` (and related ids) to route. All `data` values are **strings**.

| `data.type` | Typical `data` keys | Suggested screen |
|-------------|---------------------|------------------|
| `order_created` | `orderId`, `orderCode`, `status` | Order detail |
| `order_status_changed` | `orderId`, `orderCode`, `status`, `previousStatus` | Order detail |
| `refund_status_changed` | `refundId`, `orderId`, `orderCode`, `status` | Order / refund detail |
| `dispute_status_changed` | `disputeId`, `orderId`, `orderCode`, `status` | Dispute detail |
| `booking_status_changed` | `bookingId`, `status` | Booking detail |
| `loyalty_points_awarded` | `points`, `reason` | Loyalty / wallet |
| `loyalty_offer_active` | `offerId`, `offerName` | Offer detail |

`category` on inbox rows: `order` | `marketing` | `general` — useful for filtering tabs.

Example deep-link helper (pseudocode):

```typescript
function routeFromNotificationData(data: Record<string, string>): string | null {
  switch (data.type) {
    case 'order_created':
    case 'order_status_changed':
      return data.orderId ? `/orders/${data.orderId}` : null;
    case 'loyalty_offer_active':
      return data.offerId ? `/offers/${data.offerId}` : null;
    case 'booking_status_changed':
      return data.bookingId ? `/bookings/${data.bookingId}` : null;
    default:
      return '/notifications';
  }
}
```

When the user opens from the **inbox list**, you already have the inbox row `id` — call `PATCH /notifications/me/:id/read` after navigation.

When opened from a **push only**, you may not have the inbox row id; refresh the inbox list or match by `type` + `orderId` + recent `createdAt`.

---

## 6. Lifecycle flows

### App launch (logged in)

```text
1. GET /notification-preferences/me     → sync Settings toggles
2. GET /notifications/me/unread-count   → tab bar badge
3. If FCM token changed since last sync:
     PUT /devices/me { deviceId, fcmToken, platform, appVersion }
```

### Login / register

```text
1. Auth request with optional device { deviceId, fcmToken, platform }
   OR auth then PUT /devices/me
2. GET /notification-preferences/me
3. GET /notifications/me/unread-count
```

### FCM `onNewToken`

```text
PATCH /devices/me { deviceId, fcmToken }
  — or PUT /devices/me if device not registered yet
```

### Logout

```text
1. DELETE /devices/:deviceId
2. Clear local access token
3. Delete FCM token locally if your SDK supports it
```

### User toggles “Offers” off in Settings

```text
PATCH /notification-preferences/me { topics: { offers: false } }
→ backend unsubscribes device from FCM topic user_topic_offers
→ inbox still receives offer rows (history); only push stops
```

---

## 7. Events that trigger notifications

These are sent automatically by the backend (`CustomerPushNotificationService`):

| Domain | Event | Push topic/category | Inbox |
|--------|-------|---------------------|-------|
| Orders | Created | `order` / `order_updates` | Yes |
| Orders | Status change | `order` / `order_updates` | Yes |
| Refunds | Approved / refunded / rejected | `order` / `order_updates` | Yes |
| Disputes | Resolved / rejected | `order` / `order_updates` | Yes |
| Bookings | Confirmed / cancelled / completed | `order` / `order_updates` | Yes |
| Loyalty | Points awarded | `order` or `marketing` | Yes |
| Referrals | Bonus awarded | `marketing` / `offers` | Yes |
| Loyalty offers | New active offer | `marketing` / `offers` (topic broadcast) | Yes |

**Not sent via push/inbox:** login OTP, password reset emails, staff/POS dashboard events.

---

## 8. Error handling & edge cases

| Situation | Behavior |
|-----------|----------|
| Invalid/expired FCM token | Backend disables token; app should re-register on next `onNewToken` |
| `PUSH_NOTIFICATIONS_ENABLED=false` on server | Push silently skipped; inbox still works |
| User disables push | No FCM; inbox APIs unchanged |
| Multiple devices | Push goes to all enabled devices; one inbox per user |
| Token refresh without `deviceId` | Always persist `deviceId` locally before any API call |

HTTP errors use the same `{ statusCode, error, message }` shape. `401` → refresh login.

---

## 9. Minimal API reference

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| `PUT` | `/devices/me` | Bearer | Register/update device + FCM token |
| `PATCH` | `/devices/me` | Bearer | Update FCM token for existing device |
| `GET` | `/devices/me` | Bearer | List registered devices |
| `DELETE` | `/devices/:deviceId` | Bearer | Unregister device |
| `GET` | `/notification-preferences/me` | Bearer | Get push preferences |
| `PATCH` | `/notification-preferences/me` | Bearer | Update push preferences |
| `GET` | `/notifications/me` | Bearer | Paginated inbox |
| `GET` | `/notifications/me/unread-count` | Bearer | Unread badge count |
| `PATCH` | `/notifications/me/:id/read` | Bearer | Mark one read |
| `PATCH` | `/notifications/me/read-all` | Bearer | Mark all read |

Auth endpoints with optional `device` / `devices`: see [`MOBILE_AUTH.md`](./MOBILE_AUTH.md).

---

## 10. Testing

1. **Device registration:** after login, `GET /devices/me` should list your `deviceId` with `hasFcmToken: true`.
2. **Push:** place an order or change order status → notification appears on device (if preferences allow).
3. **Inbox:** `GET /notifications/me` shows the same event with `readAt: null`.
4. **Preferences:** set `pushEnabled: false` → no push, inbox still populated.
5. **Mark read:** `PATCH .../read` → `readAt` set; unread count decreases.

Use Firebase Console “Send test message” only for SDK wiring; production payloads come from the API.

---

## Related docs

- [`MOBILE_AUTH.md`](./MOBILE_AUTH.md) — Google/Apple token login, Bearer auth, device on auth
- [`PUSH_NOTIFICATIONS.md`](./PUSH_NOTIFICATIONS.md) — server setup, NestJS inject APIs, backend event list