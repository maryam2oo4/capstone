import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../core/network/settings_service.dart';
import '../core/network/profile_mapper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController(
    text: 'User Name',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'user@email.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+1 234 567 890',
  );
  final TextEditingController _addressController = TextEditingController(
    text: '123 Main Street, City, Country',
  );
  final TextEditingController _cityController = TextEditingController(
    text: 'Beirut',
  );
  DateTime? _selectedDate = DateTime(2000, 1, 1);

  @override
  void initState() {
    super.initState();
    _fetchAndSetProfile();
  }

  Future<void> _fetchAndSetProfile() async {
    try {
      final data = await SettingsService.getAllSettings();
      // Debug print to help map fields if needed
      // ignore: avoid_print
      print('SettingsService.getAllSettings() response: $data');
      ProfileMapper.mapSettingsToControllers(
        data,
        setName: (v) => _nameController.text = v,
        setEmail: (v) => _emailController.text = v,
        setPhone: (v) => _phoneController.text = v,
        setAddress: (v) => _addressController.text = v,
        setCity: (v) => _cityController.text = v,
        setDate: (v) => setState(() => _selectedDate = v),
      );
      setState(() {});
    } catch (e) {
      // ignore: avoid_print
      print('Failed to fetch profile info: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            children: [
              // Avatar and Name
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final XFile? pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              _profileImage = File(pickedFile.path);
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.red.shade100,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Name',
                          labelStyle: TextStyle(fontSize: 14),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Info Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      _buildProfileField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildProfileField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildDatePicker(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B0000), // dark red
                      Color(0xFFFF0000), // red
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Save action: update backend, then reload profile
                    final profileData = {
                      // Map to backend expected keys
                      'first_name': _nameController.text.split(' ').first,
                      'last_name': _nameController.text.split(' ').length > 1
                          ? _nameController.text.split(' ').sublist(1).join(' ')
                          : '',
                      'email': _emailController.text,
                      'phone_nb': _phoneController.text,
                      'address': _addressController.text,
                      'city': _cityController.text,
                      // Add more fields if needed
                    };
                    try {
                      await SettingsService.updateProfile(profileData);
                      await _fetchAndSetProfile();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update profile: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save_alt, color: Colors.white),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.red.shade400),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1950),
          lastDate: DateTime(DateTime.now().year + 1),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _selectedDate == null
                ? ''
                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.cake_outlined, color: Colors.red.shade400),
            labelText: 'Date of Birth',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
