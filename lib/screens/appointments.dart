import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/network/donor_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _organAppointments = [];
  List<Map<String, dynamic>> _appointmentsRaw = [];

  String searchQuery = '';
  String selectedSort = 'Date (Newest)';
  final List<String> sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'A-Z',
    'Z-A',
  ];
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await DonorService.getMyAppointments();
      if (!mounted) return;
      final aptList = data['appointments'];
      final organList = data['organ_appointments'];
      setState(() {
        _appointmentsRaw = aptList is List
            ? aptList
                .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
                .toList()
            : [];
        _organAppointments = organList is List
            ? organList
                .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
                .toList()
            : [];
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'] ?? '')
          : e.message;
      setState(() {
        _error = msg?.toString() ?? 'Failed to load appointments.';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load appointments.';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedAppointments {
    var list = List<Map<String, dynamic>>.from(_appointmentsRaw);
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((a) {
        final type = (a['donationType'] ?? a['type'] ?? '').toString().toLowerCase();
        final hospital = (a['hospitalName'] ?? a['hospital'] ?? '').toString().toLowerCase();
        return type.contains(q) || hospital.contains(q);
      }).toList();
    }
    if (selectedSort == 'Date (Newest)') {
      list.sort((a, b) {
        final dA = a['date']?.toString() ?? '';
        final dB = b['date']?.toString() ?? '';
        return dB.compareTo(dA);
      });
    } else if (selectedSort == 'Date (Oldest)') {
      list.sort((a, b) {
        final dA = a['date']?.toString() ?? '';
        final dB = b['date']?.toString() ?? '';
        return dA.compareTo(dB);
      });
    } else if (selectedSort == 'A-Z') {
      list.sort((a, b) {
        final hA = (a['hospitalName'] ?? a['hospital'] ?? '').toString();
        final hB = (b['hospitalName'] ?? b['hospital'] ?? '').toString();
        return hA.compareTo(hB);
      });
    } else if (selectedSort == 'Z-A') {
      list.sort((a, b) {
        final hA = (a['hospitalName'] ?? a['hospital'] ?? '').toString();
        final hB = (b['hospitalName'] ?? b['hospital'] ?? '').toString();
        return hB.compareTo(hA);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _loadAppointments,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 8 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Appointments (living organ pledges)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pending Appointments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage your upcoming appointments and stay informed',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 18),
                      _organAppointments.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No living organ pledges.',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            )
                          : Column(
                              children: _organAppointments.map((o) {
                                final code = o['code']?.toString() ?? '';
                                final organ = o['organ']?.toString() ?? '—';
                                final ethics = o['ethics_status']?.toString() ?? '—';
                                final medical = o['medical_status']?.toString() ?? '—';
                                final appStatus = o['appointment_status']?.toString() ?? '—';
                                final selectedAt = o['selected_appointment_at']?.toString();
                                String statusLabel = appStatus.replaceAll('_', ' ');
                                Color statusColor = Colors.amber;
                                String message = 'Your pledge is under review.';
                                if (appStatus == 'cancelled') {
                                  statusColor = Colors.red;
                                  message = 'This organ donation appointment was cancelled.';
                                } else if (selectedAt != null && selectedAt.isNotEmpty) {
                                  statusLabel = 'Appointment selected';
                                  message = 'Selected: $selectedAt';
                                } else if (ethics == 'approved' && medical == 'cleared') {
                                  message = 'Approved. You can choose an appointment when suggested.';
                                }
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pledge $code',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Organ: $organ • Ethics: $ethics • Medical: $medical',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                      if (selectedAt != null && selectedAt.isNotEmpty)
                                        Text(
                                          'Selected: $selectedAt',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search and Sort Row (moved after pending appointments)
                // Redesigned search and sort (card style, stacked)
                Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by hospital or type',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
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
                const SizedBox(height: 24),

                // Table
                Scrollbar(
                  thumbVisibility: true,
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalScrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 600 : 900,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
                            child: Row(
                              children: [
                                // Removed checkbox column
                                SizedBox(width: isMobile ? 8 : 12),
                                SizedBox(
                                  width: isMobile ? 100 : 150,
                                  child: Text(
                                    'Donation Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 120 : 180,
                                  child: Text(
                                    'Hospital Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 80 : 110,
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 60 : 80,
                                  child: Text(
                                    'Time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 90 : 130,
                                  child: Text(
                                    'Phlebotomist',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 70 : 100,
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 16 : 28),
                                SizedBox(
                                  width: isMobile ? 80 : 110,
                                  child: Text(
                                    'Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),
                          // Table rows from API
                          ..._filteredAndSortedAppointments.asMap().entries.map(
                            (entry) {
                              final a = entry.value;
                              final type = (a['donationType'] ?? a['type'] ?? '—').toString();
                              final hospital = (a['hospitalName'] ?? a['hospital'] ?? '—').toString();
                              final date = (a['date'] ?? '—').toString();
                              final time = (a['time'] ?? 'N/A').toString();
                              final phleb = a['phlebotomist'];
                              final phlebName = phleb is Map
                                  ? (phleb['name'] ?? '—').toString()
                                  : (phleb?.toString() ?? '—');
                              final status = (a['status'] ?? 'Pending').toString();
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: [
                                    SizedBox(width: isMobile ? 8 : 12),
                                    SizedBox(
                                      width: isMobile ? 100 : 150,
                                      child: Text(type, style: const TextStyle(fontSize: 13)),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 120 : 180,
                                      child: Text(hospital, style: const TextStyle(fontSize: 13)),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 80 : 110,
                                      child: Text(date, style: const TextStyle(fontSize: 13)),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 60 : 80,
                                      child: Text(time, style: const TextStyle(fontSize: 13)),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 90 : 130,
                                      child: Text(phlebName.isEmpty ? '—' : phlebName, style: const TextStyle(fontSize: 13)),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 70 : 100,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: status.toLowerCase() == 'cancelled'
                                              ? Colors.red.withOpacity(0.18)
                                              : Colors.amber.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: status.toLowerCase() == 'cancelled' ? Colors.red : Colors.amber,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 16 : 28),
                                    SizedBox(
                                      width: isMobile ? 80 : 110,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.visibility, color: Color(0xFF2F72FF), size: 18),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.edit, color: Colors.green, size: 18),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Cancel is not available from this screen.'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.delete, color: Colors.red, size: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (_filteredAndSortedAppointments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No appointments.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
