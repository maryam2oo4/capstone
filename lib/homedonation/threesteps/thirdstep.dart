import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThirdStepForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onBack;
  final VoidCallback onCancel;
  final Map<String, dynamic> formData;

  const ThirdStepForm({
    super.key,
    required this.onSubmit,
    required this.onBack,
    required this.onCancel,
    required this.formData,
  });

  @override
  State<ThirdStepForm> createState() => _ThirdStepFormState();
}

class _ThirdStepFormState extends State<ThirdStepForm> {
  bool consentChecked = false;
  bool termsChecked = false;
  bool isSubmitting = false;

  bool get canSubmit => consentChecked && termsChecked && !isSubmitting;

  @override
  void initState() {
    super.initState();
    debugPrint('========== STEP 3: Review and Submit ==========');
    debugPrint('Received form data:');
    debugPrint(widget.formData.toString());
    debugPrint('Consent: $consentChecked, Terms: $termsChecked');
    debugPrint('Can Submit: $canSubmit');
    debugPrint('===============================================');
  }

  void _handleSubmit() async {
    debugPrint('Submit button clicked! canSubmit: $canSubmit');
    if (!canSubmit) {
      debugPrint(
        'Submit blocked - consent: $consentChecked, terms: $termsChecked, isSubmitting: $isSubmitting',
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final finalData = {
      ...widget.formData,
      'consent': consentChecked,
      'terms_agreed': termsChecked,
    };

    debugPrint('\n========== FINAL SUBMISSION ==========');
    debugPrint('Complete form data ready for API:');
    debugPrint(finalData.toString());
    debugPrint('======================================');
    debugPrint('TODO: Replace with API call');
    debugPrint(
      'Example: await api.post("/api/blood/home_appointment", finalData);',
    );

    widget.onSubmit(finalData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicators(),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCC0000), Color(0xFFFF0000)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Review and Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildConsentCheckbox(
          value: consentChecked,
          onChanged: (value) {
            setState(() {
              consentChecked = value ?? false;
            });
            debugPrint(
              'Consent checkbox: $consentChecked, Can Submit: $canSubmit',
            );
          },
          text:
              'I consent to donate blood and confirm that the information provided is accurate to the best of my knowledge.',
        ),
        const SizedBox(height: 16),

        _buildConsentCheckbox(
          value: termsChecked,
          onChanged: (value) {
            setState(() {
              termsChecked = value ?? false;
            });
            debugPrint('Terms checkbox: $termsChecked, Can Submit: $canSubmit');
          },
          text: 'I agree to the ',
          highlightedText: 'Terms & Conditions',
          trailingText: ' of the blood donation service.',
        ),
        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.favorite, color: Color(0xFFEF5350), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'What Happens Next?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBulletPoint(
                'You\'ll receive an email with your registration details',
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(
                'Our team will review your application within 24 hours',
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(
                'A brief health screening will be conducted before the donation',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : widget.onBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSubmitting
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        color: isSubmitting
                            ? Colors.grey.shade400
                            : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSubmitting
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isSubmitting
                          ? Colors.grey.shade400
                          : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: canSubmit ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit
                        ? const Color(0xFFDC3545)
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isSubmitting ? 'Submitting' : 'Submit',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle('1', true),
        _buildConnectingLine(true),
        _buildStepCircle('2', true),
        _buildConnectingLine(true),
        _buildStepCircle('3', true),
      ],
    );
  }

  Widget _buildStepCircle(String number, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectingLine(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      color: isActive ? Colors.red : Colors.grey.shade300,
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
    String? highlightedText,
    String? trailingText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: highlightedText != null
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: text),
                        TextSpan(
                          text: highlightedText,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (trailingText != null) TextSpan(text: trailingText),
                      ],
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Colors.black87),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
