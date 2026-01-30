import 'package:flutter/material.dart';

/// Reusable support/contact card. Use [SupportCard.callCard] and
/// [SupportCard.emailCard] to build from backend (system-settings) data.
class SupportCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget content;

  const SupportCard({
    required this.width,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.content,
    Key? key,
  }) : super(key: key);

  /// Call Us card built from backend contact_phone (and optional hours).
  static SupportCard callCard({
    required double width,
    String? phone,
    String? hours,
  }) {
    return SupportCard(
      width: width,
      icon: Icons.phone,
      iconColor: Colors.red,
      title: 'Call Us',
      subtitle: 'Speak with our support team',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phone?.trim().isNotEmpty == true ? phone! : '1-800-LIFELINK',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hours?.trim().isNotEmpty == true ? hours! : 'Mon-Fri 8AM-8PM EST',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Email Support card built from backend system_email.
  static SupportCard emailCard({
    required double width,
    String? email,
    String? responseTime,
  }) {
    return SupportCard(
      width: width,
      icon: Icons.email,
      iconColor: Colors.green,
      title: 'Email Support',
      subtitle: 'Send us a detailed message',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            email?.trim().isNotEmpty == true ? email! : 'lifelink.org.team@gmail.com',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            responseTime?.trim().isNotEmpty == true ? responseTime! : 'Response within 24 hours',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}
