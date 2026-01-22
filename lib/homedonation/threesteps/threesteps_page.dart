import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../thanks/home_thanks.dart';
import 'firststep.dart';
import 'secondstep.dart';
import 'thirdstep.dart';

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

  void _handleSubmit(Map<String, dynamic> finalData) async {
    debugPrint('\n========== SUBMITTING ==========');
    debugPrint('Final data:');
    debugPrint(finalData.toString());
    debugPrint('================================');

    // Transform data for API format
    final appointmentData = {
      ...finalData,
      'appointment_date': finalData['selected_date'],
      'appointment_time': finalData['selected_time'],
      'hospital_name': widget.selectedRequest['name'],
      'hospital_id': widget.selectedRequest['id'],
      'donation_type': widget.donationType,
    };

    // Remove old keys
    appointmentData.remove('selected_date');
    appointmentData.remove('selected_time');

    // Save to state (like saving to database)
    await context.read<AppState>().addDonationAppointment(appointmentData);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Data saved to state successfully');

    if (mounted) Navigator.pop(context);

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
