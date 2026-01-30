import 'package:flutter/material.dart';
import 'blood_donation_home.dart';
import 'alive_organ_donation.dart';
import 'financial_support.dart';

class OverallPage extends StatefulWidget {
  const OverallPage({super.key});

  @override
  State<OverallPage> createState() => _OverallPageState();
}

class _OverallPageState extends State<OverallPage> {
  final ScrollController _historyController = ScrollController();
  final List<Map<String, dynamic>> _submittedRatings = [];

  Future<void> _showRatingDialog(String title) async {
    int tempRating = 0;
    final TextEditingController commentController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Rate your $title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Your Rating',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          starIndex <= tempRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() {
                          // Tap the same star again to clear rating back to 0.
                          if (tempRating == starIndex) {
                            tempRating = 0;
                          } else {
                            tempRating = starIndex;
                          }
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Comment (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us about your experience...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2F72FF)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        elevation: MaterialStateProperty.all(0),
                      ),
                  onPressed: () {
                    final ratingData = {
                      'rating': tempRating,
                      'comment': commentController.text.trim(),
                      'title': title,
                      'timestamp': DateTime.now().toIso8601String(),
                    };
                    Navigator.of(context).pop(ratingData);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E4FB8), Color(0xFF2F72FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Save Rating',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      _submittedRatings.add(result);
      print('Rating saved: $result');
      // TODO: Send to backend when connected
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rating saved!')));
    }
  }

  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85; // 85% of screen width for phone

    // Mock data placeholders – replace with backend data later
    const levelTitle = 'Level 1 Progress';
    const double currentXp = 120;
    const double nextLevelXp = 200;
    const int totalXp = 120;
    const int donationsCount = 3;
    const int livesSaved = 2;

    final List<Map<String, String>> appointments = [
      {'hospital': 'City Hospital', 'date': 'Feb 02', 'time': '10:30 AM'},
      {'hospital': 'Green Valley Clinic', 'date': 'Feb 10', 'time': '02:00 PM'},
    ];

    final List<Map<String, String>> history = [
      {
        'type': 'Home Donation',
        'status': 'Pending',
        'date': 'Jan 21',
        'reward': 'loading…',
        'rating': '--',
        'statusColor': 'amber',
      },
      {
        'type': 'Home Donation',
        'status': 'Completed',
        'date': 'Jan 15',
        'reward': '+120 XP',
        'rating': 'Rate',
        'statusColor': 'green',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'d like to help',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // 3 Donation Option Cards
            Center(
              child: Column(
                children: [
                  // Card 1: Blood Donation
                  _DonationCard(
                    icon: Icons.favorite,
                    iconBackgroundColor: const Color(0xFFE53E3E), // Red
                    title: 'Schedule\nBlood Donation',
                    subtitle: 'Register blood donation\nappointment',
                    width: cardWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BloodDonationHomePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Card 2: Organ Donation
                  _DonationCard(
                    icon: Icons.volunteer_activism,
                    iconBackgroundColor: const Color(0xFF16A34A), // Green
                    title: 'Register\nOrgan Donation',
                    subtitle: 'Pledge to save lives',
                    width: cardWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AliveOrganDonationPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Card 3: Financial Support
                  _DonationCard(
                    icon: Icons.favorite,
                    iconBackgroundColor: const Color(0xFF9333EA), // Purple
                    title: 'Provide\nFinancial Support',
                    subtitle: 'Contribute to patient care',
                    width: cardWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FinancialSupportPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress and stats
            _SectionCard(
              title: levelTitle,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalXp XP until level 2',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: currentXp / nextLevelXp,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF10A557),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total XP: $totalXp',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick stats card
            _SectionCard(
              title: 'Progress',
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatTile(
                    label: 'You have donated',
                    value: '$donationsCount times',
                  ),
                  _StatTile(label: 'You\'ve saved', value: '$livesSaved lives'),
                  _StatTile(label: 'Total XP earned', value: '$totalXp xp'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Upcoming appointments
            _SectionCard(
              title: 'Upcoming Appointments',
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: appointments.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No upcoming appointments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : Column(
                      children: appointments
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['hospital'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      item['date'] ?? '',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      item['time'] ?? '',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            const SizedBox(height: 16),

            // Donation history
            _SectionCard(
              title: 'Donation History',
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SizedBox(
                height: 110,
                child: Scrollbar(
                  controller: _historyController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _historyController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 800),
                      child: Column(
                        children: history
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        item['type'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        item['status'] ?? '',
                                        style: TextStyle(
                                          color: _statusColor(
                                            item['statusColor'] ?? 'grey',
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        item['date'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        item['reward'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    SizedBox(
                                      width: 110,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _RatingChip(
                                          label: item['rating'] ?? '',
                                          onTap:
                                              (item['rating'] ?? '')
                                                      .toLowerCase() ==
                                                  'rate'
                                              ? () => _showRatingDialog(
                                                  item['type'] ?? 'donation',
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final double width;
  final VoidCallback onTap;

  const _DonationCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets padding;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _RatingChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isAction = label.toLowerCase() == 'rate';
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAction ? null : Colors.grey[200],
        gradient: isAction
            ? const LinearGradient(
                colors: [Color(0xFF1E4FB8), Color(0xFF2F72FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isAction ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );

    if (isAction && onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}

Color _statusColor(String key) {
  switch (key) {
    case 'green':
      return const Color(0xFF10A557);
    case 'amber':
      return const Color(0xFFF59E0B);
    default:
      return Colors.grey;
  }
}
