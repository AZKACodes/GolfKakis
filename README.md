# GolfKakis

GolfKakis is a Flutter application for discovering golf courses, managing tee-time bookings, and keeping golfer profile details in one place.

## App Overview

- Home experience with course discovery, quick actions, deals, announcements, and booking shortcuts.
- Booking flow covering slot selection, player/details capture, confirmation, success, booking overview, booking detail, and booking edits.
- Profile flows for phone/OTP/PIN authentication, account details, friends, language, and notification preferences.
- Shared session, device ID, API client, localization, theme, and reusable UI foundation widgets.

## Tech Stack

- Flutter / Dart
- Material 3
- REST API integration through `ApiClient`
- Local persistence through `shared_preferences`
- PDF/printing support for booking success output
- Contact, location, image/file picker, permission, URL launcher, and in-app webview integrations

## Configuration

The app defaults to the hosted API configured in `lib/features/foundation/network/api_config.dart`.

Override the backend when running locally:

```sh
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

## Development

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

Analyze the project:

```sh
flutter analyze
```
