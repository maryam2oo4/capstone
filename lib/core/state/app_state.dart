import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const _storageKey = 'donation_appointments';

  final List<Map<String, dynamic>> _donationAppointments = [];

  AppState() {
    _loadAppointments();
  }

  List<Map<String, dynamic>> get donationAppointments => _donationAppointments;

  Future<void> _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) return;

    try {
      final decoded = jsonDecode(stored);
      if (decoded is List) {
        _donationAppointments
          ..clear()
          ..addAll(decoded.cast<Map<String, dynamic>>());
        debugPrint(
          'Loaded ${_donationAppointments.length} appointments from storage',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
    }
  }

  Future<void> _persistAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_donationAppointments));
  }

  Future<void> addDonationAppointment(Map<String, dynamic> appointment) async {
    _donationAppointments.add(appointment);

    // 🔍 Console log (like console.log)
    debugPrint('========== DONATION APPOINTMENT SAVED ==========');
    debugPrint('Hospital: ${appointment['hospital_name']}');
    debugPrint('Date: ${appointment['appointment_date']}');
    debugPrint('Time: ${appointment['appointment_time']}');
    debugPrint(
      'Donor: ${appointment['first_name']} ${appointment['last_name']}',
    );
    debugPrint('Blood Type: ${appointment['blood_type']}');
    debugPrint('Phone: ${appointment['phone']}');
    debugPrint(
      'Location: lat=${appointment['latitude']}, lng=${appointment['longitude']}',
    );
    debugPrint(
      'Medical Eligible: ${!_isMedicallyAffected(appointment['medical_conditions'])}',
    );
    debugPrint('Total Appointments: ${_donationAppointments.length}');
    debugPrint('================================================\n');

    await _persistAppointments();
    notifyListeners();

    // TODO: Later replace with API call
    // await api.post('/api/blood/home_appointment', appointment);
  }

  bool _isMedicallyAffected(Map<String, dynamic>? conditions) {
    if (conditions == null) return false;
    return conditions.values.any((value) => value == true);
  }

  Future<void> clearAppointments() async {
    _donationAppointments.clear();
    await _persistAppointments();
    debugPrint('All appointments cleared');
    notifyListeners();
  }
}
