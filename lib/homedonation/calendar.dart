import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'threesteps/threesteps_page.dart';
import '../core/state/app_state.dart';
import '../core/network/api_client.dart';

class TimeSlot {
  final String id;
  final String time;
  final String status; // 'available' or 'booked'
  final String? timeKey; // For backend booking reference

  TimeSlot({
    required this.id,
    required this.time,
    required this.status,
    this.timeKey,
  });
}

class CalendarPage extends StatefulWidget {
  final Map<String, dynamic> selectedRequest;
  final String donationType; // 'home' or 'hospital'

  const CalendarPage({
    super.key,
    required this.selectedRequest,
    required this.donationType,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  String? _selectedTimeSlotId;
  List<TimeSlot> _timeSlots = [];
  bool _loadingSlots = false;
  String? _slotsError;
  Set<String> _availableDates = {}; // Dates that have available slots (YYYY-MM-DD format)
  bool _loadingAvailableDates = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeCalendar(); // Load available dates first, then slots
  }

  Future<void> _initializeCalendar() async {
    // First load all available dates
    await _loadAvailableDates();
    // Then load slots for today
    _fetchTimeSlots();
  }

  Future<void> _fetchTimeSlots() async {
    final hospitalIdRaw = widget.selectedRequest['id'];
    if (hospitalIdRaw == null) {
      debugPrint('❌ Hospital ID is missing in selectedRequest: ${widget.selectedRequest}');
      setState(() {
        _slotsError = 'Hospital ID is missing';
        _loadingSlots = false;
      });
      return;
    }

    // Convert hospital ID to string (handles both int and string)
    final hospitalId = hospitalIdRaw.toString();

    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });

