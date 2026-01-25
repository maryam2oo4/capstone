import 'package:flutter/material.dart';

class SecondStepForm extends StatefulWidget {
  final Map<String, dynamic> firstStepData;
  final Function(Map<String, dynamic>) onContinue;
  final VoidCallback onBack;

  const SecondStepForm({
    super.key,
    required this.firstStepData,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<SecondStepForm> createState() => _SecondStepFormState();
}

class _SecondStepFormState extends State<SecondStepForm> {
  final _formKey = GlobalKey<FormState>();

  String? selectedBloodType;
  DateTime? lastDonationDate;
  String? lastDonationError;

  // Medical conditions
  bool? isUnhealthy;
  bool? hadSurgery;
  bool? hadTravel;
  bool? takingMedicine;
  bool? hasDisease;

  bool get isAffected {
    return (isUnhealthy == true) ||
        (hadSurgery == true) ||
        (hadTravel == true) ||
        (takingMedicine == true) ||
        (hasDisease == true);
  }

  bool validateLastDonation(DateTime? date) {
    if (date == null) {
      setState(() {
        lastDonationError = null;
      });
      return true;
    }

    final today = DateTime.now();
    final daysSince = today.difference(date).inDays;

    if (daysSince < 56) {
      setState(() {
        lastDonationError =
            'You must wait at least 56 days between donations. You can donate again in ${56 - daysSince} days.';
      });
      return false;
    }

    setState(() {
      lastDonationError = null;
    });
    return true;
  }

  Future<void> _selectLastDonationDate(BuildContext context) async {
    // Default to 6 months ago so it's always eligible by default
    final defaultDate =
        lastDonationDate ?? DateTime.now().subtract(const Duration(days: 180));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: defaultDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        lastDonationDate = picked;
      });
      validateLastDonation(picked);
    }
  }

  void _continueToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your blood type')),
      );
      return;
    }

    if (lastDonationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select last donation date')),
      );
      return;
    }

    if (!validateLastDonation(lastDonationDate)) {
      return;
    }

    if (isUnhealthy == null ||
        hadSurgery == null ||
        hadTravel == null ||
        takingMedicine == null ||
        hasDisease == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all medical questions')),
      );
      return;
    }

    if (isAffected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sorry, you are not eligible due to medical conditions',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formData = {
      ...widget.firstStepData,
      'blood_type': selectedBloodType,
      'last_donation': lastDonationDate!.toIso8601String().split('T')[0],
      'medical_conditions': {
        'not_healthy': isUnhealthy,
        'has_surgery': hadSurgery,
        'has_travel': hadTravel,
        'take_medicine': takingMedicine,
        'has_disease': hasDisease,
      },
    };

    widget.onContinue(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(1, "Personal Info", true),
              _buildStepLine(true),
              _buildStepIndicator(2, "Medical Info", true),
              _buildStepLine(false),
              _buildStepIndicator(3, "Review & Submit", false),
            ],
          ),
          const SizedBox(height: 24),

          // Red header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade600, Colors.red.shade700],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Medical Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Blood Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Blood Type",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedBloodType,
                decoration: InputDecoration(
                  hintText: 'Select Blood Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: const [
                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                  DropdownMenuItem(value: 'B-', child: Text('B-')),
                  DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBloodType = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Last Donation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last Donation",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectLastDonationDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lastDonationDate != null
                            ? '${lastDonationDate!.day.toString().padLeft(2, '0')}/${lastDonationDate!.month.toString().padLeft(2, '0')}/${lastDonationDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 14,
                          color: lastDonationDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              if (lastDonationError != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    lastDonationError!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Medical Questions
          _buildYesNoQuestion(
            'Are you feeling unhealthy today (fever, cough, or flu symptoms)?',
            isUnhealthy,
            (value) => setState(() => isUnhealthy = value),
          ),
          _buildDivider(),

          _buildYesNoQuestion(
            'Have you had surgery, a major illness, or hospitalization in the last 6 months?',
            hadSurgery,
            (value) => setState(() => hadSurgery = value),
          ),
          _buildDivider(),

          _buildYesNoQuestion(
            'Have you traveled outside the country or had any infectious disease in the past 3 months?',
            hadTravel,
            (value) => setState(() => hadTravel = value),
          ),
          _buildDivider(),

          _buildYesNoQuestion(
            'Are you currently taking antibiotics or medication for an ongoing illness?',
            takingMedicine,
            (value) => setState(() => takingMedicine = value),
          ),
          _buildDivider(),

          _buildYesNoQuestion(
            'Have you ever had heart disease, hepatitis, HIV, or other blood-borne diseases?',
            hasDisease,
            (value) => setState(() => hasDisease = value),
          ),

          if (isAffected)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Not eligible due to medical conditions',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Previous",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: (isAffected || lastDonationError != null)
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Next Step",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFCC0000), Color(0xFF990000)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: _continueToNextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Next Step",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.red : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 26),
      color: isActive ? Colors.red : Colors.grey.shade300,
    );
  }

  Widget _buildYesNoQuestion(
    String question,
    bool? value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRadioOption('Yes', true, value, onChanged)),
              const SizedBox(width: 12),
              Expanded(child: _buildRadioOption('No', false, value, onChanged)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String label,
    bool optionValue,
    bool? groupValue,
    Function(bool) onChanged,
  ) {
    final isSelected = groupValue == optionValue;
    return GestureDetector(
      onTap: () => onChanged(optionValue),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.red : Colors.white,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.shade200,
    );
  }
}
