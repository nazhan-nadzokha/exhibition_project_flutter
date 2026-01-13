import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Guest.dart';

class RealTimeProfilePage extends StatefulWidget {
  const RealTimeProfilePage({super.key});

  @override
  State<RealTimeProfilePage> createState() => _RealTimeProfilePageState();
}

class _RealTimeProfilePageState extends State<RealTimeProfilePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEditing = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return _buildNoUserScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () => _toggleEditMode(snapshot.data),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No profile data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Update controllers when not in edit mode
          if (!_isEditing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _firstNameController.text = userData['firstName'] ?? '';
              _lastNameController.text = userData['lastName'] ?? '';
              _dobController.text = userData['dob'] ?? '';
              _phoneController.text = userData['phone'] ?? '';
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _getInitials(userData),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData['role']?.toUpperCase() ?? 'USER',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoTile('Email', userData['email'] ?? 'N/A', false),
                        _buildInfoTile('First Name',
                            _isEditing
                                ? _buildTextField(_firstNameController, 'First Name')
                                : userData['firstName'] ?? 'N/A',
                            _isEditing
                        ),
                        _buildInfoTile('Last Name',
                            _isEditing
                                ? _buildTextField(_lastNameController, 'Last Name')
                                : userData['lastName'] ?? 'N/A',
                            _isEditing
                        ),
                        _buildInfoTile('Date of Birth',
                            _isEditing
                                ? GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _buildTextField(_dobController, 'Date of Birth'),
                              ),
                            )
                                : userData['dob'] ?? 'N/A',
                            _isEditing
                        ),
                        _buildInfoTile('Phone Number',
                            _isEditing
                                ? _buildTextField(_phoneController, 'Phone', isPhone: true)
                                : userData['phone'] ?? 'N/A',
                            _isEditing
                        ),
                      ],
                    ),
                  ),
                ),

                // Save/Cancel buttons when editing
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveChanges(_currentUser!.uid),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _firstNameController.text = userData['firstName'] ?? '';
                        _lastNameController.text = userData['lastName'] ?? '';
                        _dobController.text = userData['dob'] ?? '';
                        _phoneController.text = userData['phone'] ?? '';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
                // Alternative Logout Button at bottom
                const SizedBox(height: 30,),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout,color: Colors.red,),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () =>_showLogoutConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, dynamic content, bool isEditable) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: content is Widget
                  ? content
                  : Text(
                content.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
    );
  }

  void _toggleEditMode(DocumentSnapshot? snapshot) {
    if (_isEditing && snapshot != null) {
      _saveChanges(snapshot.id);
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _saveChanges(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'dob': _dobController.text,
        'phone': _phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _performLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      await _auth.signOut();

      // Navigate to login page and clear navigation stack
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const GuestPage()));


      _showSnackBar('Logged out successfully', isError: false);
    } catch (e) {
      _showSnackBar('Logout failed: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
    }

    return timestamp.toString();
  }

  String _getInitials(Map<String, dynamic> userData) {
    final firstName = userData['firstName']?.toString() ?? '';
    final lastName = userData['lastName']?.toString() ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }

    return 'U';
  }

  Widget _buildNoUserScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Please login to view profile',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}