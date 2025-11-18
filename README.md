# SmartExpense

SmartExpense is a fully offline-first personal finance manager written in Flutter. It keeps every account, transaction, budget, and report on-device by using `sqflite`, so you can track money anywhere without needing a network connection. The UI is optimized for simple one-handed use with a dashboard-first flow and a floating action button for quick transaction capture.

## Features

- Track multiple accounts (Cash, Bank, etc.) with running balances and categorized transactions.
- Custom add-transaction flow with notes, categories, and a calculator-like numpad.
- Offline budgets per category with progress bars and quick-edit dialogs.
- Recurring transactions are processed on launch so subscriptions and bills never get missed.
- Trend and category reports powered by `fl_chart`, with daily/weekly/monthly/yearly tabs.
- Local CSV export helpers (permission-gated) for archiving outside the app.

## Tech Stack

- Flutter 3 / Dart 3 (Material 3 design system).
- Local persistence via `sqflite`, `path`, and `path_provider`.
- Currency/date formatting through `intl`.
- Data visualization with `fl_chart`.
- Permission handling via `permission_handler`.

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.3.3 (Dart ≥ 3.3.3).
- Xcode and CocoaPods for iOS, Android Studio + Android SDK for Android.
- A physical device or emulator/simulator.
** USE Android Emulator only 

### Setup

```bash
git clone <repo-url>
cd ProjectMobile
flutter pub get
```

### Run

```bash
flutter run          # picks the first connected device
flutter run -d ios   # explicitly target iOS Simulator
flutter run -d android
```

Hot reload works as expected; the local SQLite database lives under the app documents directory (`smart_expense.db`). Deleting the app (or `flutter clean` on some platforms) resets the data.

### Tests

```bash
flutter test
```

The default widget test lives in `test/widget_test.dart`. Add integration tests with `integration_test/` for end-to-end finance flows as needed.

## Project Structure

```
lib/
├── main.dart                # App bootstrap, recurring tx processing
├── main_navigation.dart     # Bottom navigation & FAB routing
├── theme.dart               # Centralized colors/typography
├── services/
│   └── database_helper.dart # SQLite schema and data helpers
├── models/                  # Account, Transaction, Budget, Recurring models
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_transaction_screen.dart
│   ├── budget_screen.dart
│   ├── reports_screen.dart
│   ├── recurring_transactions_screen.dart
│   └── settings_screen.dart
└── widgets/                 # Reusable cards, numpad, list tiles
```

## Data & Navigation Flow

- App launches with `SplashScreen`, initializes the database, and processes due recurring transactions before showing `MainNavigationScreen`.
- Bottom tabs: Dashboard (accounts + monthly log), Reports (pie charts), Budget Planning, Settings.
- FAB opens `AddTransactionScreen`; on save, dashboard refreshes via a `GlobalKey`.
- Budgets and reports share the same tabbed layout for daily/weekly/monthly/yearly periods (monthly is currently implemented for budgets).

## Contributing / Next Steps

- Extend settings with theme toggles, currency selection, or biometric locks.
- Wire up the CSV export helper with the `permission_handler` flow on Android/iOS.
- Add integration tests that validate recurring transaction processing and budget warnings.

Feel free to open issues or pull requests for enhancements, localization, or platform-specific polish.
