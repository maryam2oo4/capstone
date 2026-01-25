import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/network/api_client.dart';
import '../../thanks/home_thanks.dart';
import 'firststep.dart';
import 'secondstep.dart';
import 'thirdstep.dart';
import 'package:dio/dio.dart';

class ThreeStepsPage extends StatefulWidget {
  final Map<String, dynamic> selectedRequest;
  final String selectedDate;
  final String selectedTime;
  final String donationType; // 'home' or 'hospital'

  const ThreeStepsPage({
    super.key,
    required this.selectedRequest,
    required this.selectedDate,
    required this.selectedTime,
    required this.donationType,
  });

  @override
  State<ThreeStepsPage> createState() => _ThreeStepsPageState();
}

class _ThreeStepsPageState extends State<ThreeStepsPage> {
  int currentStep = 0;
  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    debugPrint('\n========== HOME BLOOD DONATION FORM ==========');
    debugPrint('Hospital: ${widget.selectedRequest}');
    debugPrint('Date: ${widget.selectedDate}');
    debugPrint('Time: ${widget.selectedTime}');
    debugPrint('Type: ${widget.donationType}');
    debugPrint('============================================\n');

    // Initialize formData with selected date and time
    formData = {
      'selected_date': widget.selectedDate,
      'selected_time': widget.selectedTime,
    };
  }

  void _goToNextStep(Map<String, dynamic> data) {
    debugPrint('\n--- Moving to Step ${currentStep + 2} ---');
    debugPrint('Data from Step ${currentStep + 1}:');
    debugPrint(data.toString());
    debugPrint('---------------------------\n');

    setState(() {
      formData = data;
      currentStep++;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      currentStep--;
    });
  }

  // Convert date from DD/MM/YYYY to YYYY-MM-DD
  String _convertDateFormat(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
      // If already in YYYY-MM-DD format, return as is
      return dateStr;
    } catch (e) {
      debugPrint('Error converting date format: $e');
      return dateStr;
    }
  }

  void _handleSubmit(Map<String, dynamic> finalData) async {
    debugPrint('\n========== SUBMITTING ==========');
    debugPrint('Final data:');
    debugPrint(finalData.toString());
    debugPrint('================================');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );

    try {
      // Transform data for API format
      final hospitalId = widget.selectedRequest['id']?.toString();
      if (hospitalId == null) {
        throw Exception('Hospital ID is missing');
      }

      // Convert date from DD/MM/YYYY to YYYY-MM-DD
      final selectedDateStr = finalData['selected_date']?.toString() ?? '';
      final appointmentDate = _convertDateFormat(selectedDateStr);
      
      // Convert date of birth from DD/MM/YYYY to YYYY-MM-DD
      final dobStr = finalData['date_of_birth']?.toString() ?? '';
      final dateOfBirth = _convertDateFormat(dobStr);

      // Last donation is already in YYYY-MM-DD format from secondstep
      final lastDonation = finalData['last_donation']?.toString();

      // Prepare base appointment data
      final appointmentData = <String, dynamic>{
        'first_name': finalData['first_name']?.toString() ?? '',
        'last_name': finalData['last_name']?.toString() ?? '',
        'email': finalData['email']?.toString() ?? '',
        'phone_nb': finalData['phone_nb']?.toString() ?? '',
        'gender': finalData['gender']?.toString() ?? '',
        'blood_type': finalData['blood_type']?.toString() ?? '',
        'date_of_birth': dateOfBirth,
        'hospital_id': hospitalId,
        'appointment_date': appointmentDate,
        'appointment_time': finalData['selected_time']?.toString() ?? '',
        'last_donation': lastDonation,
      };

      // Add home-specific fields if it's a home appointment
      if (widget.donationType == 'home') {
        appointmentData['address'] = finalData['address']?.toString() ?? '';
        appointmentData['latitude'] = finalData['latitude'];
        appointmentData['longitude'] = finalData['longitude'];
        appointmentData['weight'] = finalData['weight']?.toString() ?? '';
        appointmentData['emerg_contact'] = finalData['emerg_contact']?.toString();
        appointmentData['emerg_phone'] = finalData['emerg_phone']?.toString();
        appointmentData['medical_conditions'] = finalData['medical_conditions'];
      }

      debugPrint('📤 Sending appointment data to backend:');
      debugPrint(appointmentData.toString());

      // Call appropriate API endpoint
      final dio = await ApiClient.instance.dio();
      final endpoint = widget.donationType == 'home'
          ? '/api/blood/home_appointment'
          : '/api/hospital/appointments';

      final response = await dio.post(endpoint, data: appointmentData);

      debugPrint('✅ Appointment created successfully');
      debugPrint('Response: ${response.data}');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Save to local state for reference
      await context.read<AppState>().addDonationAppointment({
        ...appointmentData,
        'donation_type': widget.donationType,
        'hospital_name': widget.selectedRequest['name'],
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ThankModalHomeBlood(
            onClose: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to calendar
            },
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ API Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      String errorMessage = 'Failed to create appointment. Please try again.';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map) {
          errorMessage = errorData['message']?.toString() ?? errorMessage;
          // Check for validation errors
          if (errorData['errors'] != null) {
            final errors = errorData['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Donation Appointment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep > 0) {
              _goToPreviousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: currentStep == 0
            ? FirstStepForm(
                selectedRequest: widget.selectedRequest,
                selectedDate: widget.selectedDate,
                selectedTime: widget.selectedTime,
                donationType: widget.donationType,
                onContinue: _goToNextStep,
              )
            : currentStep == 1
            ? SecondStepForm(
                firstStepData: formData,
                onContinue: _goToNextStep,
                onBack: _goToPreviousStep,
              )
            : ThirdStepForm(
                formData: formData,
                onSubmit: _handleSubmit,
                onBack: _goToPreviousStep,
                onCancel: _handleCancel,
              ),
      ),
    );
  }
}
