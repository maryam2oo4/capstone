import 'package:flutter/material.dart';
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

class TimeSlotsWidget extends StatefulWidget {
  final String hospitalId;
  final String donationType; // 'home' or 'hospital'
  final DateTime selectedDate;
  final String? appointmentType; // 'urgent' or 'regular'
  final Function(TimeSlot) onSlotSelected;
  final String? selectedSlotId;

  const TimeSlotsWidget({
    super.key,
    required this.hospitalId,
    required this.donationType,
    required this.selectedDate,
    required this.onSlotSelected,
    this.appointmentType,
    this.selectedSlotId,
  });

  @override
  State<TimeSlotsWidget> createState() => _TimeSlotsWidgetState();
}

class _TimeSlotsWidgetState extends State<TimeSlotsWidget> {
  List<TimeSlot> _timeSlots = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  @override
  void didUpdateWidget(TimeSlotsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if date or hospital changed
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.hospitalId != widget.hospitalId ||
        oldWidget.appointmentType != widget.appointmentType) {
      _fetchTimeSlots();
    }
  }

  Future<void> _fetchTimeSlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = await ApiClient.instance.dio();
      final endpoint = widget.donationType == 'home'
          ? '/blood/home_donation/${widget.hospitalId}'
          : '/blood/hospital_donation/${widget.hospitalId}';

      final url = widget.appointmentType != null
          ? '$endpoint?appointment_type=${widget.appointmentType}'
          : endpoint;

      final res = await dio.get(url);
      final timeSlotsData = (res.data['time_slots'] as List?) ?? [];

      // Filter slots for the selected date
      final selectedDateStr = _formatDateForBackend(widget.selectedDate);
      final filteredSlots = timeSlotsData
          .where((slot) {
            final slotDate = slot['date']?.toString() ?? '';
            return slotDate == selectedDateStr;
          })
          .map((slot) {
            return TimeSlot(
              id: slot['id']?.toString() ?? '',
              time: slot['time']?.toString() ?? '',
              status: slot['status']?.toString() ?? 'available',
              timeKey: slot['time_key']?.toString(),
            );
          })
          .toList();

      setState(() {
        _timeSlots = filteredSlots;
      });
    } catch (e) {
      debugPrint('Error fetching time slots: $e');
      setState(() {
        _error = 'Failed to load time slots';
        _timeSlots = [];
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDateForBackend(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Colors.red),
            ),
          )
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_timeSlots.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No time slots available for ${_formatDateForDisplay(widget.selectedDate)}',
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
              final isSelected = widget.selectedSlotId == slot.id;
              final isBooked = slot.status == 'booked';

              return GestureDetector(
                onTap: isBooked
                    ? null
                    : () {
                        widget.onSlotSelected(slot);
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
      ],
    );
  }
}
