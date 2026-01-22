import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'threesteps/threesteps_page.dart';
import '../core/state/app_state.dart';

class TimeSlot {
  final String id;
  final String time;
  final String status; // 'available' or 'booked'

  TimeSlot({required this.id, required this.time, required this.status});
}

// Mock time slots data - all start as available
final List<TimeSlot> mockTimeSlots = [
  TimeSlot(id: '1', time: '08:00 - 09:00', status: 'available'),
  TimeSlot(id: '2', time: '09:00 - 10:00', status: 'available'),
  TimeSlot(id: '3', time: '10:00 - 11:00', status: 'available'),
  TimeSlot(id: '4', time: '11:00 - 12:00', status: 'available'),
  TimeSlot(id: '5', time: '14:00 - 15:00', status: 'available'),
  TimeSlot(id: '6', time: '15:00 - 16:00', status: 'available'),
];

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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 1, 21); // Set to Jan 21, 2026 like mockup
  }

  // Check if a specific date+time combination is booked
  bool _isTimeSlotBooked(DateTime date, String time) {
    final appState = Provider.of<AppState>(context, listen: false);
    final dateString =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final isBooked = appState.donationAppointments.any((appointment) {
      final matches =
          appointment['appointment_date'] == dateString &&
          appointment['appointment_time'] == time &&
          appointment['donation_type'] == widget.donationType;
      if (matches) {
        debugPrint('✓ Found booked slot: $dateString at $time');
      }
      return matches;
    });

    return isBooked;
  }

  // Check if a date has any available time slots
  bool _hasAvailableSlots(DateTime date) {
    for (var slot in mockTimeSlots) {
      if (!_isTimeSlotBooked(date, slot.time)) {
        return true; // At least one slot is available
      }
    }
    return false; // All slots are booked
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
          body: SingleChildScrollView(
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
      final isFullyBooked = !_hasAvailableSlots(date);
      final isDisabled = isPast || isFullyBooked;

      calendarDays.add(
        GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlotId = null;
                  });
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
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : isSelected
                      ? Colors.white
                      : Colors.black87,
                  decoration: isFullyBooked && !isPast
                      ? TextDecoration.lineThrough
                      : null,
                ),
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

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Time Slots",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockTimeSlots.length,
          itemBuilder: (context, index) {
            final slot = mockTimeSlots[index];
            final isSelected = _selectedTimeSlotId == slot.id;
            // Check if this slot is booked for the selected date
            final isBooked = _isTimeSlotBooked(_selectedDate, slot.time);

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
        if (_selectedTimeSlotId != null)
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
                  final selectedSlot = mockTimeSlots.firstWhere(
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
