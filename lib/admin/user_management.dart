import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  void _addOrEditUser({DocumentSnapshot? userDoc}) {
    final isEdit = userDoc != null;

    final TextEditingController nameController =
    TextEditingController(text: isEdit ? userDoc['name'] : '');
    final TextEditingController emailController =
    TextEditingController(text: isEdit ? userDoc['email'] : '');
    String role = isEdit ? userDoc['role'] : 'Exhibitor';

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
              const SizedBox(height: 8),
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
            onPressed: () async {
              if (isEdit) {
                await usersCollection.doc(userDoc!.id).update({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': role,
                });
              } else {
                await usersCollection.add({
                  'name': nameController.text,
                  'email': emailController.text,
                  'role': role,
                });
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'SAVE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await usersCollection.doc(userId).delete();
              Navigator.pop(context);
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _setRole(String userId, String role) async {
    await usersCollection.doc(userId).update({'role': role});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role updated to $role')),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final user = userDocs[index];
              final userData = user.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userData['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['email'] ?? ''),
                      const SizedBox(height: 4),
                      Text('Role: ${userData['role'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Delete') {
                        _deleteUser(user.id);
                      } else if (value == 'Edit') {
                        _addOrEditUser(userDoc: user);
                      } else {
                        _setRole(user.id, value);
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
          );
        },
      ),
    );
  }
}