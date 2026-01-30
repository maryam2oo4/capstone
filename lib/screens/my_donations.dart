import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/network/donor_service.dart';

class MyDonationsPage extends StatefulWidget {
  const MyDonationsPage({super.key});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _donations = [];

  String searchQuery = '';
  String selectedSort = 'Newest to Oldest';
  final ScrollController _horizontalScrollController = ScrollController();
  final List<String> sortOptions = [
    'A-Z',
    'Z-A',
    'Highest XP',
    'Newest to Oldest',
    'Oldest to Newest',
  ];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await DonorService.getMyDonations();
      if (!mounted) return;
      final raw = data['donations'];
      final list = raw is List
          ? raw
              .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
              .toList()
          : <Map<String, dynamic>>[];
      setState(() {
        _donations = list.map(_normalizeDonation).toList();
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'] ?? '')
          : e.message;
      final errStr = msg?.toString().trim() ?? '';
      setState(() {
        _error = errStr.isEmpty ? 'Failed to load donations.' : errStr;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load donations.';
        _loading = false;
      });
    }
  }

  /// Map API donation to UI shape: type, hospital, date, xp, status, statusColor, rating
  Map<String, dynamic> _normalizeDonation(Map<String, dynamic> d) {
    final type = (d['donationType'] ?? d['type'] ?? '—').toString();
    final hospital = (d['hospitalName'] ?? d['hospital'] ?? 'N/A').toString();
    final date = (d['date'] ?? '—').toString();
    final xp = (d['xpEarned'] ?? d['xp'] ?? '—').toString();
    final status = (d['status'] ?? 'Pending').toString();
    Color statusColor = Colors.amber;
    if (status.toLowerCase() == 'completed') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'canceled') {
      statusColor = Colors.red;
    } else if (status.toLowerCase() == 'active') {
      statusColor = const Color(0xFF10A557);
    }
    String rating = '--';
    final r = d['rating'];
    if (r is Map && r['rating'] != null) {
      final n = r['rating'] is int ? r['rating'] as int : int.tryParse(r['rating'].toString());
      if (n != null && n >= 1 && n <= 5) {
        rating = '★' * n + '☆' * (5 - n);
      }
    }
    return {
      'type': type,
      'hospital': hospital,
      'date': date,
      'xp': xp,
      'status': status,
      'statusColor': statusColor,
      'rating': rating,
    };
  }

  List<Map<String, dynamic>> get filteredDonations {
    var filtered = _donations.where((donation) {
      final hospitalName = donation['hospital'].toString().toLowerCase();
      final query = searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return hospitalName.contains(query);
    }).toList();

    switch (selectedSort) {
      case 'A-Z':
        filtered.sort((a, b) =>
            (a['hospital'] ?? '').toString().compareTo((b['hospital'] ?? '').toString()));
        break;
      case 'Z-A':
        filtered.sort((a, b) =>
            (b['hospital'] ?? '').toString().compareTo((a['hospital'] ?? '').toString()));
        break;
      case 'Highest XP':
        filtered.sort((a, b) {
          final xpA = int.tryParse((a['xp'] ?? '').toString().replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
          final xpB = int.tryParse((b['xp'] ?? '').toString().replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
          return xpB.compareTo(xpA);
        });
        break;
      case 'Newest to Oldest':
        filtered.sort((a, b) =>
            (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
        break;
      case 'Oldest to Newest':
        filtered.sort((a, b) =>
            (a['date'] ?? '').toString().compareTo((b['date'] ?? '').toString()));
        break;
    }
    return filtered;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _loading
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
                          onPressed: _loadDonations,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Donations',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your donations and stay informed',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFE53E3E), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Total Donations: ${_donations.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and filter row
            Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by hospital',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.clear, color: Colors.grey),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2F72FF),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: selectedSort,
                    items: sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSort = value;
                        });
                      }
                    },
                    underline: const SizedBox(),
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(Icons.unfold_more, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Donations table
            Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table header
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Donation Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 180,
                          child: Text(
                            'Hospital Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Xp Earned',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Rating',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Table rows
                    if (filteredDonations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No donations yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredDonations.map((donation) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                donation['type'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 180,
                              child: Text(
                                donation['hospital'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 110,
                              child: Text(
                                donation['date'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: Text(
                                donation['xp'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2F72FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (donation['statusColor'] as Color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  donation['status'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: donation['statusColor'] as Color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: donation['status'] != 'Pending'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        final ratingStr =
                                            donation['rating'] as String? ?? '';
                                        final filledStars = ratingStr
                                            .split('')
                                            .where((c) => c == '★')
                                            .length;
                                        return Icon(
                                          index < filledStars
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 18,
                                        );
                                      }),
                                    )
                                  : Text(
                                      '--',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
