import 'package:flutter/material.dart';

class ApplicationManagementPage extends StatefulWidget {
  const ApplicationManagementPage({super.key});

  @override
  State<ApplicationManagementPage> createState() =>
      _ApplicationManagementPageState();
}

class _ApplicationManagementPageState
    extends State<ApplicationManagementPage> {
  List<Map<String, String>> applications = [
    {'id': 'APP001', 'company': 'ABC Tech Sdn Bhd', 'booth': 'A01', 'status': 'Pending', 'reason': ''},
    {'id': 'APP002', 'company': 'Foodies MY', 'booth': 'B03', 'status': 'Approved', 'reason': ''},
    {'id': 'APP003', 'company': 'Green Energy Co', 'booth': 'C02', 'status': 'Rejected', 'reason': 'Incomplete form'},
  ];

  String _filterStatus = 'All';
  String _searchQuery = '';

  List<Map<String, String>> get _filteredApplications {
    return applications.where((app) {
      final matchesStatus = _filterStatus == 'All' || app['status'] == _filterStatus;
      final matchesSearch = app['company']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app['id']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _addOrEditApplication({int? index}) {
    final isEdit = index != null;
    final TextEditingController companyController =
    TextEditingController(text: isEdit ? applications[index]['company'] : '');
    final TextEditingController boothController =
    TextEditingController(text: isEdit ? applications[index]['booth'] : '');
    String status = isEdit ? applications[index]['status']! : 'Pending';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Application' : 'Add Application'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company Name')),
              TextField(controller: boothController, decoration: const InputDecoration(labelText: 'Booth')),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isEdit) {
                  applications[index] = {
                    'id': applications[index]['id']!,
                    'company': companyController.text,
                    'booth': boothController.text,
                    'status': status,
                    'reason': '',
                  };
                } else {
                  final newId = 'APP${(applications.length + 1).toString().padLeft(3, '0')}';
                  applications.add({
                    'id': newId,
                    'company': companyController.text,
                    'booth': boothController.text,
                    'status': status,
                    'reason': '',
                  });
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'Application updated' : 'Application added')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _updateApplication(int index, String newStatus, [String reason = '']) {
    setState(() {
      applications[index]['status'] = newStatus;
      applications[index]['reason'] = reason;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application ${applications[index]['id']} is now $newStatus.')),
    );
  }

  Future<void> _showReasonDialog(int index, String action) async {
    final TextEditingController reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Application'),
        content: TextField(controller: reasonController, decoration: const InputDecoration(hintText: 'Enter reason (optional)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateApplication(index, action, reasonController.text);
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _deleteApplication(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete ${applications[index]['id']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                applications.removeAt(index);
              });
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
          IconButton(icon: const Icon(Icons.add), onPressed: () => _addOrEditApplication()),
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
            Expanded(
              child: ListView.builder(
                itemCount: _filteredApplications.length,
                itemBuilder: (context, index) {
                  final app = _filteredApplications[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Application ID: ${app['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Company: ${app['company']}'),
                          Text('Booth: ${app['booth']}'),
                          if (app['reason']!.isNotEmpty)
                            Text('Reason: ${app['reason']}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(app['status']!, style: TextStyle(color: _statusColor(app['status']!), fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (app['status'] == 'Pending') ...[
                                TextButton(onPressed: () => _showReasonDialog(index, 'Rejected'), child: const Text('REJECT', style: TextStyle(color: Colors.red))),
                                const SizedBox(width: 8),
                                ElevatedButton(onPressed: () => _showReasonDialog(index, 'Approved'), child: const Text('APPROVE')),
                                const SizedBox(width: 8),
                                IconButton(onPressed: () => _addOrEditApplication(index: index), icon: const Icon(Icons.edit, color: Colors.blueGrey)),
                              ] else if (app['status'] == 'Approved') ...[
                                ElevatedButton(
                                  onPressed: () => _showReasonDialog(index, 'Cancelled'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                  child: const Text('CANCEL'),
                                ),
                              ] else if (app['status'] == 'Rejected') ...[
                                IconButton(onPressed: () => _addOrEditApplication(index: index), icon: const Icon(Icons.edit, color: Colors.blueGrey)),
                              ],
                              const SizedBox(width: 8),
                              IconButton(onPressed: () => _deleteApplication(index), icon: const Icon(Icons.delete, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
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
