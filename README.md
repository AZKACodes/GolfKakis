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

The default environment is `staging`, which currently uses:

```text
https://golfergo-api.onrender.com
```

Override the backend when running locally:

```sh
flutter run \
  --flavor staging \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://your-api.example.com
```

Run the staging flavor against the default staging/dev API:

```sh
flutter run \
  --flavor staging \
  --dart-define=APP_ENV=staging
```

Run the production flavor once the production API is available:

```sh
flutter run \
  --flavor production \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://your-production-api.example.com
```

Flavor app IDs:

- Android staging: `com.ezackly.golfkakis.staging`
- Android production: `com.ezackly.golfkakis`
- iOS staging: `com.ezackly.golfkakis.staging`
- iOS production: `com.ezackly.golfkakis`

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

## Release

Android release builds require a production upload keystore. Copy
`android/key.properties.example` to `android/key.properties`, fill in the
keystore values, and keep the real `android/key.properties` and keystore file
out of git.

Build Android for Play Store upload:

```sh
flutter build appbundle \
  --flavor production \
  --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://your-production-api.example.com
```

Build Android staging for internal testing:

```sh
flutter build apk \
  --flavor staging \
  --debug \
  --dart-define=APP_ENV=staging
```

Build iOS staging without code signing:

```sh
flutter build ios \
  --flavor staging \
  --release \
  --no-codesign \
  --dart-define=APP_ENV=staging
```

Build iOS production from Xcode or CI with the App Store team/provisioning
profile configured for `com.ezackly.golfkakis`:

```sh
flutter build ios \
  --flavor production \
  --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://your-production-api.example.com
```
