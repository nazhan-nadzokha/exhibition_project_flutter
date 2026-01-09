import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  String searchText = '';
  String selectedStatus = 'All';
  DateTime? selectedDate;

  final List<String> statusList = [
    'All',
    'Pending',
    'Approved',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildBookingList()),
        ],
      ),
    );
  }

  // 🔍 SEARCH + FILTER UI
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // SEARCH
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search Booking / User ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => searchText = value.toLowerCase());
            },
          ),
          const SizedBox(height: 8),

          // STATUS DROPDOWN
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Booking Status',
              border: OutlineInputBorder(),
            ),
            items: statusList
                .map(
                  (status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() => selectedStatus = value!);
            },
          ),
          const SizedBox(height: 8),

          // DATE PICKER
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedDate == null
                      ? 'Select booking date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                    initialDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              if (selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => selectedDate = null);
                  },
                )
            ],
          ),
        ],
      ),
    );
  }

  // 📋 BOOKING LIST
  Widget _buildBookingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!.docs.where((doc) {
          final id = doc.id.toLowerCase();
          final userId = doc['userId'].toString().toLowerCase();
          final status = doc['status'];
          final Timestamp dateTs = doc['date'];
          final date = dateTs.toDate();

          final matchSearch =
              id.contains(searchText) || userId.contains(searchText);

          final matchStatus =
              selectedStatus == 'All' || status == selectedStatus;

          final matchDate = selectedDate == null
              ? true
              : DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate!);

          return matchSearch && matchStatus && matchDate;
        }).toList();

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final doc = bookings[index];

            return Card(
              child: ListTile(
                title: Text('Booking ID: ${doc.id}'),
                subtitle: Text(
                  'User: ${doc['userId']}\n'
                      'Status: ${doc['status']}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(doc.id)
                        .update({'status': value});
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'Approved',
                      child: Text('Approve'),
                    ),
                    PopupMenuItem(
                      value: 'Cancelled',
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
