import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/network/organ_donation_service.dart';
import '../core/network/public_service.dart';

class AliveOrganDonationPage extends StatefulWidget {
  const AliveOrganDonationPage({super.key});

  @override
  State<AliveOrganDonationPage> createState() => _AliveOrganDonationPageState();
}

class _AliveOrganDonationPageState extends State<AliveOrganDonationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedOrgan;
  String? _selectedDonationType;
  String? _gender;
  bool _agreeToTerms = false;

  // Health conditions
  bool _hasDiabetes = false;
  bool _hasKidneyLiverDisease = false;
  bool _hasPreviousSurgeries = false;
  bool _hasHighBloodPressure = false;
  bool _hasHepatitisHIV = false;
  bool _isCurrentSmoker = false;
  DateTime? _dateOfBirth;

  // Recipient information state
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientAgeController = TextEditingController();
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  String? _recipientContactType = 'Phone Number';
  String? _recipientBloodType;
  String? _recipientHospital;

  // Non-directed hospital selection state
  String? _selectedNonDirectedHospital;
  
  // Dynamic hospital data (names for UI; full list for resolving hospital_id)
  List<String> _hospitals = [];
  List<Map<String, dynamic>> _hospitalList = [];
  bool _isLoadingHospitals = false;
  String? _hospitalLoadError;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoadingHospitals = true;
      _hospitalLoadError = null;
    });

    try {
      final result = await PublicService.getHospitals();
      if (!mounted) return;
      // Backend returns either {hospitals: [...]} or direct List
      List<dynamic> raw;
      if (result is List) {
        raw = result;
      } else if (result is Map) {
        final h = result['hospitals'] ?? result['data'];
        raw = h is List ? h : <dynamic>[];
      } else {
        raw = <dynamic>[];
      }
      final list = raw
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .where((m) => (m['name'] ?? m['id']) != null)
          .toList();
      if (!mounted) return;
      setState(() {
        _hospitalList = list;
        _hospitals = list
            .map((h) => h['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        _isLoadingHospitals = false;
        _hospitalLoadError = null;
      });
    } catch (e, st) {
      debugPrint('Failed to load hospitals: $e');
      debugPrint('Stack trace: $st');
      if (!mounted) return;
      setState(() {
        _isLoadingHospitals = false;
        _hospitalLoadError = e.toString();
        _hospitals = [];
        _hospitalList = [];
      });
    }
  }

  /// Backend organ slugs: kidney, liver-partial, bone-marrow.
  static String? _organToSlug(String? organ) {
    if (organ == null) return null;
    switch (organ) {
      case 'Kidney': return 'kidney';
      case 'Liver': return 'liver-partial';
      case 'Bone Marrow': return 'bone-marrow';
      default: return null;
    }
  }

  int? _hospitalNameToId(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final h in _hospitalList) {
      if (h['name']?.toString() == name && h['id'] != null) {
        final id = h['id'];
        return id is int ? id : int.tryParse(id.toString());
      }
    }
    return null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _recipientNameController.dispose();
    _recipientAgeController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  // Collect all form data in a structured format ready for API submission
  Map<String, dynamic> _collectFormData() {
    return {
      'personalInfo': {
        'firstName': _firstNameController.text,
        'middleName': _middleNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'gender': _gender,
        'address': _addressController.text,
      },
      'healthInfo': {
        'bloodType': _selectedBloodType,
        'organToDonate': _selectedOrgan,
        'healthConditions': {
          'diabetes': _hasDiabetes,
          'kidneyLiverDisease': _hasKidneyLiverDisease,
          'previousSurgeries': _hasPreviousSurgeries,
          'highBloodPressure': _hasHighBloodPressure,
          'hepatitisHIV': _hasHepatitisHIV,
          'currentSmoker': _isCurrentSmoker,
        },
      },
      'donationType': _selectedDonationType,
      'recipientInfo': _selectedDonationType == 'directed'
          ? {
              'recipientName': _recipientNameController.text,
              'recipientAge': _recipientAgeController.text,
              'contactType': _recipientContactType,
              'contactPhone': _recipientPhoneController.text,
              'recipientBloodType': _recipientBloodType,
              'hospital': _recipientHospital,
            }
          : null,
      'hospitalSelection': _selectedDonationType == 'non-directed'
          ? {'selectedHospital': _selectedNonDirectedHospital}
          : null,
      'agreedToTerms': _agreeToTerms,
      'submittedAt': DateTime.now().toIso8601String(),
    };
  }

  // Method to save data - connect to backend API
  Future<void> _submitRegistration() async {
    if (_isSubmitting) return;

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final formData = _collectFormData();
      final dateBirth = formData['personalInfo']['dateOfBirth'] as String?;
      final birthDate = dateBirth != null && dateBirth.length >= 10
          ? dateBirth.substring(0, 10)
          : dateBirth;
      if (birthDate == null || birthDate.isEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your Date of Birth.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final organSlug = _organToSlug(formData['healthInfo']['organToDonate'] as String?);
      if (organSlug == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Kidney, Liver, or Bone Marrow.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_gender == null || (_gender != 'Male' && _gender != 'Female')) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Gender.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedBloodType == null || _selectedBloodType!.isEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your Blood Type.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_selectedDonationType == null || _selectedDonationType!.isEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Donation Type (Directed or Non-Directed).'), backgroundColor: Colors.red),
        );
        return;
      }

      final donationData = <String, dynamic>{
        'first_name': (formData['personalInfo']['firstName'] as String?)?.trim() ?? '',
        'middle_name': (formData['personalInfo']['middleName'] as String?)?.trim(),
        'last_name': (formData['personalInfo']['lastName'] as String?)?.trim() ?? '',
        'email': (formData['personalInfo']['email'] as String?)?.trim() ?? '',
        'phone': (formData['personalInfo']['phone'] as String?)?.trim() ?? '',
        'birth_date': birthDate,
        'gender': _gender!.toLowerCase(),
        'address': (formData['personalInfo']['address'] as String?)?.trim() ?? '',
        'blood_type': _selectedBloodType!,
        'organ': organSlug,
        'donation_type': _selectedDonationType! == 'directed' ? 'directed' : 'non-directed',
        'medical_conditions': formData['healthInfo']['healthConditions'],
        'agree_interest': _agreeToTerms,
      };

      if (donationData['donation_type'] == 'directed' && formData['recipientInfo'] != null) {
        final rec = formData['recipientInfo'] as Map<String, dynamic>;
        final hospitalId = _hospitalNameToId(rec['hospital'] as String?);
        if (hospitalId == null) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a valid hospital for the recipient.'), backgroundColor: Colors.red),
          );
          return;
        }
        final ageRaw = (rec['recipientAge'] as String?)?.trim() ?? '';
        final age = int.tryParse(ageRaw);
        if (age == null || age < 1 || age > 120) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid recipient age (1–120).'), backgroundColor: Colors.red),
          );
          return;
        }
        final fullName = (rec['recipientName'] as String?)?.trim() ?? '';
        if (fullName.isEmpty) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter recipient full name.'), backgroundColor: Colors.red),
          );
          return;
        }
        final contact = (rec['contactPhone'] as String?)?.trim() ?? '';
        if (contact.isEmpty) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter recipient contact (phone or email).'), backgroundColor: Colors.red),
          );
          return;
        }
        final recipientBlood = rec['recipientBloodType'] as String?;
        if (recipientBlood == null || recipientBlood.isEmpty) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select recipient blood type.'), backgroundColor: Colors.red),
          );
          return;
        }
        donationData['recipient'] = {
          'full_name': fullName,
          'age': age,
          'contact': contact,
          'contact_type': rec['contactType'] == 'Email' ? 'email' : 'phone',
          'blood_type': recipientBlood,
          'hospital_id': hospitalId,
        };
      } else if (donationData['donation_type'] == 'non-directed') {
        final sel = formData['hospitalSelection']?['selectedHospital'] as String?;
        final hospitalId = _hospitalNameToId(sel);
        if (hospitalId != null) {
          donationData['hospital_selection'] = 'specific';
          donationData['hospital_id'] = hospitalId;
        } else {
          donationData['hospital_selection'] = 'general';
        }
      }

      debugPrint('Submitting living donor payload: $donationData');
      await OrganDonationService.submitLivingDonor(donationData);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Registration Submitted!'),
          content: const Text(
            'Your live organ donation registration has been successfully submitted. The hospital will contact you within 48 hours for the next steps.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      String msg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        msg = 'Request timed out. Your registration may have been saved. Please check your email or contact support to confirm.';
      } else {
        final raw = e.response?.data is Map
            ? (e.response!.data['message'] ?? e.response!.data['error'] ?? e.response!.data['errors']?.toString() ?? e.message)
            : e.message;
        msg = raw?.toString() ?? 'Failed to submit registration.';
      }
      if (mounted) {
        setState(() {
          _errorMessage = msg;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to submit registration: ${e.toString()}';
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: Text('Living Donor'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gift of Life Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bold main title
                  const Text(
                    'Give the Gift of Life – Become a Live Organ Donor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Small font subtitle
                  Text(
                    'Your willingness can bring hope to patients waiting for a life-saving transplant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade600),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Medical Evaluation Required',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Living organ donation requires extensive medical and psychological evaluation. This form is the first step in a comprehensive screening process that prioritizes donor safety.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Why Live Organ Donation Matters Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Why Live Organ Donation Matters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Organ donation cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kidney Card
                      SizedBox(
                        width: 95,
                        height: 190,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF01010),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/images/kidney.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Kidney',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You can live normally with one healthy kidney',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Liver Card
                      SizedBox(
                        width: 95,
                        height: 190,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF01010),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/images/liver.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Liver (Portion)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Liver regenerates after partial donation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bone Marrow Card
                      SizedBox(
                        width: 95,
                        height: 190,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF01010),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/images/bone.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Bone Marrow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Bone marrow regenerates naturally',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Statistics 1
                      Column(
                        children: [
                          const Text(
                            '17',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF01010),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const SizedBox(
                            width: 100,
                            child: Text(
                              'People die daily waiting for organs',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Statistics 2
                      Column(
                        children: [
                          const Text(
                            '100000+',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF01010),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const SizedBox(
                            width: 100,
                            child: Text(
                              'People on transplant waiting list',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // How It Works Section - Mobile Responsive
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'How It Works - 3 Simple Steps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Step 1
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Register Your Interest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete our simple online form with your basic information and health details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Step 2
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hospital Review & Contact',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your assigned hospital reviews your details and contacts you within 48 hours',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Step 3
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Medical & Legal Evaluation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete medical tests and legal approval process at the hospital',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Live Organ Donation Registration Form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A), // Dark blue
                          Color(0xFF2563EB), // Blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: const Text(
                      'Live Organ Donation Registration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Personal Information Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Personal Information',
                          Icons.person,
                        ),
                        const SizedBox(height: 12),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Name Fields
                              TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _middleNameController,
                                decoration: InputDecoration(
                                  labelText: 'Middle Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Email and Phone
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Date of Birth and Gender
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dateOfBirth = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dateOfBirth != null
                                            ? '${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                                            : 'Date of Birth',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _dateOfBirth != null
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _gender = value);
                                },
                              ),
                              const SizedBox(height: 12),
                              // Address
                              TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Personal ID Picture
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.grey.shade50,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Personal ID Picture',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: Colors.black87,
                                      ),
                                      onPressed: () {
                                        // Image picker logic
                                      },
                                      child: const Text('Choose File'),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upload a clear picture of your ID (Max 5MB, JPEG/PNG/WebP)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Health Information Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                'Health Information',
                                Icons.favorite,
                              ),
                              const SizedBox(height: 12),
                              // Blood Type and Choose Organ
                              DropdownButtonFormField<String>(
                                value: _selectedBloodType,
                                decoration: InputDecoration(
                                  labelText: 'Blood Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'O+',
                                    child: Text('O+'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'O-',
                                    child: Text('O-'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'A+',
                                    child: Text('A+'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'A-',
                                    child: Text('A-'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'B+',
                                    child: Text('B+'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'B-',
                                    child: Text('B-'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AB+',
                                    child: Text('AB+'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AB-',
                                    child: Text('AB-'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBloodType = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _selectedOrgan,
                                decoration: InputDecoration(
                                  labelText: 'Choose Organ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Kidney',
                                    child: Text('Kidney'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Liver',
                                    child: Text('Liver'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Bone Marrow',
                                    child: Text('Bone Marrow'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Pancreas',
                                    child: Text('Pancreas'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Lung',
                                    child: Text('Lung'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOrgan = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              // Health Conditions
                              const Text(
                                'Please check any conditions that applies to you:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 3.5,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                children: [
                                  _buildHealthCheckbox(
                                    'Diabetes',
                                    _hasDiabetes,
                                    (value) {
                                      setState(
                                        () => _hasDiabetes = value ?? false,
                                      );
                                    },
                                  ),
                                  _buildHealthCheckbox(
                                    'Kidney/Liver Disease',
                                    _hasKidneyLiverDisease,
                                    (value) {
                                      setState(
                                        () => _hasKidneyLiverDisease =
                                            value ?? false,
                                      );
                                    },
                                  ),
                                  _buildHealthCheckbox(
                                    'Previous Major Surgeries',
                                    _hasPreviousSurgeries,
                                    (value) {
                                      setState(
                                        () => _hasPreviousSurgeries =
                                            value ?? false,
                                      );
                                    },
                                  ),
                                  _buildHealthCheckbox(
                                    'High Blood Pressure',
                                    _hasHighBloodPressure,
                                    (value) {
                                      setState(
                                        () => _hasHighBloodPressure =
                                            value ?? false,
                                      );
                                    },
                                  ),
                                  _buildHealthCheckbox(
                                    'Hepatitis/HIV',
                                    _hasHepatitisHIV,
                                    (value) {
                                      setState(
                                        () => _hasHepatitisHIV = value ?? false,
                                      );
                                    },
                                  ),
                                  _buildHealthCheckbox(
                                    'Current Smoker',
                                    _isCurrentSmoker,
                                    (value) {
                                      setState(
                                        () => _isCurrentSmoker = value ?? false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Donation Type Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                'Donation Type',
                                Icons.favorite,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    _buildRadioTile(
                                      'Directed Donation',
                                      'Donate to a specific person you know',
                                      'directed',
                                      _selectedDonationType,
                                      (value) {
                                        setState(
                                          () => _selectedDonationType = value,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRadioTile(
                                      'Non-Directed Donation',
                                      'Donate to someone on the waiting list',
                                      'non-directed',
                                      _selectedDonationType,
                                      (value) {
                                        setState(
                                          () => _selectedDonationType = value,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Recipient Information (only for Directed Donation)
                        if (_selectedDonationType == 'directed')
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Recipient Information',
                                  Icons.person,
                                ),
                                const SizedBox(height: 12),
                                // Recipient Full Name
                                TextFormField(
                                  controller: _recipientNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Recipient Full Name',
                                    labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                // Age
                                TextFormField(
                                  controller: _recipientAgeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                // Contact Type
                                DropdownButtonFormField<String>(
                                  value: _recipientContactType,
                                  decoration: InputDecoration(
                                    labelText: 'Contact Type',
                                    labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  items: const ['Phone Number', 'Email']
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _recipientContactType = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                // Phone Number
                                TextFormField(
                                  controller: _recipientPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                // Recipient Blood Type
                                DropdownButtonFormField<String>(
                                  value: _recipientBloodType,
                                  decoration: InputDecoration(
                                    labelText: 'Recipient Blood Type',
                                    labelStyle: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  items:
                                      const [
                                            'O+',
                                            'O-',
                                            'A+',
                                            'A-',
                                            'B+',
                                            'B-',
                                            'AB+',
                                            'AB-',
                                          ]
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(type),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _recipientBloodType = value;
                                    });
                                  },
                                  hint: const Text(
                                    'Select Blood Type',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Hospital
                                if (_hospitalLoadError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Could not load hospitals. Please check your connection.',
                                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _isLoadingHospitals ? null : _loadHospitals,
                                          icon: _isLoadingHospitals
                                              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                              : const Icon(Icons.refresh, size: 16),
                                          label: Text(_isLoadingHospitals ? 'Loading...' : 'Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else
                                  DropdownButtonFormField<String>(
                                    value: _recipientHospital,
                                    decoration: InputDecoration(
                                      labelText: 'Hospital',
                                      labelStyle: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    items: _isLoadingHospitals
                                        ? []
                                        : _hospitals.isEmpty
                                            ? [
                                                DropdownMenuItem(
                                                  value: null,
                                                  child: Text('No hospitals available'),
                                                  enabled: false,
                                                ),
                                              ]
                                            : _hospitals.map(
                                                (hospital) => DropdownMenuItem(
                                                  value: hospital,
                                                  child: Text(hospital),
                                                ),
                                              ).toList(),
                                    onChanged: _isLoadingHospitals || _hospitals.isEmpty
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _recipientHospital = value;
                                            });
                                          },
                                    hint: Text(
                                      _isLoadingHospitals ? 'Loading hospitals...' : 'Select Hospital',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (_selectedDonationType == 'directed')
                          const SizedBox(height: 16),

                        // Hospital Selection (only for Non-Directed Donation)
                        if (_selectedDonationType == 'non-directed')
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Hospital Selection',
                                  Icons.local_hospital,
                                ),
                                const SizedBox(height: 12),
                                if (_hospitalLoadError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Could not load hospitals. Please check your connection.',
                                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _isLoadingHospitals ? null : _loadHospitals,
                                          icon: _isLoadingHospitals
                                              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                              : const Icon(Icons.refresh, size: 16),
                                          label: Text(_isLoadingHospitals ? 'Loading...' : 'Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else
                                  DropdownButtonFormField<String>(
                                    value: _selectedNonDirectedHospital,
                                    decoration: InputDecoration(
                                      labelText: 'Hospital',
                                      labelStyle: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    items: _isLoadingHospitals
                                        ? []
                                        : _hospitals.isEmpty
                                            ? [
                                                DropdownMenuItem(
                                                  value: null,
                                                  child: Text('No hospitals available'),
                                                  enabled: false,
                                                ),
                                              ]
                                            : _hospitals.map(
                                                (hospital) => DropdownMenuItem(
                                                  value: hospital,
                                                  child: Text(hospital),
                                                ),
                                              ).toList(),
                                    onChanged: _isLoadingHospitals || _hospitals.isEmpty
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedNonDirectedHospital = value;
                                            });
                                          },
                                    hint: Text(
                                      _isLoadingHospitals ? 'Loading hospitals...' : 'Select Hospital',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (_selectedDonationType == 'non-directed')
                          const SizedBox(height: 16),

                        // Consent Checkbox
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.red.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(
                                        () => _agreeToTerms = value ?? false,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      'I understand this is an expression of interest only. Final approval is done by hospital doctors and legal authorities.\nBy checking this box, I consent to being contacted by partner hospitals for further evaluation.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Error Display
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Submit Button
                        Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E3A8A), // Dark blue
                                Color(0xFF2563EB), // Blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : () async {
                              if (_formKey.currentState!.validate() &&
                                  _agreeToTerms) {
                                // Submit registration
                                await _submitRegistration();
                              } else if (!_agreeToTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please agree to the terms'),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isSubmitting) ...[
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  _isSubmitting ? 'Submitting...' : 'Send Request',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                if (!_isSubmitting) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.send, size: 16, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // FAQ Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // FAQ Grid
                  Column(
                    children: [
                      _buildFAQItem(
                        'Can I change my mind after pledging?',
                        'Absolutely. You can update or withdraw your organ donation pledge at any time by re-registering or contacting us.',
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'Will my medical care be affected if I\'m a donor?',
                        'No. Your medical care will never be compromised because of your decision to donate organs.',
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'Are there any costs to my family for organ donation?',
                        'No. There are no costs to your family for organ donation. All expenses related to the donation process are covered by the recipient\'s insurance or the transplant program.',
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'How are organs allocated to recipients?',
                        'Organs are allocated based on medical urgency, compatibility, and time spent on the waiting list, following strict medical guidelines.',
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'Can I specify which organs to donate?',
                        'Yes. You can choose to donate specific organs or tissues according to your preferences.',
                      ),
                      const SizedBox(height: 12),
                      _buildFAQItem(
                        'Can I specify which organs to donate?',
                        'Yes. You can choose to donate specific organs or tissues according to your preferences.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Privacy Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'All your information is kept confidential and shared only with partner hospitals for evaluation purposes. We use industry-standard encryption to protect your data and comply with all medical privacy regulations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
      ],
    );
  }

  Widget _buildRadioTile(
    String title,
    String subtitle,
    String value,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
