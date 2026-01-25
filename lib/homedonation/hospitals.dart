import 'package:flutter/material.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final String? bloodTypeNeeded;
  final int availableSlots;
  final int? urgentSlots;
  final int? regularSlots;
  final bool? hasUrgent;
  final bool? hasRegular;
  final String? urgentDueDate;
  final String? urgentDueTime;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    this.bloodTypeNeeded,
    this.availableSlots = 0,
    this.urgentSlots,
    this.regularSlots,
    this.hasUrgent,
    this.hasRegular,
    this.urgentDueDate,
    this.urgentDueTime,
  });
}

class Hospitals extends StatelessWidget {
  final Function(Map<String, dynamic>) onSelect;
  final List<Hospital> showHospitals;
  final String searchQuery;
  final List<Hospital> urgentHospitals;
  final List<Hospital> regularHospitals;

  const Hospitals({
    super.key,
    required this.onSelect,
    required this.showHospitals,
    required this.searchQuery,
    this.urgentHospitals = const [],
    this.regularHospitals = const [],
  });

  bool get isSearching => searchQuery.trim().isNotEmpty;

  bool get hasResults {
    if (isSearching) {
      return showHospitals.isNotEmpty;
    } else {
      return urgentHospitals.isNotEmpty ||
          regularHospitals.isNotEmpty ||
          showHospitals.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case 1: Searching but no results
            if (isSearching && !hasResults)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No hospitals found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ),

            // Case 2: Searching with results
            if (isSearching && hasResults)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Results:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...showHospitals.map((h) {
                    final isUrgent =
                        h.hasUrgent == true ||
                        urgentHospitals.any((uh) => uh.id == h.id);
                    final appointmentType = isUrgent ? 'urgent' : 'regular';

                    return GestureDetector(
                      onTap: () {
                        onSelect({
                          'id': h.id,
                          'name': h.name,
                          'address': h.address,
                          'blood_type_needed': h.bloodTypeNeeded,
                          'appointment_type': appointmentType,
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    h.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),

            // Case 3: Not searching → show default content
            if (!isSearching)
              if (hasResults)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Urgent Hospitals Section
                    if (urgentHospitals.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...urgentHospitals.map((h) {
                            return GestureDetector(
                              onTap: () {
                                onSelect({
                                  'id': h.id,
                                  'name': h.name,
                                  'address': h.address,
                                  'blood_type_needed': h.bloodTypeNeeded,
                                  'appointment_type': 'urgent',
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_hospital,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            h.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Urgent: Due Today',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            h.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '2.3km',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(
                                          Icons.bloodtype,
                                          size: 14,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          h.bloodTypeNeeded ?? 'All Types',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${h.urgentSlots ?? h.availableSlots}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Available Slots',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                    // Regular Hospitals Section
                    SizedBox(height: 16),
                    Text(
                      'Registered Hospitals:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...(regularHospitals.isNotEmpty
                            ? regularHospitals
                            : showHospitals
                                  .where(
                                    (h) => !urgentHospitals.any(
                                      (uh) => uh.id == h.id,
                                    ),
                                  )
                                  .toList())
                        .map((h) {
                          return GestureDetector(
                            onTap: () {
                              onSelect({
                                'id': h.id,
                                'name': h.name,
                                'address': h.address,
                                'blood_type_needed': h.bloodTypeNeeded,
                                'appointment_type': 'regular',
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_hospital,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          h.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          h.address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '2.3km',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.bloodtype,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'All Types',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${h.regularSlots ?? h.availableSlots}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Available Slots',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        ,
                  ],
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFF01010),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Hospitals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
