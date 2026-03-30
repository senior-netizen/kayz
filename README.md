# Courier Control System (Flutter MVP)

Operational control system for courier logistics in low-connectivity environments.

## Architecture

- Clean architecture style with domain/data/presentation separation under each feature.
- Riverpod for deterministic state management.
- Offline-first design using local repository abstraction + queued sync service.
- Mock REST/WebSocket-ready sync boundary via `MockSyncService`.

## Roles

- Admin: parcel creation, route filtering, dashboard metrics.
- Agent: assigned route, QR scan lifecycle progression, proof-of-delivery.
- Customer: no-login tracking by parcel ID or receiver phone.

## Demo flow

1. Admin opens dashboard and creates parcel.
2. Parcel ID and QR are generated instantly.
3. Parcel is assigned to route.
4. Agent scans QR repeatedly to progress lifecycle.
5. Customer tracks parcel by ID/phone and views timeline.
6. Agent confirms delivery with receiver name + signature.

## Routes & Pickup points

Routes:
- Harare → Zvishavane
- Harare → Masvingo
- Harare → Mberengwa

Pickup points:
- Kwame Mall
- Zvishavane CABS
- Masvingo CBD

## Notes

- Flutter SDK is required to run and test (`flutter pub get`, `flutter run`).
- In this environment, Flutter binaries may be unavailable.
