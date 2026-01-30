import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  // Dropdown + date vars
  String? selectedBlood;
  String? selectedCity;
  DateTime? selectedDate;

  // State
  bool _loading = false;
  String _error = '';
  final _formKey = GlobalKey<FormState>();

  // lists
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> lebanonCities = [
    "Beirut",
    "Tripoli",
    "Sidon",
    "Tyre",
    "Nabatieh",
    "Zahle",
    "Baalbek",
    "Byblos",
    "Jounieh",
    "Aley",
    "Chouf",
    "Keserwan",
    "Metn",
    "Akkar",
    "Batroun",
    "Zgharta",
    "Minieh",
    "Hermel",
  ];

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future pickBirthday() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!value.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      setState(() => _error = 'Please select your date of birth');
      return;
    }

    if (selectedBlood == null) {
      setState(() => _error = 'Please select your blood type');
      return;
    }

    if (passwordController.text != confirmPassController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final dio = await ApiClient.instance.dio();
      
      final registrationData = {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'confirmPassword': confirmPassController.text,
        'dob': selectedDate!.toIso8601String().split('T')[0], // YYYY-MM-DD
        'bloodType': selectedBlood,
        if (selectedCity != null && selectedCity!.isNotEmpty) 'city': selectedCity,
      };
      
      debugPrint('Registration data: $registrationData');
      
      final response = await dio.post(
        '/register',
        data: registrationData,
        options: Options(
          contentType: 'application/json',
          headers: {'Accept': 'application/json'},
        ),
      );
      
      debugPrint('Registration response: ${response.statusCode}');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on DioException catch (e) {
      String errorMsg = 'Registration failed. Please try again.';
      
      debugPrint('Registration error: ${e.response?.statusCode}');
      debugPrint('Error data: ${e.response?.data}');
      
      if (e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        
        // Check for message field
        if (data.containsKey('message')) {
          errorMsg = data['message'].toString();
        } 
        // Check for validation errors
        else if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            // Get the first error from the first field
            final firstField = errors.keys.first;
            final firstErrorList = errors[firstField];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMsg = '${firstField.replaceAll('_', ' ').toUpperCase()}: ${firstErrorList.first}';
            } else {
              errorMsg = firstErrorList.toString();
            }
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Cannot connect to server. Please check if the backend is running.';
      }

      if (mounted) {
        setState(() => _error = errorMsg);
      }
    } catch (e) {
      debugPrint('Unexpected registration error: $e');
      if (mounted) {
        setState(() => _error = 'An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            // Red header
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(140),
                  bottomRight: Radius.circular(140),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF330000), Color(0xFFB71C1C)],
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                children: const [
                  SizedBox(height: 40),
                  Text(
                    "Registration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top image
            SizedBox(
              height: 180,
              child: Image.asset("assets/images/register.png"),
            ),

            const SizedBox(height: 15),

            // Error message
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Form fields with margin around boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  buildField(
                    "Username",
                    controller: usernameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Username is required' : null,
                  ),
                  buildField(
                    "Email",
                    controller: emailController,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  buildField(
                    "Password",
                    controller: passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                  buildField(
                    "Confirm Password",
                    controller: confirmPassController,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  // Birthday + Blood type
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: pickBirthday,
                          child: Container(
                            height: 45,
                            margin: const EdgeInsets.only(top: 10, right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: box(),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedDate == null
                                  ? "Date of Birth"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          margin: const EdgeInsets.only(top: 10, left: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: box(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              hint: const Text(
                                "Blood Type",
                                style: TextStyle(color: Colors.black54),
                              ),
                              value: selectedBlood,
                              items: bloodTypes
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedBlood = v),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // City dropdown
                  Container(
                    height: 45,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: box(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Text(
                          "City",
                          style: TextStyle(color: Colors.black54),
                        ),
                        value: selectedCity,
                        items: lebanonCities
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedCity = v),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Register button
                  GestureDetector(
                    onTap: _loading ? null : _register,
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: _loading
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xffA60000), Color(0xffFF3D3D)],
                              ),
                        color: _loading ? Colors.grey.shade400 : null,
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text.rich(
                      const TextSpan(
                        text: "By signing in you agree to our ",
                        children: [
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    )
  );
  }

  // ---- reusable input field
  Widget buildField(
    String hint, {
    controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: validator != null ? null : 45,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: box(),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.black54),
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  BoxDecoration box() => BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(15),
  );
}
