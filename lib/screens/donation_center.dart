import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'blood_donation_home.dart';
import 'blood_donation_hospital.dart';
import 'alive_organ_donation.dart';
import 'after_death_donation.dart';
import 'financial_support.dart';
import '../core/network/public_service.dart';

class DonationCenterPage extends StatefulWidget {
  const DonationCenterPage({super.key});

  @override
  State<DonationCenterPage> createState() => _DonationCenterPageState();
}

class _DonationCenterPageState extends State<DonationCenterPage> {
  bool _loading = true;
  String? _error;
  String? _platformName;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        PublicService.getSystemSettings(),
        PublicService.getDonationStats(),
      ]);
      if (!mounted) return;
      final settings = results[0];
      final stats = results[1];
      setState(() {
        _platformName = settings['platform_name']?.toString();
        _stats = stats;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'] ?? '')
          : e.message;
      final errStr = msg?.toString().trim() ?? '';
      setState(() {
        _error = errStr.isEmpty ? 'Failed to load data.' : errStr;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _platformName != null && _platformName!.isNotEmpty
              ? '$_platformName Donation Center'
              : 'Donation Center',
        ),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_stats != null) ...[
                            _buildStatsCard(),
                            const SizedBox(height: 20),
                          ],
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

  Widget _buildStatsCard() {
    final metrics = _stats!['metrics'];
    if (metrics is! Map) return const SizedBox.shrink();
    final blood = metrics['blood_donations_per_year'];
    final organ = metrics['organ_transplants_per_year'];
    final year = _stats!['year'];
    String bloodStr = '—';
    if (blood is int) {
      if (blood >= 1000000) {
        bloodStr = '${(blood / 1000000).toStringAsFixed(1)}M+';
      } else if (blood >= 1000) {
        bloodStr = '${(blood / 1000).toStringAsFixed(0)}K+';
      } else {
        bloodStr = '$blood';
      }
    }
    String organStr = '—';
    if (organ is int) {
      if (organ >= 1000000) {
        organStr = '${(organ / 1000000).toStringAsFixed(1)}M+';
      } else if (organ >= 1000) {
        organStr = '${(organ / 1000).toStringAsFixed(0)}K+';
      } else {
        organStr = '$organ';
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F72FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2F72FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact at a glance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          if (year != null && year.toString().isNotEmpty)
            Text(
              'Worldwide estimates ($year)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  Icons.bloodtype,
                  'Blood donations/year',
                  bloodStr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatChip(
                  Icons.health_and_safety,
                  'Organ transplants/year',
                  organStr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2F72FF)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
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