    try {
      final dio = await ApiClient.instance.dio();
      final endpoint = widget.donationType == 'home'
          ? '/api/blood/home_donation/$hospitalId'
          : '/api/blood/hospital_donation/$hospitalId';
      
      final appointmentType = widget.selectedRequest['appointment_type'];
      final url = appointmentType != null
          ? '$endpoint?appointment_type=$appointmentType'
          : endpoint;

      final selectedDateStr = _formatDateForBackend(_selectedDate);
      debugPrint('📅 Fetching time slots');
      debugPrint('   Hospital ID: $hospitalId');
      debugPrint('   Selected Date: $selectedDateStr');
      debugPrint('   Donation Type: ${widget.donationType}');
      debugPrint('   Appointment Type: $appointmentType');
      debugPrint('   URL: $url');

      final res = await dio.get(url);
      debugPrint('✅ Response received: ${res.statusCode}');
      debugPrint('   Response keys: ${res.data.keys}');
      
      final timeSlotsData = (res.data['time_slots'] as List?) ?? [];
      debugPrint('📊 Received ${timeSlotsData.length} total time slots from backend');

      if (timeSlotsData.isEmpty) {
        debugPrint('⚠️ No time slots in response. Full response: ${res.data}');
      }

      // Filter slots for the selected date
      debugPrint('🔍 Filtering for date: $selectedDateStr');
      debugPrint('   Total slots received: ${timeSlotsData.length}');
      
      final filteredSlots = <TimeSlot>[];
      for (var slot in timeSlotsData) {
        final rawSlotDate = slot['date']?.toString() ?? '';
        final slotDate = _normalizeDate(rawSlotDate);
        final slotStatus = slot['status']?.toString() ?? 'available';
        final slotTime = slot['time']?.toString() ?? '';
        
        debugPrint('   Slot: rawDate="$rawSlotDate" -> normalized="$slotDate", time="$slotTime", status="$slotStatus"');
        debugPrint('   Comparing: "$slotDate" == "$selectedDateStr" ? ${slotDate == selectedDateStr}');
        
        if (slotDate == selectedDateStr) {
          debugPrint('   ✅ Match found! Adding slot: $slotTime ($slotStatus)');
          filteredSlots.add(TimeSlot(
            id: slot['id']?.toString() ?? '',
            time: slotTime,
            status: slotStatus,
            timeKey: slot['time_key']?.toString(),
          ));
        } else {
          debugPrint('   ❌ Date mismatch: "$slotDate" != "$selectedDateStr"');
        }
      }

      debugPrint('✅ Filtered to ${filteredSlots.length} slots for selected date');

      setState(() {
        _timeSlots = filteredSlots;
        _selectedTimeSlotId = null; // Reset selection when date changes
      });
    } catch (e) {
      debugPrint('❌ Error fetching time slots: $e');
      if (e.toString().contains('DioException')) {
        try {
          final response = (e as dynamic).response;
          debugPrint('   Response status: ${response?.statusCode}');
          debugPrint('   Response data: ${response?.data}');
          if (response?.statusCode == 404) {
            setState(() {
              _slotsError = 'Hospital not found or no appointments available';
            });
            return;
          }
        } catch (_) {}
      }
      setState(() {
        _slotsError = 'Failed to load time slots. Please try again.';
        _timeSlots = [];
      });
    } finally {
      setState(() {
        _loadingSlots = false;
      });
    }
  }

  String _formatDateForBackend(DateTime date) {
    final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    debugPrint('📅 Formatted date: ${date.day}/${date.month}/${date.year} -> $formatted');
    return formatted;
  }
  
  // Normalize date string to YYYY-MM-DD format (same as website)
  String _normalizeDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    // Remove time portion if present (handle both 'T' and ' ' separators)
    String normalized = dateStr.split('T')[0].split(' ')[0].trim();
    // Ensure it's exactly YYYY-MM-DD format (10 characters)
    if (normalized.length >= 10) {
      normalized = normalized.substring(0, 10);
    }
    return normalized;
  }

  // Load all available dates for this hospital
  Future<void> _loadAvailableDates() async {
    final hospitalIdRaw = widget.selectedRequest['id'];
    if (hospitalIdRaw == null) {
      setState(() {
        _loadingAvailableDates = false;
      });
      return;
    }

    final hospitalId = hospitalIdRaw.toString();

    setState(() {
      _loadingAvailableDates = true;
    });

    try {
      final dio = await ApiClient.instance.dio();
      final endpoint = widget.donationType == 'home'
          ? '/api/blood/home_donation/$hospitalId'
          : '/api/blood/hospital_donation/$hospitalId';
      
      final appointmentType = widget.selectedRequest['appointment_type'];
      final url = appointmentType != null
          ? '$endpoint?appointment_type=$appointmentType'
          : endpoint;

      debugPrint('📅 Loading available dates from: $url');

      final res = await dio.get(url);
      final timeSlotsData = (res.data['time_slots'] as List?) ?? [];

      debugPrint('📊 Received ${timeSlotsData.length} total time slots from backend');

      // Extract all dates that have ANY slots (available or booked)
      // We enable dates that have slots, but only show available ones when selected
      final availableDatesSet = <String>{};
      for (var slot in timeSlotsData) {
        final rawSlotDate = slot['date']?.toString() ?? '';
        final slotDate = _normalizeDate(rawSlotDate);
        
        if (slotDate.isNotEmpty) {
          availableDatesSet.add(slotDate);
          debugPrint('   Added date: $slotDate (from raw: $rawSlotDate)');
        }
      }

      debugPrint('✅ Found ${availableDatesSet.length} dates with slots');
      debugPrint('   Dates with slots: ${availableDatesSet.toList()}');

      setState(() {
        _availableDates = availableDatesSet;
        _loadingAvailableDates = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading available dates: $e');
      setState(() {
        _availableDates = {}; // Empty set means no dates available
        _loadingAvailableDates = false;
      });
    }
  }

  // Check if a date has any slots (available or booked)
  bool _hasAvailableSlots(DateTime date) {
    if (_loadingAvailableDates) {
      // While loading, disable all dates
      return false;
    }
    final dateStr = _formatDateForBackend(date);
    final hasSlots = _availableDates.contains(dateStr);
    if (!hasSlots && _availableDates.isNotEmpty) {
      debugPrint('🔍 Date $dateStr NOT found. Available dates: ${_availableDates.toList()}');
    }
    return hasSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        debugPrint(
          '🔄 Calendar rebuilding. Total appointments: ${appState.donationAppointments.length}',
        );
        if (appState.donationAppointments.isNotEmpty) {
          debugPrint('Appointments:');
          for (var apt in appState.donationAppointments) {
            debugPrint(
              '  - ${apt['appointment_date']} at ${apt['appointment_time']}',
            );
          }
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Select Date & Time"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _loadingAvailableDates
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar
                        _buildCalendar(),
                        const SizedBox(height: 32),
                        // Time Slots
                        _buildTimeSlots(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Map<String, dynamic> get selectedRequest => widget.selectedRequest;

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Text(
          "${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),

        // Week days header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map(
                (day) => SizedBox(
                  width: 45,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),

        // Calendar grid
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    ).weekday;

    final List<Widget> calendarDays = [];

    // Empty cells for days before month starts
    for (int i = 0; i < (firstDayOfMonth == 7 ? 0 : firstDayOfMonth); i++) {
      calendarDays.add(SizedBox(width: 45, height: 45));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isSelected =
          date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;
      final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
      // Only disable past dates, enable all future dates
      final isDisabled = isPast || _loadingAvailableDates;

      calendarDays.add(
        GestureDetector(
          onTap: isDisabled
              ? null
              : () async {
                  debugPrint('📅 Date selected: ${date.day}/${date.month}/${date.year}');
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlotId = null;
                  });
                  await _fetchTimeSlots(); // Fetch slots for the new date
                },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Color(0xFF8B0000), Color(0xFFFF0000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDisabled
                          ? Colors.grey.shade400
                          : isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  // Small dot indicator for dates with available slots
                  if (!isPast && _hasAvailableSlots(date) && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Build grid rows
    final List<Widget> gridRows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.sublist(
        i,
        i + 7 < calendarDays.length ? i + 7 : calendarDays.length,
      );
      gridRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowDays
              .map((day) => day is SizedBox ? day : Center(child: day))
              .toList(),
        ),
      );
      gridRows.add(const SizedBox(height: 16));
    }

    return Column(children: gridRows);
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Time Slots",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        if (_loadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Colors.red),
            ),
          )
        else if (_slotsError != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _slotsError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_timeSlots.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No time slots for ${_formatDateForDisplay(_selectedDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = _selectedTimeSlotId == slot.id;
              final isBooked = slot.status == 'booked';

            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () {
                      setState(() {
                        _selectedTimeSlotId = slot.id;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Color(0xFF8B0000), Color(0xFFFF0000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isBooked
                      ? Colors.grey.shade200
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isBooked
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      isBooked ? 'Booked' : 'Available',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : isBooked
                            ? Colors.grey.shade500
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Confirm button
        if (_selectedTimeSlotId != null && !_loadingSlots)
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFCC0000), Color(0xFF990000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final selectedSlot = _timeSlots.firstWhere(
                    (s) => s.id == _selectedTimeSlotId,
                  );
                  final dateString =
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreeStepsPage(
                        selectedRequest: widget.selectedRequest,
                        selectedDate: dateString,
                        selectedTime: selectedSlot.time,
                        donationType: widget.donationType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                child: const Text(
                  "Confirm Time to Proceed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
