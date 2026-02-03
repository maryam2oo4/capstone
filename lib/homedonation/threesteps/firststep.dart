import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_picker_map.dart';
import '../../core/network/settings_service.dart';

class FirstStepForm extends StatefulWidget {
  final Map<String, dynamic> selectedRequest;
  final String selectedDate;
  final String selectedTime;
  final String donationType; // 'home' or 'hospital'
  final Function(Map<String, dynamic>) onContinue;

  const FirstStepForm({
    super.key,
    required this.selectedRequest,
    required this.selectedDate,
    required this.selectedTime,
    required this.donationType,
    required this.onContinue,
  });

  @override
  State<FirstStepForm> createState() => _FirstStepFormState();
}

class _FirstStepFormState extends State<FirstStepForm> {
  final _formKey = GlobalKey<FormState>();

  /// True only for home donation; hide address & location for hospital.
  bool get _isHomeDonation =>
      widget.donationType.trim().toLowerCase() == 'home';

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dateOfBirthController;
  late TextEditingController weightController;
  late TextEditingController addressController;
  late TextEditingController emergContactController;
  late TextEditingController emergPhoneController;

  String? selectedGender;
  double? latitude;
  double? longitude;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    assert(
      widget.donationType.trim().toLowerCase() == 'home' ||
          widget.donationType.trim().toLowerCase() == 'hospital',
      'donationType must be "home" or "hospital", got: "${widget.donationType}"',
    );
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dateOfBirthController = TextEditingController();
    weightController = TextEditingController();
    addressController = TextEditingController();
    emergContactController = TextEditingController();
    emergPhoneController = TextEditingController();
    _prefillFromRegistration();
  }

  Future<void> _prefillFromRegistration() async {
    try {
      final data = await SettingsService.getAllSettings();
      final user = data['profile']?['user'] ?? {};
      final donor = data['profile']?['donor'] ?? {};
      firstNameController.text = user['first_name'] ?? '';
      lastNameController.text = user['last_name'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone_nb'] ?? '';
      dateOfBirthController.text = donor['date_of_birth'] ?? '';
      addressController.text = user['address'] ?? donor['address'] ?? '';
      // Optionally prefill city, gender, etc. if available
      setState(() {});
    } catch (e) {
      // ignore: avoid_print
      print('Failed to prefill registration info: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    weightController.dispose();
    addressController.dispose();
    emergContactController.dispose();
    emergPhoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => isLoadingLocation = false);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoadingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location captured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openLocationPicker() async {
    // Get current location first if not available
    if (latitude == null || longitude == null) {
      await _getCurrentLocation();
    }
    if (latitude == null || longitude == null) return;

    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerMap(
          initialLatitude: latitude!,
          initialLongitude: longitude!,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _continueToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    final formData = <String, dynamic>{
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone_nb': phoneController.text,
      'date_of_birth': dateOfBirthController.text,
      'gender': selectedGender,
      'weight': weightController.text,
      'selected_date': widget.selectedDate,
      'selected_time': widget.selectedTime,
      'emerg_contact': emergContactController.text,
      'emerg_phone': emergPhoneController.text,
      if (_isHomeDonation) ...{
        'address': addressController.text,
        'latitude': latitude,
        'longitude': longitude,
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
              _buildStepLine(false),
              _buildStepIndicator(2, "Medical Info", false),
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
              "Personal Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // First Name
          _buildTextField(
            controller: firstNameController,
            label: "First Name",
            hint: "Enter your first name",
            icon: Icons.person,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Last Name
          _buildTextField(
            controller: lastNameController,
            label: "Last Name",
            hint: "Enter your last name",
            icon: Icons.person,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Email
          _buildTextField(
            controller: emailController,
            label: "Email Address",
            hint: "Enter your email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildTextField(
            controller: phoneController,
            label: "Phone Number",
            hint: "Enter your phone number",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Date of Birth
          _buildTextField(
            controller: dateOfBirthController,
            label: "Date of Birth",
            hint: "DD/MM/YYYY",
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context),
            readOnly: true,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Gender
          _buildGenderDropdown(),
          const SizedBox(height: 16),

          // Weight
          _buildTextField(
            controller: weightController,
            label: "Weight (kg)",
            hint: "Must be over 50kg",
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight < 50) {
                return 'Must be ≥50kg';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Address (home donation only)
          if (_isHomeDonation) ...[
            _buildTextField(
              controller: addressController,
              label: "Address",
              hint: "Enter your address in details..",
              icon: Icons.location_on,
              maxLines: 3,
              isRequired: true,
            ),
            const SizedBox(height: 16),
          ],

          // Emergency Contacts (Optional)
          _buildTextField(
            controller: emergContactController,
            label: "Emergency Contact (optional)",
            hint: "Enter emergency contact name",
            icon: Icons.contact_emergency,
            isRequired: false,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: emergPhoneController,
            label: "Emergency Contact Number (optional)",
            hint: "Enter emergency contact number",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            isRequired: false,
          ),
          const SizedBox(height: 16),

          // Location Sharing (home donation only)
          if (_isHomeDonation) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Share Your Location",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            latitude != null
                                ? Icons.location_on
                                : Icons.location_off,
                            color: latitude != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              latitude != null
                                  ? 'Location captured: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
                                  : 'No location shared yet',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoadingLocation
                              ? null
                              : _openLocationPicker,
                          icon: isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            isLoadingLocation
                                ? 'Getting Location...'
                                : latitude != null
                                ? 'Update Location on Map'
                                : 'Select Location on Map',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This helps our phlebotomist find your address easily',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Container(
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    bool isRequired = true,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person, color: Colors.grey.shade600),
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
          hint: const Text('Select a Gender'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select gender';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
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
        dateOfBirthController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }
}
