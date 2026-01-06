import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExhibitionManagementPage extends StatefulWidget {
  const ExhibitionManagementPage({super.key});

  @override
  State<ExhibitionManagementPage> createState() =>
      _ExhibitionManagementPageState();
}

class _ExhibitionManagementPageState extends State<ExhibitionManagementPage> {
  final CollectionReference _exhibitionsCollection =
  FirebaseFirestore.instance.collection('exhibitions');

  // Add or Edit Exhibition
  void _addOrEditExhibitionFirestore(String? docId, Map<String, dynamic>? existingData) {
    final isEdit = docId != null;

    final TextEditingController nameController =
    TextEditingController(text: existingData?['title'] ?? '');
    final TextEditingController dateController =
    TextEditingController(text: existingData?['date'] ?? '');
    final TextEditingController hallController =
    TextEditingController(text: existingData?['hall'] ?? '');
    String status = existingData?['status'] ?? 'Upcoming';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Exhibition' : 'Add Exhibition'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exhibition Name')),
              TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date')),
              TextField(
                  controller: hallController,
                  decoration: const InputDecoration(labelText: 'Hall')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
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
                'title': nameController.text,
                'date': dateController.text,
                'hall': hallController.text,
                'status': status,
                'createdAt': FieldValue.serverTimestamp(),
              };

              if (isEdit) {
                await _exhibitionsCollection.doc(docId).update(data);
              } else {
                final newDoc = _exhibitionsCollection.doc(); // auto-ID
                await newDoc.set(data);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'Exhibition updated' : 'Exhibition added')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  // Delete Exhibition
  void _deleteExhibitionFirestore(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Exhibition'),
        content: const Text('Are you sure you want to delete this exhibition?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await _exhibitionsCollection.doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exhibition deleted')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibition Management'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditExhibitionFirestore(null, null),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _exhibitionsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No exhibitions found.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${doc.id}'),
                      Text('Date: ${data['date'] ?? ''}'),
                      Text('Hall: ${data['hall'] ?? ''}'),
                      Text('Status: ${data['status'] ?? ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        _addOrEditExhibitionFirestore(doc.id, data);
                      } else if (value == 'Delete') {
                        _deleteExhibitionFirestore(doc.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Edit', child: Text('Edit')),
                      PopupMenuItem(value: 'Delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}