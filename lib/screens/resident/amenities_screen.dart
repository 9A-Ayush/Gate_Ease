import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/amenity.dart';
import '../../services/auth_provider.dart';
import 'package:provider/provider.dart';

class AmenitiesScreen extends StatefulWidget {
  const AmenitiesScreen({super.key});

  @override
  State<AmenitiesScreen> createState() => _AmenitiesScreenState();
}

class _AmenitiesScreenState extends State<AmenitiesScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedAmenity = 'Swimming Pool';

  final List<String> _amenities = [
    'Swimming Pool',
    'Gym',
    'Club House',
    'Tennis Court',
    'Basketball Court',
    'Children\'s Play Area',
    'Party Hall',
    'Conference Room',
  ];

  final List<String> _timeSlots = [
    '06:00 - 08:00',
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
    '20:00 - 22:00',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Amenity Booking'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amenity Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Amenity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _amenities.length,
                    itemBuilder: (context, index) {
                      final amenity = _amenities[index];
                      final isSelected = _selectedAmenity == amenity;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAmenity = amenity),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            amenity,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Calendar
          Container(
            color: Colors.white,
            child: TableCalendar<Amenity>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),

          // Time Slots
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Slots for ${_formatDate(_selectedDay)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('amenities')
                              .where('name', isEqualTo: _selectedAmenity)
                              .where(
                                'date',
                                isEqualTo: _formatDateForQuery(_selectedDay),
                              )
                              .snapshots(),
                      builder: (context, snapshot) {
                        final bookedSlots = <String>{};
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final amenity = Amenity.fromMap(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                            bookedSlots.add(amenity.slotTime);
                          }
                        }

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.5,
                              ),
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = _timeSlots[index];
                            final isBooked = bookedSlots.contains(slot);
                            return _buildTimeSlotCard(slot, isBooked, user);
                          },
                        );
                      },
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

  Widget _buildTimeSlotCard(String slot, bool isBooked, user) {
    return GestureDetector(
      onTap: isBooked ? null : () => _bookSlot(slot, user),
      child: Container(
        decoration: BoxDecoration(
          color: isBooked ? Colors.grey.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isBooked ? Colors.grey.shade400 : const Color(0xFF4CAF50),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isBooked ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBooked ? 'BOOKED' : 'AVAILABLE',
              style: TextStyle(
                fontSize: 12,
                color: isBooked ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateForQuery(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _bookSlot(String slot, user) async {
    try {
      await FirebaseFirestore.instance.collection('amenities').add({
        'name': _selectedAmenity,
        'slot_time': slot,
        'booked_by': user?.uid,
        'flat_no': user?.flatNo,
        'date': _formatDateForQuery(_selectedDay),
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedAmenity booked for $slot'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking amenity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
