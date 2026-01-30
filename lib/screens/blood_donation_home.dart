import 'package:flutter/material.dart';
import '../homedonation/searchbar.dart';
import '../homedonation/calendar.dart';
import '../core/network/api_client.dart';

class BloodDonationHomePage extends StatefulWidget {
  const BloodDonationHomePage({super.key});

  @override
  State<BloodDonationHomePage> createState() => _BloodDonationHomePageState();
}

class _BloodDonationHomePageState extends State<BloodDonationHomePage> {
  String searchQuery = "";
  bool loading = true;
  String error = '';
  List<Map<String, dynamic>> urgentHospitals = [];
  List<Map<String, dynamic>> regularHospitals = [];

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final dio = await ApiClient.instance.dio();
      final res = await dio.get('/blood/home_donation');

      final urg = (res.data['urgent_hospitals'] as List?) ?? [];
      final reg = (res.data['regular_hospitals'] as List?) ?? [];

      setState(() {
        urgentHospitals = urg.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        regularHospitals = reg.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load hospitals. Make sure the backend is reachable.';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> _filterHospitals(List<Map<String, dynamic>> hospitals) {
    if (searchQuery.isEmpty) return hospitals;

    final query = searchQuery.toLowerCase();
    return hospitals.where((h) {
      final name = h["name"]?.toString().toLowerCase() ?? '';
      final address = h["address"]?.toString().toLowerCase() ?? '';
      final code = h["code"]?.toString().toLowerCase() ?? '';
      final bloodType = h["blood_type_needed"]?.toString().toLowerCase() ?? '';
      return name.contains(query) || address.contains(query) || code.contains(query) || bloodType.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUrgent = _filterHospitals(urgentHospitals);
    final filteredRegular = _filterHospitals(regularHospitals);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Blood Donation"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: _fetchHospitals, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(onSearch: handleSearch),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                    ),
                  if (!loading && error.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(error, style: const TextStyle(color: Colors.red)),
                      ),
                    ),
                  // Urgent Section
                  if (!loading && error.isEmpty && filteredUrgent.isNotEmpty) ...[
                    ...filteredUrgent.map(
                      (request) => _buildRequestCard(request, isUrgent: true),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Regular Section
                  if (!loading && error.isEmpty && filteredRegular.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          color: Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Registered Hospitals",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...filteredRegular.map(
                      (request) => _buildRequestCard(request, isUrgent: false),
                    ),
                  ],

                  // No results
                  if (!loading && error.isEmpty && filteredUrgent.isEmpty && filteredRegular.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          searchQuery.isEmpty
                              ? "No requests available"
                              : "No requests match your search",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request, {
    required bool isUrgent,
  }) {
    final hospitalName = request["name"] ?? request["hospital_name"] ?? "Unknown Hospital";
    final code = request["code"] ?? "N/A";
    final address = request["address"] ?? "N/A";
    final bloodTypeNeeded = request["blood_type_needed"];
    final dueDate = request["urgent_due_date"] ?? request["due_date"];
    final dueTime = request["urgent_due_time"] ?? request["due_time"];
    final availableSlots = request["available_slots"] ?? request["urgent_slots"] ?? request["regular_slots"];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isUrgent ? Color(0xFFFFE4E1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUrgent ? Colors.red.shade200 : Colors.transparent,
          width: isUrgent ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CalendarPage(
                    selectedRequest: {
                      'id': request['id'],
                      'name': hospitalName,
                      'address': address,
                      'blood_type_needed': bloodTypeNeeded,
                      'appointment_type': isUrgent ? 'urgent' : 'regular',
                    },
                    donationType: 'home',
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospitalName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          code,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "URGENT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (bloodTypeNeeded != null)
                _buildInfoRow(
                  Icons.bloodtype,
                  "Blood Type",
                  bloodTypeNeeded,
                ),

              if (availableSlots != null)
                _buildInfoRow(Icons.event_available, "Available Slots", availableSlots.toString()),

              if (isUrgent && dueDate != null)
                _buildInfoRow(
                  Icons.alarm,
                  "Due",
                  dueTime != null ? "$dueDate at $dueTime" : "$dueDate",
                  isHighlight: true,
                ),

              _buildInfoRow(Icons.location_on, "Address", address),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    dynamic value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlight ? Colors.red : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: TextStyle(
                fontSize: 13,
                color: isHighlight ? Colors.red.shade700 : Colors.black87,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
