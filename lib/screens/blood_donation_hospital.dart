import 'package:flutter/material.dart';
import '../homedonation/searchbar.dart';
import '../homedonation/calendar.dart';
import '../core/network/api_client.dart';

class BloodDonationHospitalPage extends StatefulWidget {
  const BloodDonationHospitalPage({super.key});

  @override
  State<BloodDonationHospitalPage> createState() =>
      _BloodDonationHospitalPageState();
}

class _BloodDonationHospitalPageState extends State<BloodDonationHospitalPage> {
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
      final res = await dio.get('/blood/hospital_donation');

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
        title: const Text("Hospital Blood Donation"),
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
                      (hospital) => _buildRequestCard(hospital, isUrgent: true),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Regular Section
                  if (!loading && error.isEmpty && filteredRegular.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(
                          Icons.local_hospital,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
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
                      (hospital) => _buildRequestCard(hospital, isUrgent: false),
                    ),
                  ],

                  // No results
                  if (!loading && error.isEmpty && filteredUrgent.isEmpty && filteredRegular.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          searchQuery.isEmpty
                              ? "No hospitals available"
                              : "No hospitals match your search",
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
    Map<String, dynamic> hospital, {
    required bool isUrgent,
  }) {
    final hospitalName = hospital["name"] ?? "Unknown Hospital";
    final code = hospital["code"] ?? "N/A";
    final address = hospital["address"] ?? "N/A";
    final bloodTypeNeeded = hospital["blood_type_needed"];
    final availableSlots = hospital["available_slots"] ?? hospital["urgent_slots"] ?? hospital["regular_slots"];
    final urgentDueDate = hospital["urgent_due_date"] ?? hospital["due_date"];
    final urgentDueTime = hospital["urgent_due_time"] ?? hospital["due_time"];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isUrgent ? const Color(0xFFFFE4E1) : Colors.white,
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
              builder: (context) => CalendarPage(
                selectedRequest: {
                  'id': hospital['id'],
                  'name': hospitalName,
                  'address': address,
                  'blood_type_needed': bloodTypeNeeded,
                  'appointment_type': isUrgent ? 'urgent' : 'regular',
                },
                donationType: 'hospital',
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
                  "Blood Type Needed",
                  bloodTypeNeeded.toString(),
                ),

              if (availableSlots != null)
                _buildInfoRow(
                  Icons.event_available,
                  "Available Slots",
                  availableSlots.toString(),
                ),

              if (isUrgent && urgentDueDate != null)
                _buildInfoRow(
                  Icons.alarm,
                  "Due",
                  urgentDueTime != null ? "$urgentDueDate at $urgentDueTime" : "$urgentDueDate",
                ),

              _buildInfoRow(Icons.location_on, "Address", address),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
