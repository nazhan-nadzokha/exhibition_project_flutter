import 'package:flutter/material.dart';

class FloorPlanManagementPage extends StatefulWidget {
  const FloorPlanManagementPage({super.key});

  @override
  State<FloorPlanManagementPage> createState() =>
      _FloorPlanManagementPageState();
}

class _FloorPlanManagementPageState extends State<FloorPlanManagementPage> {
  List<Map<String, String>> booths = [
    {'booth': 'A01', 'size': '3x3', 'status': 'Available'},
    {'booth': 'A02', 'size': '6x6', 'status': 'Booked'},
    {'booth': 'A03', 'size': '3x3', 'status': 'Available'},
    {'booth': 'A04', 'size': '6x6', 'status': 'Booked'},
  ];

  void _addOrEditBooth({int? index}) {
    final isEdit = index != null;
    final TextEditingController boothController = TextEditingController(
        text: isEdit ? booths[index]['booth'] : '');
    final TextEditingController sizeController = TextEditingController(
        text: isEdit ? booths[index]['size'] : '');
    String status = isEdit ? booths[index]['status']! : 'Available';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Booth' : 'Add Booth'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: boothController,
                decoration: const InputDecoration(labelText: 'Booth ID'),
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Booth Size'),
              ),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isEdit) {
                  booths[index] = {
                    'booth': boothController.text,
                    'size': sizeController.text,
                    'status': status,
                  };
                } else {
                  booths.add({
                    'booth': boothController.text,
                    'size': sizeController.text,
                    'status': status,
                  });
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        isEdit ? 'Booth updated' : 'Booth added successfully')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _deleteBooth(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Booth'),
        content:
        Text('Are you sure you want to delete booth ${booths[index]['booth']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                booths.removeAt(index);
              });
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

  void _toggleBoothStatus(int index) {
    setState(() {
      final current = booths[index]['status'];
      if (current == 'Available') {
        booths[index]['status'] = 'Booked';
      } else if (current == 'Booked') {
        booths[index]['status'] = 'Available';
      }
      // Reserved remains unchanged for manual override
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booth ${booths[index]['booth']} status updated')),
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
            onPressed: () => _addOrEditBooth(),
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
              child: GridView.builder(
                itemCount: booths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final booth = booths[index];
                  return GestureDetector(
                    onTap: () => _toggleBoothStatus(index),
                    child: Card(
                      elevation: 4,
                      color: _statusColor(booth['status']!),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Booth ${booth['booth']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Size: ${booth['size']}'),
                            const SizedBox(height: 8),
                            Text(
                              booth['status']!,
                              style: TextStyle(
                                color: _statusTextColor(booth['status']!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _addOrEditBooth(index: index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _deleteBooth(index),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}

