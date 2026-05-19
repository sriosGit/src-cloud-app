# SRC Cloud Mobile

Mobile client for [SRC Cloud](https://src.cloud) — personal cloud storage with AI assistant, built with Flutter for iOS and Android.

## Features

- **File browser** — list and grid views, folder navigation, starring, and search
- **Photo gallery** — photos organized by month with filter support
- **Shared links** — manage public share links with expiry tracking and clipboard copy
- **Galleta AI** — built-in AI assistant chat with streaming message UI
- **Dashboard** — storage quota visualization and recent files at a glance
- **Auth** — OAuth2 login with automatic JWT refresh via interceptors
- **Themes** — light and dark mode with warm terracotta accent palette

## Tech stack

| Layer | Library |
|---|---|
| State management | `provider` |
| HTTP client | `dio` with interceptors |
| Secure storage | `flutter_secure_storage` |
| Fonts | `google_fonts` |
| Image caching | `cached_network_image` |
| Preferences | `shared_preferences` |
| Localization | `intl` |

## Project structure

```
lib/
├── core/
│   ├── api.dart              # Dio client, token injection, 401 refresh
│   └── secure_storage.dart   # Keychain / EncryptedSharedPrefs wrapper
├── models/
│   ├── file_item.dart
│   ├── share.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── shell_screen.dart      # Bottom nav shell
│   ├── dashboard_screen.dart
│   ├── archivos_screen.dart   # File browser
│   ├── fotos_screen.dart      # Photo gallery
│   ├── compartidos_screen.dart
│   └── galleta_screen.dart    # AI assistant
├── widgets/
│   ├── file_thumb.dart
│   ├── galleta_mark.dart      # Dog mascot (CustomPaint)
│   └── preview_sheet.dart
└── theme.dart
```

## Getting started

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Analyze
flutter analyze

# Test
flutter test
```

Requires Flutter 3.22+ (managed via `mise` in this repo).

## Backend

The app connects to the SRC Cloud API (`/api/auth/login`, `/api/files/`, `/api/shares/`, `/api/galleta/chat`). Set the base URL in `lib/core/api.dart` before building.
