# instructor_app

The HelloFit **instructor** Flutter app — today's schedule, booking offers, check-in and
check-out, earnings.

Created 7 Nov 2026 when the single dual-mode app was split in two. The customer app is
`../customer_app/`.

## Current state

**A bare `flutter create` scaffold.** `lib/main.dart` is still the default counter demo
and there are no dependencies beyond `cupertino_icons`. Nothing here is real yet.

When this is picked up, port `core/` (network, token store, theme) from `../customer_app/`
rather than rewriting it. **No screens until the client supplies designs.**

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

Project instructions: `../claude.md` (index) and `../docs/`. History: `../worklog/`.
