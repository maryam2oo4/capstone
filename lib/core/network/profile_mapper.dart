// This file will contain the logic to map the backend response to the profile fields.
// It can be expanded later if needed.
class ProfileMapper {
  static void mapSettingsToControllers(
    Map<String, dynamic> data, {
    required Function(String) setName,
    required Function(String) setEmail,
    required Function(String) setPhone,
    required Function(String) setAddress,
    required Function(String) setCity,
    required Function(DateTime?) setDate,
  }) {
    // Map from backend response structure
    final user = data['profile']?['user'] ?? {};
    final donor = data['profile']?['donor'] ?? {};

    // Name: use first_name + last_name (or just first_name if last_name is empty)
    String name = user['first_name'] ?? '';
    if ((user['last_name'] ?? '').toString().isNotEmpty) {
      name += ' ' + (user['last_name'] ?? '');
    }
    setName(name);

    setEmail(user['email'] ?? '');
    setPhone(user['phone_nb'] ?? '');
    setAddress(user['address'] ?? donor['address'] ?? '');
    setCity(user['city'] ?? '');

    // Date of birth: donor['date_of_birth']
    if (donor['date_of_birth'] != null) {
      try {
        setDate(DateTime.parse(donor['date_of_birth']));
      } catch (_) {
        setDate(null);
      }
    } else {
      setDate(null);
    }
  }
}
