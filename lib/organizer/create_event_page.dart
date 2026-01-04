import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for form fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();

  // Date and Time variables
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  // Booth count dropdown value
  int _selectedBoothCount = 1;
  final List<int> _boothCountOptions = List.generate(
    8,
    (index) => index + 1,
  ); // 1 to 8

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _eventNameController.dispose();
    _priceController.dispose();
    _venueController.dispose();
    _eventDescController.dispose();
    super.dispose();
  }

  // Method to pick date
  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? DateTime.now()
        : (_startDate ?? DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Method to pick time
  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final initialTime = isStart
        ? TimeOfDay.now()
        : (_startTime ?? TimeOfDay.now());
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // Format date for display
  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date';
  }

  // Format time for display
  String _formatTime(TimeOfDay? time) {
    return time != null ? time.format(context) : 'Select Time';
  }

  // Create date-time by combining date and time
  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Method to create event in Firestore
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate date and time
    if (_startDate == null || _startTime == null) {
      _showError('Please select event start date and time');
      return;
    }

    if (_endDate == null || _endTime == null) {
      _showError('Please select event end date and time');
      return;
    }

    // Validate end date/time is after start date/time
    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    if (endDateTime!.isBefore(startDateTime!)) {
      _showError('End date/time must be after start date/time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare event data
      final eventData = {
        'eventName': _eventNameController.text.trim(),
        'venue': _venueController.text.trim(),
        'eventDesc': _eventDescController.text.trim(),
        'eventStartDate': Timestamp.fromDate(startDateTime),
        'eventStartTime': Timestamp.fromDate(startDateTime),
        'eventEndDate': Timestamp.fromDate(endDateTime),
        'eventEndTime': Timestamp.fromDate(endDateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Create event document
      final eventDocRef = await _firestore.collection('events').add(eventData);

      // Create booths collection inside the event
      await _createBooths(eventDocRef.id);

      // Show success message
      _showSuccess('Event created successfully!');

      // Clear form
      _resetForm();

      // Navigate back after a delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true); // Return success flag
    } catch (e) {
      _showError('Failed to create event: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Method to create booths inside the event
  Future<void> _createBooths(String eventId) async {
    try {
      final batch = _firestore.batch();

      // Create specified number of booths
      for (int i = 1; i <= _selectedBoothCount; i++) {
        final boothId = 'booth$i';
        final boothDocRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('booth')
            .doc(boothId);

        final boothData = {
          'boothId': boothId,
          'boothName': 'Booth $i',
          'boothStatus': 'Available',
          'boothPrice': _priceController.text.trim(),
          'boothAvailability': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        batch.set(boothDocRef, boothData);
      }

      await batch.commit();
      log('Created $_selectedBoothCount booths for event: $eventId');
    } catch (e) {
      log('Error creating booths: $e');
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _eventNameController.clear();
    _priceController.clear();
    _venueController.clear();
    _eventDescController.clear();
    setState(() {
      _startDate = null;
      _startTime = null;
      _endDate = null;
      _endTime = null;
      _selectedBoothCount = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Event Details"),
                      const SizedBox(height: 20),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Event Name
                            _buildModernTextField(
                              label: "Event Name *",
                              controller: _eventNameController,
                              icon: Icons.title,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter event name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Venue
                            _buildModernTextField(
                              label: "Venue *",
                              controller: _venueController,
                              icon: Icons.location_on,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter venue';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildModernTextField(
                              label: "Description",
                              controller: _eventDescController,
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Booth Count Dropdown
                            _buildBoothCountDropdown(),

                            const SizedBox(height: 16),

                            // Title
                            _buildModernTextField(
                              label: "Booth Price (RM) *",
                              controller: _priceController,
                              icon: Icons.attach_money,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter booth price';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 20),

                            // Date and Time Section
                            _buildSectionHeader("Event Schedule"),
                            const SizedBox(height: 16),

                            // Start Date & Time
                            _buildDateTimeRow(
                              label: "Start",
                              date: _startDate,
                              time: _startTime,
                              onDatePressed: () => _pickDate(context, true),
                              onTimePressed: () => _pickTime(context, true),
                            ),
                            const SizedBox(height: 16),

                            // End Date & Time
                            _buildDateTimeRow(
                              label: "End",
                              date: _endDate,
                              time: _endTime,
                              onDatePressed: () => _pickDate(context, false),
                              onTimePressed: () => _pickTime(context, false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryButton(
                              "Cancel",
                              () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPrimaryButton(
                              "Create Event",
                              _createEvent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildBoothCountDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Number of Booths *",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButton<int>(
            value: _selectedBoothCount,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: _boothCountOptions.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value booth${value > 1 ? 's' : ''}'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBoothCount = newValue;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Maximum 8 booths available',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onDatePressed,
    required VoidCallback onTimePressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label Date",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildDateTimeButton(
                icon: Icons.calendar_month,
                text: _formatDate(date),
                onPressed: onDatePressed,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$label Time",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildDateTimeButton(
                icon: Icons.access_time,
                text: _formatTime(time),
                onPressed: onTimePressed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black26),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: text == 'Select Date' || text == 'Select Time'
                    ? Colors.grey
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black26),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
