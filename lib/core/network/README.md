# LifeLink Mobile API Services

This directory contains all the API service files for connecting the Flutter mobile app to the Laravel backend.

## Available Services

### 1. `api_client.dart`
- Base HTTP client configuration using Dio
- Automatic token injection for authenticated requests
- Platform-aware base URLs (emulator vs real device)

### 2. `auth_service.dart`
- User authentication (login, logout)
- Token management with SharedPreferences
- Mobile-specific login endpoint: `/api/mobile/login`

### 3. `donation_service.dart`
- Blood donation appointments
- Home and hospital donations
- Blood types and hospitals data
- Key endpoints:
  - `GET /blood/home_donation`
  - `POST /blood/home_appointment`
  - `GET /blood/hospital_donation`
  - `POST /hospital/appointments`

### 4. `donor_service.dart`
- Donor dashboard and profile data
- Donation history and appointments
- Certificates and ratings
- Key endpoints:
  - `GET /donor/dashboard`
  - `GET /donor/my-donations`
  - `GET /donor/my-appointments`

### 5. `organ_donation_service.dart`
- Living organ donation
- After-death organ pledges
- Key endpoints:
  - `POST /organ/living-donor`
  - `POST /organ/after-death-pledge`

### 6. `rewards_service.dart`
- Rewards and gamification
- XP system and shop
- Blood heroes leaderboard
- Key endpoints:
  - `GET /donor/rewards`
  - `GET /donor/rewards/shop`
  - `POST /donor/rewards/purchase`

### 7. `financial_service.dart`
- Financial donations
- Patient cases
- Key endpoints:
  - `POST /financial-donations`
  - `GET /patient-cases`

### 8. `quiz_service.dart`
- Educational quizzes
- Mini-games
- Progress tracking
- Key endpoints:
  - `GET /quiz/questions/{level}`
  - `POST /quiz/answer-question`
  - `POST /mini-game/play`

### 9. `settings_service.dart`
- User profile management
- Medical information
- Notification preferences
- Key endpoints:
  - `GET /settings/profile`
  - `PUT /settings/profile`
  - `GET /settings/medical`

### 10. `support_service.dart`
- Customer support tickets
- Key endpoints:
  - `POST /support/tickets`
  - `GET /support/tickets`

### 11. `public_service.dart`
- Public data (no auth required)
- System settings and statistics
- Key endpoints:
  - `GET /system-settings`
  - `GET /public/donation-stats`
  - `GET /articles`

## Usage Example

```dart
import '../core/network/donation_service.dart';

// Get available home donations
final donations = await DonationService.getHomeDonations();

// Create a new appointment
final appointmentData = {
  'hospital_name': 'General Hospital',
  'appointment_date': '2024-01-15',
  'appointment_time': '10:00',
  // ... other fields
};
final result = await DonationService.createHomeAppointment(appointmentData);
```

## Error Handling

All services use the centralized error handling through `ApiHelper`:

```dart
import '../core/utils/api_helper.dart';

final response = await ApiHelper.handleRequest(
  () => DonationService.getHomeDonations(),
  (data) => data, // Transform response data if needed
);

if (response.success) {
  // Handle success
  print(response.data);
} else {
  // Handle error
  print(response.error);
}
```

## Configuration

The API base URL is automatically configured based on the platform:
- **Web**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000`
- **Real Device**: Set via `api_base_url` in SharedPreferences

## Authentication

Authentication tokens are automatically injected into requests:
1. Login via `AuthService.login()`
2. Token stored in SharedPreferences
3. Subsequent requests include `Authorization: Bearer {token}` header
4. Token removed on logout

## Testing

Use the test endpoint to verify connectivity:
```dart
import '../core/network/public_service.dart';

final test = await PublicService.testConnection();
print(test['message']); // "API connected successfully!"
```
