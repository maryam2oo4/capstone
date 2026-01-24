import 'package:flutter/material.dart';

class AfterDeathDonationPage extends StatefulWidget {
  const AfterDeathDonationPage({super.key});

  @override
  State<AfterDeathDonationPage> createState() => _AfterDeathDonationPageState();
}

class _AfterDeathDonationPageState extends State<AfterDeathDonationPage> {
  int _currentStep = 0;

  // Step 1 form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _bloodType;
  String? _gender;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  bool _isUnder18 = false;

  // Step 2 form and fields
  final GlobalKey<FormState> _personalFormKey = GlobalKey<FormState>();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _spouseNameController = TextEditingController();
  final TextEditingController _exSpouseNameController = TextEditingController();
  final TextEditingController _deceasedSpouseNameController =
      TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  String? _maritalStatus;
  String? _professionalStatus;

  // Step 3 organ selection
  String? _hospitalChoice = 'General Donation';
  String? _selectedHospital;
  bool _donateAllOrgans = false;
  final List<String> _organs = [
    'Heart',
    'Liver',
    'Kidneys',
    'Lungs',
    'Pancreas',
    'Intestines',
    'Corneas',
    'Skin',
    'Bones',
    'Valves',
    'Tendons',
    'Blood Vessels',
  ];
  final Map<String, bool> _selectedOrgans = {};
  final List<String> _hospitals = [
    'AL Zahrani Hospital',
    'Rageb Hareeb Hospital',
    'AL Rassoul AL Aazam Hospital',
  ];

