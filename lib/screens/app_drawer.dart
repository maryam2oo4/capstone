import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/network/auth_service.dart';
import '../core/network/public_service.dart';
import 'dashboard.dart';
import 'my_donations.dart';
import 'appointments.dart';
import 'login.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: PublicService.getSystemSettings(),
              builder: (context, snapshot) {
                final logo = snapshot.data?['system_logo'];
                Widget child = Image.asset(
                  'assets/images/logol.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => Text(
                    snapshot.data?['platform_name']?.toString() ?? 'LifeLink',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                );
                if (logo != null && logo.toString().startsWith('data:image')) {
                  try {
                    final base64 = logo.toString().split(',').last;
                    child = Image.memory(
                      base64Decode(base64),
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => child,
                    );
                  } catch (_) {}
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: child,
                );
              },
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.black87),
                    title: const Text('Dashboard'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OverallPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bloodtype, color: Colors.black87),
                    title: const Text('My Donations'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyDonationsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.black87,
                    ),
                    title: const Text('Appointments'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsPage(),
                        ),
                      );
                    },
                  ),
                  // Rewards entry removed
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black87),
              title: const Text('Logout'),
              onTap: () async {
                // Close drawer
                Navigator.pop(context);
                // Call logout API and clear local auth state
                await AuthService.logout();
                if (!context.mounted) return;
                // Remove all routes and go to login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
