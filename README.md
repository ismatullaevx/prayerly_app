# Prayerly

Prayerly is a simple, beautiful, and localized Flutter application for tracking daily Islamic prayers. It focuses on privacy, simplicity, and core functionalities without ads, cloud sync, or unnecessary complexities.

## Features
- **Real Prayer Times**: Calculates precise daily prayer times using geolocation and standard calculation methods.
- **Local Notifications**: Automatic, offline alerts for every prayer, generated via `flutter_local_notifications`.
- **Prayer Tracking**: Tap to check off completed prayers. Data is stored securely offline using Hive.
- **Themes**: Soft Light and Dark themes that automatically follow system settings.
- **Localization**: Supports English and Russian.
- **Onboarding**: A clean, single-screen onboarding flow requesting necessary permissions gracefully.

## Tech Stack
- Flutter & Dart
- **State Management**: Riverpod (`flutter_riverpod`)
- **Persistence**: Hive (for daily records) & SharedPreferences (for simple settings)
- **Notifications**: `flutter_local_notifications`
- **Location**: `geolocator` & `geocoding`
- **Prayer Calculations**: `adhan`

## Project Structure
- `lib/core/` - Global providers, themes, and localization logic.
- `lib/models/` - Data models (Prayer, PrayerRecord, etc.).
- `lib/screens/` - UI screens (Home, History, Settings, Onboarding).
- `lib/services/` - Background services like Hive caching and Notifications.
- `lib/widgets/` - Reusable UI components.

## Setup Instructions
1. **Clone the repository.**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate App Icon & Splash Screen**:
   Place your desired icon image at `assets/icon.png`, then run:
   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```
4. **Run the App**:
   ```bash
   flutter run
   ```

## Build Instructions (Release)
- **Android**: `flutter build apk --release` or `flutter build appbundle --release`
- **iOS**: `flutter build ipa`

## Permissions
Prayerly requires two permissions to function properly:
- **Location**: To calculate accurate prayer times using the `adhan` library.
- **Notifications**: To schedule local alarms when prayer times occur.

## Troubleshooting
If `flutter analyze` shows any minor warnings regarding missing assets, ensure you've placed `icon.png` in the `assets/` directory.

---
_Keep it simple. Keep it Prayerly._
