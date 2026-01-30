import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/public_service.dart';
import '../core/network/support_service.dart';
import '_support_card.dart';
import '_faq_drawer_section.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _contactPhone;
  String? _systemEmail;
  bool _supportContactLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupportContact();
  }

  Future<void> _loadSupportContact() async {
    try {
      final data = await PublicService.getSystemSettings();
      if (!mounted) return;
      setState(() {
        _contactPhone = data['contact_phone']?.toString();
        _systemEmail = data['system_email']?.toString();
        _supportContactLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _supportContactLoading = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _categoryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_formKey.currentState?.validate() != true) return;
    final subject = _subjectController.text.trim();
    final category = _categoryController.text.trim();
    final message = _messageController.text.trim();

    try {
      await SupportService.submitTicket({
        'subject': subject,
        'category': category,
        'message': message,
      });
      if (!mounted) return;
      _subjectController.clear();
      _categoryController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent. We\'ll get back to you soon.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      String msg = 'Failed to send. Please try again.';
      final d = e.response?.data;
      if (d is Map) {
        msg = (d['message'] ?? d['error'] ?? msg).toString();
        final errors = d['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) msg = first.first.toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: ${e is Exception ? e.toString().replaceFirst('Exception: ', '') : "Please try again."}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.85;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Find answers to common questions or get in touch with our support team for personalized assistance.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Support cards: Call & Email from backend, Live Chat static
            if (_supportContactLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              SupportCard.callCard(
                width: cardWidth,
                phone: _contactPhone,
                hours: null,
              ),
              const SizedBox(height: 16),
              SupportCard(
                width: cardWidth,
                icon: Icons.chat_bubble,
                iconColor: Colors.blue,
                title: 'Live Chat',
                subtitle: 'Chat with our AI assistant',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Start Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Available 24/7',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SupportCard.emailCard(
                width: cardWidth,
                email: _systemEmail,
                responseTime: null,
              ),
            ],
            const SizedBox(height: 28),
            // FAQ Section title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FaqDrawerSection(),
            const SizedBox(height: 32),
            // Contact Support Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Can't find what you're looking for? Send us a message.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a subject'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a category'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                      isDense: true,
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a message'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB71C1C), Color(0xFFFF1744)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ElevatedButton(
                        onPressed: _handleSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Send Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
