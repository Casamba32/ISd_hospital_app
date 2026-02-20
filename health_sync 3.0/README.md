# Hospital Management System - Flutter App

A complete hospital management mobile application built with Flutter.

## Features

- **User Authentication** (Login/Register)
- **Patient Dashboard**
  - Book appointments
  - View medical records
- **Admin/Staff Dashboard**
  - Manage billing
  - Pharmacy management
  - Reports (coming soon)
- **Account Settings**
  - Change password
  - Two-factor authentication
  - Notification preferences
- **Notifications Center**
- **Bills Management**

## Test Accounts

Use these credentials to test different user roles:

- **Patient**: `patient@test.com`
- **Doctor**: `doctor@test.com`
- **Staff/Admin**: `admin@test.com`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── models.dart          # Data models
├── services/
│   ├── backend_service.dart # Backend API simulation
│   └── in_memory_db.dart    # In-memory database
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── notifications_screen.dart
│   ├── account_settings_screen.dart
│   ├── bills_screen.dart
│   ├── records_screen.dart
│   ├── profile_screen.dart
│   ├── admin/
│   │   └── admin_dashboard_screen.dart
│   └── patient/
│       ├── patient_dashboard.dart
│       ├── book_appointment.dart
│       └── medical_records.dart
└── widgets/
    └── bottom_nav_bar.dart  # Reusable navigation bar
```

## How to Run

1. Make sure you have Flutter installed
2. Navigate to the project directory:
   ```bash
   cd hospital_app
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Features in Detail

### Patient Features
- Book appointments with doctors
- Select date and time for appointments
- View appointment history
- Access medical records

### Admin/Staff Features
- View pending billing invoices
- Manage pharmacy orders
- Access notifications
- View reports (placeholder)

### Common Features
- Notification center with appointment, billing, and pharmacy alerts
- Profile management
- Account settings with password change and 2FA
- Notification preferences customization
- Logout functionality

## Notes

- This is a demonstration app with simulated backend
- Data is stored in-memory and will reset when the app restarts
- All API calls are simulated with delays for realistic UX
