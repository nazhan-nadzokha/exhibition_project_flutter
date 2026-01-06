import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FloorPlanManagementPage extends StatefulWidget {
  const FloorPlanManagementPage({super.key});

  @override
  State<FloorPlanManagementPage> createState() =>
      _FloorPlanManagementPageState();
}

class _FloorPlanManagementPageState extends State<FloorPlanManagementPage> {
  final CollectionReference _floorplansCollection =
  FirebaseFirestore.instance.collection('floorplans');

  // Add or Edit Booth
  void _addOrEditBoothFirestore(String? docId, Map<String, dynamic>? existingData) {
    final isEdit = docId != null;

    final TextEditingController boothController =
    TextEditingController(text: existingData?['booth'] ?? '');
    final TextEditingController sizeController =
    TextEditingController(text: existingData?['size'] ?? '');
    String status = existingData?['status'] ?? 'Available';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Booth' : 'Add Booth'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: boothController,
                  decoration: const InputDecoration(labelText: 'Booth ID')),
              TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(labelText: 'Booth Size')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'Available', child: Text('Available')),
                  DropdownMenuItem(value: 'Booked', child: Text('Booked')),
                  DropdownMenuItem(value: 'Reserved', child: Text('Reserved')),
                ],
                onChanged: (val) {
                  if (val != null) status = val;
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'booth': boothController.text,
                'size': sizeController.text,
                'status': status,
                'createdAt': FieldValue.serverTimestamp(),
              };

              if (isEdit) {
                await _floorplansCollection.doc(docId).update(data);
              } else {
                final newDoc = _floorplansCollection.doc();
                await newDoc.set(data);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'Booth updated' : 'Booth added successfully')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  // Delete Booth
  void _deleteBoothFirestore(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Booth'),
        content: const Text('Are you sure you want to delete this booth?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await _floorplansCollection.doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booth deleted successfully')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  // Toggle Booth Status
  void _toggleBoothStatusFirestore(String docId, String currentStatus) async {
    String newStatus;
    if (currentStatus == 'Available') {
      newStatus = 'Booked';
    } else if (currentStatus == 'Booked') {
      newStatus = 'Available';
    } else {
      newStatus = currentStatus; // Reserved remains unchanged
    }

    await _floorplansCollection.doc(docId).update({'status': newStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booth $docId status updated to $newStatus')),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green.shade100;
      case 'Booked':
        return Colors.red.shade100;
      case 'Reserved':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Booked':
        return Colors.red;
      case 'Reserved':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor Plan Management'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditBoothFirestore(null, null),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hall A – Booth Layout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _floorplansCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No booths found.'));

                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () => _toggleBoothStatusFirestore(doc.id, data['status']),
                        child: Card(
                          elevation: 4,
                          color: _statusColor(data['status']),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Booth ${data['booth']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Size: ${data['size']}'),
                                const SizedBox(height: 8),
                                Text(
                                  data['status'],
                                  style: TextStyle(
                                    color: _statusTextColor(data['status']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () =>
                                          _addOrEditBoothFirestore(doc.id, data),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () =>
                                          _deleteBoothFirestore(doc.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}