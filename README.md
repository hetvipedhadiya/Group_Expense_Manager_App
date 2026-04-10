# Group Expense Manager (Offline-First)

A mobile application for managing group events and splitting expenses, built with Flutter.
This app has been fully migrated from a cloud-based SQL Server architecture to an offline-first architecture using local SQLite.

## Features
- **User Authentication**: Local signup and login mapping to isolated environments per host.
- **Event Management**: Create, edit, and delete events.
- **Member Management**: Add and track members for specific events.
- **Transaction Tracking**: Log income and expenses paid by members.
- **Expense Reporting**: View overall aggregate reports, per-member breakdowns, and visual pie charts.
- **PDF Export**: Generate and download detailed PDF reports of expenses.
- **Offline First**: All data is stored locally on the device using SQLite, ensuring 100% functionality without the internet.

## Tech Stack
- **Frontend**: Flutter
- **Local Database**: SQLite (via `sqflite`)
- **State/Dependency**: `shared_preferences`, `intl`, `fl_chart`, `pdf`

## How to Run

1. Ensure you have the Flutter SDK installed on your system.
2. Clone this repository.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on an emulator or physical device:
   ```bash
   flutter run
   ```
   Or build the debug APK:
   ```bash
   flutter build apk --debug
   ```

## Architecture Notes
The app implements a standard Repository pattern for data access. 
- `DatabaseHelper`: Manages SQLite schemas and table initialization.
- **Repositories**: `UserRepository`, `EventRepository`, `PersonRepository`, and `TransactionRepository` handle all CRUD operations natively.
- **Services**: `ExpenseService` encapsulates the business logic for real-time reporting metrics calculation.
