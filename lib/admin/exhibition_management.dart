import 'package:flutter/material.dart';

class ExhibitionManagementPage extends StatefulWidget {
  const ExhibitionManagementPage({super.key});

  @override
  State<ExhibitionManagementPage> createState() =>
      _ExhibitionManagementPageState();
}

class _ExhibitionManagementPageState extends State<ExhibitionManagementPage> {
  List<Map<String, String>> exhibitions = [
    {
      'id': 'EXH001',
      'name': 'Malaysia Tech Expo 2025',
      'date': '12–15 June 2025',
      'hall': 'Hall A',
      'status': 'Active',
    },
    {
      'id': 'EXH002',
      'name': 'Food & Beverage Fair',
      'date': '20–23 July 2025',
      'hall': 'Hall B',
      'status': 'Upcoming',
    },
    {
      'id': 'EXH003',
      'name': 'Education & Career Expo',
      'date': '5–7 August 2025',
      'hall': 'Hall C',
      'status': 'Active',
    },
  ];

  void _addOrEditExhibition({int? index}) {
    final isEdit = index != null;
    final TextEditingController nameController =
    TextEditingController(text: isEdit ? exhibitions[index]['name'] : '');
    final TextEditingController dateController =
    TextEditingController(text: isEdit ? exhibitions[index]['date'] : '');
    final TextEditingController hallController =
    TextEditingController(text: isEdit ? exhibitions[index]['hall'] : '');
    String status = isEdit ? exhibitions[index]['status']! : 'Upcoming';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Exhibition' : 'Add Exhibition'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exhibition Name'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: hallController,
                decoration: const InputDecoration(labelText: 'Hall'),
              ),
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
            onPressed: () {
              setState(() {
                if (isEdit) {
                  exhibitions[index] = {
                    'id': exhibitions[index]['id']!,
                    'name': nameController.text,
                    'date': dateController.text,
                    'hall': hallController.text,
                    'status': status,
                  };
                } else {
                  final newId = 'EXH${(exhibitions.length + 1).toString().padLeft(3, '0')}';
                  exhibitions.add({
                    'id': newId,
                    'name': nameController.text,
                    'date': dateController.text,
                    'hall': hallController.text,
                    'status': status,
                  });
                }
              });
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

  void _deleteExhibition(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Exhibition'),
        content: Text('Are you sure you want to delete ${exhibitions[index]['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                exhibitions.removeAt(index);
              });
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
            onPressed: () => _addOrEditExhibition(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: exhibitions.length,
        itemBuilder: (context, index) {
          final exhibition = exhibitions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(exhibition['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${exhibition['id']}'),
                  Text('Date: ${exhibition['date']}'),
                  Text('Hall: ${exhibition['hall']}'),
                  Text('Status: ${exhibition['status']}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _addOrEditExhibition(index: index);
                  } else if (value == 'Delete') {
                    _deleteExhibition(index);
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
      ),
    );
  }
}

