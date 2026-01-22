import 'package:flutter/material.dart';
import 'blood_donation_home.dart';
import 'blood_donation_hospital.dart';
import 'alive_organ_donation.dart';
import 'after_death_donation.dart';
import 'financial_support.dart';

class DonationCenterPage extends StatelessWidget {
  const DonationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donation Center'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Blood Donation Section
                _buildSectionHeader('BLOOD DONATION'),
                const SizedBox(height: 12),
                _buildDonationOption(
                  context,
                  icon: Icons.home,
                  title: 'Home Donation',
                  subtitle: 'Donate from the comfort of your home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BloodDonationHomePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildDonationOption(
                  context,
                  icon: Icons.local_hospital,
                  title: 'Hospital Donation',
                  subtitle: 'Visit donation centers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BloodDonationHospitalPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Organ Donation Section
                _buildSectionHeader('ORGAN DONATION'),
                const SizedBox(height: 12),
                _buildDonationOption(
                  context,
                  icon: Icons.favorite,
                  title: 'Living Donor',
                  subtitle: 'Living organ donation registration',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AliveOrganDonationPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildDonationOption(
                  context,
                  icon: Icons.health_and_safety,
                  title: 'After Death',
                  subtitle: 'Posthumous organ donation pledge',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AfterDeathDonationPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Financial Support Section
                _buildSectionHeader('FINANCIAL SUPPORT'),
                const SizedBox(height: 12),
                _buildDonationOption(
                  context,
                  icon: Icons.attach_money,
                  title: 'Surgical Donation',
                  subtitle: 'Support surgical procedures',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FinancialSupportPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDonationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}
