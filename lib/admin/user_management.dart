import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, String>> users = [
    {'id': 'U001', 'name': 'Admin One', 'email': 'admin@berjaya.com', 'role': 'Admin'},
    {'id': 'U002', 'name': 'Siti Aminah', 'email': 'siti@event.com', 'role': 'Organizer'},
    {'id': 'U003', 'name': 'Ali Hassan', 'email': 'ali@expo.com', 'role': 'Exhibitor'},
  ];

  void _addOrEditUser({int? index}) {
    final isEdit = index != null;
    final TextEditingController nameController =
    TextEditingController(text: isEdit ? users[index]['name'] : '');
    final TextEditingController emailController =
    TextEditingController(text: isEdit ? users[index]['email'] : '');
    String role = isEdit ? users[index]['role']! : 'Exhibitor';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit User' : 'Add User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Organizer', child: Text('Organizer')),
                  DropdownMenuItem(value: 'Exhibitor', child: Text('Exhibitor')),
                ],
                onChanged: (val) {
                  if (val != null) role = val;
                },
                decoration: const InputDecoration(labelText: 'Role'),
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
                  users[index] = {
                    'id': users[index]['id']!,
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': role,
                  };
                } else {
                  final newId = 'U${(users.length + 1).toString().padLeft(3, '0')}';
                  users.add({
                    'id': newId,
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': role,
                  });
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'User updated successfully' : 'User added successfully')),
              );
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${users[index]['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                users.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _setRole(int index, String role) {
    setState(() {
      users[index]['role'] = role;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${users[index]['name']} role set to $role')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditUser(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user['name']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']!),
                  const SizedBox(height: 4),
                  Text('Role: ${user['role']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _addOrEditUser(index: index);
                  } else if (value == 'Delete') {
                    _deleteUser(index);
                  } else {
                    _setRole(index, value);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Admin', child: Text('Set as Admin')),
                  PopupMenuItem(value: 'Organizer', child: Text('Set as Organizer')),
                  PopupMenuItem(value: 'Exhibitor', child: Text('Set as Exhibitor')),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                  PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
