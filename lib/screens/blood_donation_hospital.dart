import 'package:flutter/material.dart';
import '../homedonation/searchbar.dart';
import '../homedonation/calendar.dart';
import '../mockdata/mockhomerequest.dart';

class BloodDonationHospitalPage extends StatefulWidget {
  const BloodDonationHospitalPage({super.key});

  @override
  State<BloodDonationHospitalPage> createState() =>
      _BloodDonationHospitalPageState();
}

class _BloodDonationHospitalPageState extends State<BloodDonationHospitalPage> {
  String searchQuery = "";

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _filterRequests(
    List<Map<String, dynamic>> requests,
  ) {
    if (searchQuery.isEmpty) return requests;

    return requests.where((request) {
      final hospitalName =
          request["hospital_name"]?.toString().toLowerCase() ?? '';
      final bloodType = request["blood_type"]?.toString().toLowerCase() ?? '';
      final address = request["address"]?.toString().toLowerCase() ?? '';
      final code = request["code"]?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();

      return hospitalName.contains(query) ||
          bloodType.contains(query) ||
          address.contains(query) ||
          code.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUrgent = _filterRequests(urgentHomeAppointments);
    final filteredRegular = _filterRequests(regularHomeAppointments);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hospital Blood Donation"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  // Urgent Section
                  if (filteredUrgent.isNotEmpty) ...[
                    ...filteredUrgent.map(
                      (request) => _buildRequestCard(request, isUrgent: true),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Regular Section
                  if (filteredRegular.isNotEmpty) ...[
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
                      (request) => _buildRequestCard(request, isUrgent: false),
                    ),
                  ],

                  // No results
                  if (filteredUrgent.isEmpty && filteredRegular.isEmpty)
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
                selectedRequest: request,
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
                          request["hospital_name"] ?? "Unknown Hospital",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request["code"] ?? "N/A",
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

              if (request["blood_type"] != null)
                _buildInfoRow(
                  Icons.bloodtype,
                  "Blood Type",
                  request["blood_type"],
                ),

              _buildInfoRow(
                Icons.calendar_today,
                "Date",
                request["appointment_date"],
              ),

              if (request["address"] != null)
                _buildInfoRow(Icons.location_on, "Address", request["address"]),
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