  void _calculateAge(String dob) {
    try {
      // Parse date in MM/DD/YYYY format
      final parts = dob.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final birthDate = DateTime(year, month, day);
        final today = DateTime.now();

        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }

        setState(() {
          _isUnder18 = age < 18;
        });
      }
    } catch (e) {
      // Invalid date format, keep _isUnder18 as false
      setState(() {
        _isUnder18 = false;
      });
    }
  }

  bool _validateStep1() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _dobController.text.trim().isNotEmpty &&
        _bloodType != null &&
        _gender != null &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _emergencyContactController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _motherNameController.dispose();
    _spouseNameController.dispose();
    _exSpouseNameController.dispose();
    _deceasedSpouseNameController.dispose();
    _jobTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        title: Text('After Death Donation'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: _currentStep == 0
          ? _buildIntroAndForm()
          : _currentStep == 1
          ? _buildPersonalInfoForm()
          : _buildOrganSubmissionForm(),
    );
  }

  Widget _buildIntroAndForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                // Main Title
                Text(
                  "Leave a Legacy of Life - Pledge Your Organs Today",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16),
                // Subtitle
                Text(
                  "One donor can save up to 8 lives. Your decision now can bring hope to many after you're gone.",
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
          // Why After-Death Donation Matters Section
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
                  'Why After-Death Donation Matters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Thousands of patients die every year waiting for an organ. By pledging your organs, you give the greatest gift possible — the chance to live.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Organ donation cards - 2 per row
                Column(
                  children: [
                    // First row: Heart and Kidneys
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heart Card
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
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Heart',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Restores life for those with heart failure',
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
                        // Kidneys Card
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
                                  'Kidneys',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Two kidneys can save two livese',
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
                    const SizedBox(height: 8),
                    // Second row: Liver and Eye
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  'Liver',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Liver regenerates and can save two lives',
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
                        // Eye Card
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
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Eye',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Restore vision to the blind',
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
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Donation Process Section
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
                  'Donation Process',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Steps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Register Your Pledge Online',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete your organ donation pledge with our secure online form.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Step 2
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Share Your Decision with Family',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inform your loved ones about your noble decision to save lives.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 3
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Hospitals Access Your Consent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Medical teams can quickly access your donation preferences when needed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Step 4
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lives Are Saved',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your gift brings hope and new life to patients waiting for transplants.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              height: 1.3,
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
          const SizedBox(height: 24),
          // General Information Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue Header with Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'General Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Form Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _personalFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your first name',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Middle Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Middle Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _middleNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your middle name',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Last Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your last name',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Blood Type
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blood Type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _bloodType,
                              items:
                                  [
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
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _bloodType = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Date of Birth
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _dobController,
                              onChanged: _calculateAge,
                              decoration: InputDecoration(
                                hintText: 'MM/DD/YYYY',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Gender
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _gender,
                              items: ['Male', 'Female', 'Other']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Phone Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: 'Enter your phone number',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Address
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Enter your address in detail...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Emergency Contact Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Contact (optional)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emergencyContactController,
                              decoration: InputDecoration(
                                hintText: 'Enter emergency contact name',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Emergency Contact Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Contact Number (optional)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter emergency contact number',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Next Step Button
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              onPressed: _validateStep1()
                                  ? () {
                                      setState(() {
                                        _currentStep = 1;
                                      });
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                'Next Step',
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Frequently Asked Questions Section
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
                      'Organs are allocated based on medical urgency, compatibility, and time spent on the waiting list, following strict ethical guidelines.',
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
                // Privacy Notice
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator('G', 'General Info', true, true),
              Container(
                width: 60,
                height: 2,
                color: Color(0xFF2563EB),
                margin: EdgeInsets.only(bottom: 24),
              ),
              _buildStepIndicator('P', 'Personal Info', true, false),
              Container(
                width: 60,
                height: 2,
                color: Colors.grey.shade300,
                margin: EdgeInsets.only(bottom: 24),
              ),
              _buildStepIndicator('O', 'Organ Submission', false, false),
            ],
          ),
          const SizedBox(height: 24),
          // Personal Information Form
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue Header with Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Form Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _personalFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marital Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marital Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              hint: Text('Select a state'),
                              items:
                                  [
                                        'Single',
                                        'Married',
                                        'Divorced or separated',
                                        'Widowed',
                                      ]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _maritalStatus = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mother's Full Name (shown when Single is selected)
                        if (_maritalStatus == 'Single')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mother\'s Full Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _motherNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Mother\'s full name is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter mother\'s full name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_maritalStatus == 'Single')
                          const SizedBox(height: 16),
                        // Husband/Wife Full Name (shown when Married is selected)
                        if (_maritalStatus == 'Married')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Husband/Wife Full Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _spouseNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Husband/Wife full name is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter husband/wife full name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_maritalStatus == 'Married')
                          const SizedBox(height: 16),
                        // Ex-Spouse's Full Name (shown when Divorced or separated is selected)
                        if (_maritalStatus == 'Divorced or separated')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ex-Spouse\'s Full Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _exSpouseNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ex-spouse\'s full name is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter ex-spouse\'s full name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_maritalStatus == 'Divorced or separated')
                          const SizedBox(height: 16),
                        // Deceased Spouse's Full Name (shown when Widowed is selected)
                        if (_maritalStatus == 'Widowed')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deceased Spouse\'s Full Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _deceasedSpouseNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Deceased spouse\'s full name is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter deceased spouse\'s full name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_maritalStatus == 'Widowed')
                          const SizedBox(height: 16),
                        // Education Level
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Education Level',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              hint: Text('Select one'),
                              items:
                                  [
                                        'Elementary',
                                        'Intermediate',
                                        'Secondary',
                                        'University',
                                        'Graduate',
                                      ]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Professional Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Professional Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              hint: Text('Select a state'),
                              items: ['I do not work', 'I work']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _professionalStatus = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Job Type (shown when I work is selected)
                        if (_professionalStatus == 'I work')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _jobTypeController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Job type is required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter your job type',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_professionalStatus == 'I work')
                          const SizedBox(height: 16),
                        // ID Upload
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Valid ID',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'No file chosen',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2563EB),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      'Browse File',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Conditional Parent ID Upload for Minors
                        if (_isUnder18) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mother\'s ID Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'No file chosen',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF2563EB),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Browse File',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Father\'s ID Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'No file chosen',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF2563EB),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Browse File',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF1E40AF),
                                    Color(0xFF2563EB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  final needsMother =
                                      _maritalStatus == 'Single';
                                  if (needsMother) {
                                    if (_personalFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      setState(() {
                                        _currentStep = 2;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _currentStep = 2;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Next Step',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOrganSubmissionForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator('G', 'General Info', true, true),
              Container(
                width: 60,
                height: 2,
                color: Color(0xFF2563EB),
                margin: EdgeInsets.only(bottom: 24),
              ),
              _buildStepIndicator('P', 'Personal Info', true, true),
              Container(
                width: 60,
                height: 2,
                color: Color(0xFF2563EB),
                margin: EdgeInsets.only(bottom: 24),
              ),
              _buildStepIndicator('O', 'Organ Submission', true, false),
            ],
          ),
          const SizedBox(height: 24),
          // Organ Selection Form
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Organ and Tissues to Donate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hospital Selection
                      Text(
                        'Hospital Selection',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'General Donation (not specific to a hospital)',
                              ),
                              value: 'General Donation',
                              groupValue: _hospitalChoice,
                              onChanged: (value) {
                                setState(() {
                                  _hospitalChoice = value;
                                  _selectedHospital = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Select Specific Hospital'),
                              value: 'Specific Hospital',
                              groupValue: _hospitalChoice,
                              onChanged: (value) {
                                setState(() {
                                  _hospitalChoice = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_hospitalChoice == 'Specific Hospital') ...[
                        const SizedBox(height: 12),
                        Text(
                          'Hospital',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          hint: Text('Select Hospital'),
                          value: _selectedHospital,
                          items: _hospitals
                              .map(
                                (hospital) => DropdownMenuItem(
                                  value: hospital,
                                  child: Text(hospital),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHospital = value;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Declaration
                      Text(
                        'I declare, in full possession of my mental faculties and my own free will, that I donate after my death:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Organ Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _organs.length,
                        itemBuilder: (context, index) {
                          final organ = _organs[index];
                          return CheckboxListTile(
                            title: Text(organ),
                            value: _selectedOrgans[organ] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _selectedOrgans[organ] = value ?? false;
                                _donateAllOrgans = false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Donate All Organs
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Donate all organs and tissues',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: _donateAllOrgans,
                          onChanged: (value) {
                            setState(() {
                              _donateAllOrgans = value ?? false;
                              if (_donateAllOrgans) {
                                for (var organ in _organs) {
                                  _selectedOrgans[organ] = true;
                                }
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // What Happens Next
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What Happens Next ?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint(
                              'You\'ll receive an email with your registration details',
                            ),
                            _buildBulletPoint(
                              'Our team will review your application within 24 hours',
                            ),
                            _buildBulletPoint(
                              'If eligible, you\'ll be contacted for your approval via email and be added to the wait list for "After Death Hero Donors',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep = 1;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Green checkmark icon
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD4EDDA),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: Color(0xFF28A745),
                                                size: 50,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Title
                                            Text(
                                              'Registration Completed!',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            // Thank you message
                                            Text(
                                              'Thank You for Your Support',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            // Subtitle
                                            Text(
                                              'Your registration is a big support for us!',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.red,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            // Confirmation message
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Text(
                                                'A confirmation email has been sent to your registered email address. Please check.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Back Home button
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 40,
                                                    vertical: 14,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Back Home',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Complete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    String label,
    String title,
    bool isActive,
    bool isCompleted,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive
                ? Color(0xFF2563EB)
                : (isCompleted ? Color(0xFF2563EB) : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive || isCompleted
                    ? Colors.white
                    : Colors.grey.shade600,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Color(0xFF2563EB) : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      width: double.infinity,
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
