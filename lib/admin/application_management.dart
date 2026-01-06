import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplicationManagementPage extends StatefulWidget {
  const ApplicationManagementPage({super.key});

  @override
  State<ApplicationManagementPage> createState() =>
      _ApplicationManagementPageState();
}

class _ApplicationManagementPageState
    extends State<ApplicationManagementPage> {
  final CollectionReference _applicationsCollection =
  FirebaseFirestore.instance.collection('applications');

  String _filterStatus = 'All';
  String _searchQuery = '';

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  // Add or Edit Application
  void _addOrEditApplicationFirestore(String? docId, Map<String, dynamic>? existingData) {
    final isEdit = docId != null;

    final TextEditingController companyController =
    TextEditingController(text: existingData?['companyName'] ?? '');
    final TextEditingController boothController =
    TextEditingController(text: existingData?['booth'] ?? '');
    String status = existingData?['status'] ?? 'Pending';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Application' : 'Add Application'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: companyController,
                  decoration:
                  const InputDecoration(labelText: 'Company Name')),
              TextField(
                  controller: boothController,
                  decoration: const InputDecoration(labelText: 'Booth')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'companyName': companyController.text,
                'booth': boothController.text,
                'status': status,
                'reason': '',
                'createdAt': FieldValue.serverTimestamp(),
              };

              if (isEdit) {
                await _applicationsCollection.doc(docId).update(data);
              } else {
                final newDoc = _applicationsCollection.doc(); // auto-ID
                await newDoc.set(data);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        isEdit ? 'Application updated' : 'Application added')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  // Update Status / Reason
  void _showReasonDialogFirestore(String docId, String action) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Application'),
        content: TextField(
          controller: reasonController,
          decoration:
          const InputDecoration(hintText: 'Enter reason (optional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await _applicationsCollection.doc(docId).update({
                'status': action,
                'reason': reasonController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Application $docId is now $action.')),
              );
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  // Delete Application
  void _deleteApplicationFirestore(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete $docId?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await _applicationsCollection.doc(docId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application deleted')),
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
        title: const Text('Application Management'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addOrEditApplicationFirestore(null, null)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SEARCH + FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by Company or ID',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                    DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _filterStatus = val;
                      });
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            // APPLICATION LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _applicationsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesStatus =
                        _filterStatus == 'All' || data['status'] == _filterStatus;
                    final matchesSearch = data['companyName']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                        doc.id.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesStatus && matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No applications found.'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Application ID: ${doc.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Company: ${data['companyName']}'),
                              Text('Booth: ${data['booth']}'),
                              if ((data['reason'] ?? '').toString().isNotEmpty)
                                Text('Reason: ${data['reason']}',
                                    style:
                                    const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Status: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(data['status'],
                                      style: TextStyle(
                                          color: _statusColor(data['status']),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (data['status'] == 'Pending') ...[
                                    TextButton(
                                      onPressed: () => _showReasonDialogFirestore(
                                          doc.id, 'Rejected'),
                                      child: const Text('REJECT',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _showReasonDialogFirestore(
                                          doc.id, 'Approved'),
                                      child: const Text('APPROVE'),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _addOrEditApplicationFirestore(
                                          doc.id, data),
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueGrey),
                                    ),
                                  ] else if (data['status'] == 'Approved') ...[
                                    ElevatedButton(
                                      onPressed: () => _showReasonDialogFirestore(
                                          doc.id, 'Cancelled'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      child: const Text('CANCEL'),
                                    ),
                                  ] else if (data['status'] == 'Rejected') ...[
                                    IconButton(
                                      onPressed: () => _addOrEditApplicationFirestore(
                                          doc.id, data),
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blueGrey),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteApplicationFirestore(doc.id),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
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