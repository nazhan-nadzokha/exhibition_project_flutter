import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/admin_nav_button.dart';
import 'application_management.dart';
import 'exhibition_management.dart';
import 'floorplan_management.dart';
import 'user_management.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const int totalExhibitions = 5;
  static const int pendingApplications = 12;
  static const int totalUsers = 48;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== SUMMARY =====
              const Row(
                children: [
                  SummaryCard(title: 'Exhibitions', value: totalExhibitions),
                  SizedBox(width: 8),
                  SummaryCard(title: 'Pending', value: pendingApplications),
                  SizedBox(width: 8),
                  SummaryCard(title: 'Users', value: totalUsers),
                ],
              ),
              const SizedBox(height: 24),
              // ===== ADMIN NAVIGATION =====
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    AdminNavButton(
                      title: 'Manage Exhibitions',
                      icon: Icons.event,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExhibitionManagementPage(),
                        ),
                      ),
                    ),
                    AdminNavButton(
                      title: 'Floor Plans',
                      icon: Icons.map,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FloorPlanManagementPage(),
                        ),
                      ),
                    ),
                    AdminNavButton(
                      title: 'Users',
                      icon: Icons.people,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserManagementPage(),
                        ),
                      ),
                    ),
                    AdminNavButton(
                      title: 'Applications',
                      icon: Icons.assignment,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplicationManagementPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/', // Go to main page (route)
                    (route) => false,
              );
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}

// ===== SUMMARY CARD =====
class SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}