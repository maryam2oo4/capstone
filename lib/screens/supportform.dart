import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/network/financial_service.dart';

class SupportFormScreen extends StatefulWidget {
  final String patientName;
  final int? patientCaseId;

  const SupportFormScreen({
    super.key,
    required this.patientName,
    this.patientCaseId,
  });

  @override
  State<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends State<SupportFormScreen> {
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _selectedAmount = 0;
  String _donationType = '';
  String _selectedRecipient = '';
  String _selectedPayment = '';
  bool _anonymous = false;
  bool _stayUpdated = false;

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I know my donation reaches patients?',
      'a':
          'We provide regular updates and receipts showing exactly how your donation was used. All funds go directly to medical expenses.',
    },
    {
      'q': 'What payment methods do you accept?',
      'a':
          'We accept credit cards, PayPal, and bank transfers. All payments are processed through secure, encrypted systems.',
    },
    {
      'q': 'Can I donate to multiple patients?',
      'a':
          'Yes! You can make separate donations to different patients or contribute to our general fund that helps all urgent cases.',
    },
    {
      'q': 'Can I cancel my monthly donation?',
      'a':
          'Absolutely. You can cancel or modify your monthly donation at any time by contacting our support team.',
    },
    {
      'q': 'Are donations tax-deductible?',
      'a':
          'Yes, we provide official receipts for tax purposes. Keep your donation receipt for tax filing.',
    },
    {
      'q': 'How are patients selected for the program?',
      'a':
          'Patients are referred by partner hospitals based on medical need and financial hardship. All cases are verified by medical professionals.',
    },
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collectFormData() {
    final double amount = _selectedAmount > 0
        ? _selectedAmount.toDouble()
        : double.tryParse(_customAmountController.text.trim()) ?? 0;

    return {
      'donationType': _donationType,
      'amount': amount,
      'recipient': _selectedRecipient,
      'paymentMethod': _selectedPayment,
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'anonymous': _anonymous,
      'stayUpdated': _stayUpdated,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _handleSubmit() async {
    final double amount = _selectedAmount > 0
        ? _selectedAmount.toDouble()
        : double.tryParse(_customAmountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a valid amount.')),
      );
      return;
    }

    final donationType = _donationType == 'monthly' ? 'monthly' : 'one time';
    final recipientChosen = _selectedRecipient == 'specific'
        ? 'specific patient'
        : 'general patient';
    String paymentMethod = 'credit card';
    if (_selectedPayment == 'wish') {
      paymentMethod = 'wish';
    } else if (_selectedPayment == 'paypal' || _selectedPayment == 'credit') {
      paymentMethod = 'credit card';
    } else if (_selectedPayment == 'cash') {
      paymentMethod = 'cash';
    }

    final payload = <String, dynamic>{
      'donation_type': donationType,
      'donation_amount': amount,
      'recipient_chosen': recipientChosen,
      'payment_method': paymentMethod,
      'name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };
    if (_selectedRecipient == 'specific' && widget.patientCaseId != null) {
      payload['patient_case_id'] = widget.patientCaseId;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FinancialService.submitDonation(payload);
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10A557),
                  size: 64,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Support Confirmed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You pledged \$${amount.toStringAsFixed(2)} as a ${_donationType == 'monthly' ? 'monthly' : 'one-time'} gift.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10A557),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['errors']?.toString() ?? '')
          : e.message;
      final displayMsg = (msg?.toString().trim() ?? '').isEmpty
          ? 'Failed to submit donation.'
          : msg.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(displayMsg)),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit donation.')),
      );
    }
  }

  Widget _buildAmountButton(int amount) {
    final bool isSelected = _selectedAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAmount = amount;
            _customAmountController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00C17F).withOpacity(0.08)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00C17F)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                '\$$amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF00C17F) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String keyValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required String groupValue,
    required void Function(String) onSelect,
  }) {
    final bool isSelected = groupValue == keyValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => onSelect(keyValue)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 160),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0E8A53).withOpacity(0.07)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0E8A53)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0E8A53), size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _faqs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq['q']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    faq['a']!,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support ${widget.patientName}'),
        elevation: 6,
        shadowColor: Colors.black45,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E8A53), Color(0xFF0B7A3F)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Make Your Donation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Donation Type
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.volunteer_activism,
                        color: Color(0xFF0E8A53),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Donation Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _donationType = 'one-time'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            constraints: const BoxConstraints(minHeight: 130),
                            decoration: BoxDecoration(
                              color: _donationType == 'one-time'
                                  ? const Color(0xFF0E8A53).withOpacity(0.07)
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _donationType == 'one-time'
                                    ? const Color(0xFF0E8A53)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.favorite,
                                  color: Color(0xFF0E8A53),
                                  size: 28,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'One-Time Donation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Make a single contribution',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _donationType = 'monthly'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            constraints: const BoxConstraints(minHeight: 130),
                            decoration: BoxDecoration(
                              color: _donationType == 'monthly'
                                  ? const Color(0xFF0E8A53).withOpacity(0.07)
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _donationType == 'monthly'
                                    ? const Color(0xFF0E8A53)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF0E8A53),
                                  size: 28,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Monthly Support',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Recurring monthly help',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Donation Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.attach_money,
                        color: Color(0xFF0E8A53),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Donation Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildAmountButton(10),
                      const SizedBox(width: 8),
                      _buildAmountButton(25),
                      const SizedBox(width: 8),
                      _buildAmountButton(50),
                      const SizedBox(width: 8),
                      _buildAmountButton(100),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Custom Amount',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(width: 12),
                        const Text('\$', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedAmount = 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Choose Recipient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.volunteer_activism,
                        color: Color(0xFF0E8A53),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Choose Recipient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildChoiceCard(
                        keyValue: 'general',
                        title: 'General Patient Fund',
                        subtitle: 'Supports any urgent medical case',
                        icon: Icons.shield_moon,
                        groupValue: _selectedRecipient,
                        onSelect: (val) => _selectedRecipient = val,
                      ),
                      const SizedBox(width: 10),
                      _buildChoiceCard(
                        keyValue: 'specific',
                        title: 'Specific Patient',
                        subtitle: 'Choose a patient to support directly',
                        icon: Icons.person,
                        groupValue: _selectedRecipient,
                        onSelect: (val) => _selectedRecipient = val,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.payment, color: Color(0xFF0E8A53), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildChoiceCard(
                        keyValue: 'credit',
                        title: 'Credit Card',
                        subtitle: '',
                        icon: Icons.credit_card,
                        groupValue: _selectedPayment,
                        onSelect: (val) => _selectedPayment = val,
                      ),
                      const SizedBox(width: 10),
                      _buildChoiceCard(
                        keyValue: 'paypal',
                        title: 'PayPal',
                        subtitle: '',
                        icon: Icons.account_balance_wallet,
                        groupValue: _selectedPayment,
                        onSelect: (val) => _selectedPayment = val,
                      ),
                      const SizedBox(width: 10),
                      _buildChoiceCard(
                        keyValue: 'wish',
                        title: 'Wish',
                        subtitle: '',
                        icon: Icons.card_giftcard,
                        groupValue: _selectedPayment,
                        onSelect: (val) => _selectedPayment = val,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Information (optional)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.contact_page,
                        color: Color(0xFF0E8A53),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Contact Information (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preferences
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune, color: Color(0xFF0E8A53), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _anonymous,
                    onChanged: (val) =>
                        setState(() => _anonymous = val ?? false),
                    title: const Text(
                      'Make this donation anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Your name will not be shared with patients or publicly',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _stayUpdated,
                    onChanged: (val) =>
                        setState(() => _stayUpdated = val ?? false),
                    title: const Text(
                      "I want to stay updated on the patient's progress",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive updates on how your donation is helping',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B6B3A), Color(0xFF10A557)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Donate Securely',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FAQs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFaqGrid(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'All your information is kept confidential and shared only with partner hospitals for evaluation purposes. We use industry-standard encryption to protect your data and comply with all medical privacy regulations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Embeddable version of the support form (no Scaffold/AppBar)
class SupportFormContent extends StatefulWidget {
  final String patientName;
  final String selectedPatientName;
  final int? patientCaseId;
  final VoidCallback? onSelectSpecificPatient;
  final Function(String)? onPatientSelected;

  const SupportFormContent({
    super.key,
    required this.patientName,
    this.selectedPatientName = '',
    this.patientCaseId,
    this.onSelectSpecificPatient,
    this.onPatientSelected,
  });

  @override
  State<SupportFormContent> createState() => _SupportFormContentState();
}

class _SupportFormContentState extends State<SupportFormContent> {
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _selectedAmount = 0;
  String _donationType = '';
  String _selectedRecipient = '';
  String _selectedPayment = '';
  bool _anonymous = false;
  bool _stayUpdated = false;

  @override
  void didUpdateWidget(SupportFormContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPatientName.isNotEmpty &&
        widget.selectedPatientName != oldWidget.selectedPatientName) {
      setState(() {
        _selectedRecipient = 'specific';
      });
    }
  }

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I know my donation reaches patients?',
      'a':
          'We provide regular updates and receipts showing exactly how your donation was used. All funds go directly to medical expenses.',
    },
    {
      'q': 'What payment methods do you accept?',
      'a':
          'We accept credit cards, PayPal, and bank transfers. All payments are processed through secure, encrypted systems.',
    },
    {
      'q': 'Can I donate to multiple patients?',
      'a':
          'Yes! You can make separate donations to different patients or contribute to our general fund that helps all urgent cases.',
    },
    {
      'q': 'Can I cancel my monthly donation?',
      'a':
          'Absolutely. You can cancel or modify your monthly donation at any time by contacting our support team.',
    },
    {
      'q': 'Are donations tax-deductible?',
      'a':
          'Yes, we provide official receipts for tax purposes. Keep your donation receipt for tax filing.',
    },
    {
      'q': 'How are patients selected for the program?',
      'a':
          'Patients are referred by partner hospitals based on medical need and financial hardship. All cases are verified by medical professionals.',
    },
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collectFormData() {
    final double amount = _selectedAmount > 0
        ? _selectedAmount.toDouble()
        : double.tryParse(_customAmountController.text.trim()) ?? 0;

    return {
      'donationType': _donationType,
      'amount': amount,
      'recipient': _selectedRecipient,
      'paymentMethod': _selectedPayment,
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'anonymous': _anonymous,
      'stayUpdated': _stayUpdated,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _handleSubmit() async {
    final double amount = _selectedAmount > 0
        ? _selectedAmount.toDouble()
        : double.tryParse(_customAmountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a valid amount.')),
      );
      return;
    }

    final donationType = _donationType == 'monthly' ? 'monthly' : 'one time';
    final recipientChosen = _selectedRecipient == 'specific'
        ? 'specific patient'
        : 'general patient';
    String paymentMethod = 'credit card';
    if (_selectedPayment == 'wish') {
      paymentMethod = 'wish';
    } else if (_selectedPayment == 'paypal' || _selectedPayment == 'credit') {
      paymentMethod = 'credit card';
    } else if (_selectedPayment == 'cash') {
      paymentMethod = 'cash';
    }

    final payload = <String, dynamic>{
      'donation_type': donationType,
      'donation_amount': amount,
      'recipient_chosen': recipientChosen,
      'payment_method': paymentMethod,
      'name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };
    if (_selectedRecipient == 'specific' && widget.patientCaseId != null) {
      payload['patient_case_id'] = widget.patientCaseId;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FinancialService.submitDonation(payload);
      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10A557),
                  size: 64,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Support Confirmed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You pledged \$${amount.toStringAsFixed(2)} as a ${_donationType == 'monthly' ? 'monthly' : 'one-time'} gift.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10A557),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['errors']?.toString() ?? '')
          : e.message;
      final displayMsg = (msg?.toString().trim() ?? '').isEmpty
          ? 'Failed to submit donation.'
          : msg.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(displayMsg)),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit donation.')),
      );
    }
  }

  Widget _buildAmountButton(int amount) {
    final bool isSelected = _selectedAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAmount = amount;
            _customAmountController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00C17F).withOpacity(0.08)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00C17F)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                '\$${amount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF00C17F) : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String keyValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required String groupValue,
    required void Function(String) onSelect,
  }) {
    final bool isSelected = groupValue == keyValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => onSelect(keyValue)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 160),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0E8A53).withOpacity(0.07)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0E8A53)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0E8A53), size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _faqs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq['q']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    faq['a']!,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E8A53), Color(0xFF0B7A3F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Make Your Donation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Donation Type
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.volunteer_activism,
                    color: Color(0xFF0E8A53),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Donation Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _donationType = 'one-time'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        constraints: const BoxConstraints(
                          minHeight: 160,
                          maxHeight: 160,
                        ),
                        decoration: BoxDecoration(
                          color: _donationType == 'one-time'
                              ? const Color(0xFF0E8A53).withOpacity(0.07)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _donationType == 'one-time'
                                ? const Color(0xFF0E8A53)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.favorite,
                              color: Color(0xFF0E8A53),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'One-Time Donation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Make a single contribution',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _donationType = 'monthly'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        constraints: const BoxConstraints(
                          minHeight: 160,
                          maxHeight: 160,
                        ),
                        decoration: BoxDecoration(
                          color: _donationType == 'monthly'
                              ? const Color(0xFF0E8A53).withOpacity(0.07)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _donationType == 'monthly'
                                ? const Color(0xFF0E8A53)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.calendar_today,
                              color: Color(0xFF0E8A53),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Monthly Support',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Recurring monthly help',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Donation Amount
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.attach_money, color: Color(0xFF0E8A53), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Donation Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildAmountButton(10),
                  const SizedBox(width: 8),
                  _buildAmountButton(25),
                  const SizedBox(width: 8),
                  _buildAmountButton(50),
                  const SizedBox(width: 8),
                  _buildAmountButton(100),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Custom Amount',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    const Text('\$', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedAmount = 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Choose Recipient
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.volunteer_activism,
                    color: Color(0xFF0E8A53),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Choose Recipient',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChoiceCard(
                    keyValue: 'general',
                    title: 'General Patient Fund',
                    subtitle: 'Supports any urgent medical case',
                    icon: Icons.shield_moon,
                    groupValue: _selectedRecipient,
                    onSelect: (val) {
                      setState(() => _selectedRecipient = val);
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildChoiceCard(
                    keyValue: 'specific',
                    title: 'Specific Patient',
                    subtitle: widget.selectedPatientName.isEmpty
                        ? 'Choose a patient to support directly'
                        : 'Donate for ${widget.selectedPatientName}',
                    icon: Icons.person,
                    groupValue: _selectedRecipient,
                    onSelect: (val) {
                      setState(() => _selectedRecipient = val);
                      widget.onSelectSpecificPatient?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.payment, color: Color(0xFF0E8A53), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChoiceCard(
                    keyValue: 'credit',
                    title: 'Credit Card',
                    subtitle: '',
                    icon: Icons.credit_card,
                    groupValue: _selectedPayment,
                    onSelect: (val) => _selectedPayment = val,
                  ),
                  const SizedBox(width: 10),
                  _buildChoiceCard(
                    keyValue: 'paypal',
                    title: 'PayPal',
                    subtitle: '',
                    icon: Icons.account_balance_wallet,
                    groupValue: _selectedPayment,
                    onSelect: (val) => _selectedPayment = val,
                  ),
                  const SizedBox(width: 10),
                  _buildChoiceCard(
                    keyValue: 'wish',
                    title: 'Wish',
                    subtitle: '',
                    icon: Icons.card_giftcard,
                    groupValue: _selectedPayment,
                    onSelect: (val) => _selectedPayment = val,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Contact Information (optional)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.contact_page, color: Color(0xFF0E8A53), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Contact Information (optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Preferences
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.tune, color: Color(0xFF0E8A53), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _anonymous,
                onChanged: (val) => setState(() => _anonymous = val ?? false),
                title: const Text(
                  'Make this donation anonymous',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Your name will not be shared with patients or publicly',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _stayUpdated,
                onChanged: (val) => setState(() => _stayUpdated = val ?? false),
                title: const Text(
                  "I want to stay updated on the patient's progress",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Receive updates on how your donation is helping',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B6B3A), Color(0xFF10A557)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Donate Securely',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // FAQs
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              _buildFaqGrid(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'All your information is kept confidential and shared only with partner hospitals for evaluation purposes. We use industry-standard encryption to protect your data and comply with all medical privacy regulations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
