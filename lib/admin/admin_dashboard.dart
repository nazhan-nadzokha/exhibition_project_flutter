import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import ' hall_management/hall_list_page.dart';
import 'application_management.dart';
import 'exhibition_management.dart';
import 'floorplan_management.dart';
import 'user_management.dart';
import 'hall_management/hall_list_page.dart';
import 'booking_management/booking_list_page.dart';
import 'analytics/booking_chart_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administrator Dashboard'),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey, Colors.black87],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSummarySection(),
              const SizedBox(height: 24),
              Expanded(child: _buildAdminMenu(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome, Admin 👋',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Manage halls, users and bookings efficiently',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ===== SUMMARY CARDS =====
  Widget _buildSummarySection() {
    return Row(
      children: const [
        DashboardCountCard(
          title: 'Halls',
          icon: Icons.meeting_room,
          collection: 'halls',
        ),
        SizedBox(width: 12),
        DashboardCountCard(
          title: 'Bookings',
          icon: Icons.book_online,
          collection: 'bookings',
        ),
        SizedBox(width: 12),
        DashboardCountCard(
          title: 'Users',
          icon: Icons.people,
          collection: 'users',
        ),
      ],
    );
  }

  // ===== ADMIN MENU =====
  Widget _buildAdminMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _adminButton(
          context,
          title: 'Manage Exhibitions',
          icon: Icons.event,
          page: ExhibitionManagementPage(),
        ),
        _adminButton(
          context,
          title: 'Floor Plans',
          icon: Icons.map,
          page: FloorPlanManagementPage(),
        ),
        _adminButton(
          context,
          title: 'Users',
          icon: Icons.people_alt,
          page: UserManagementPage(),
        ),
        _adminButton(
          context,
          title: 'Applications',
          icon: Icons.assignment,
          page: ApplicationManagementPage(),
        ),
        _adminButton(
          context,
          title: 'Halls',
          icon: Icons.meeting_room,
          page: HallListPage(),
        ),
        _adminButton(
          context,
          title: 'Bookings',
          icon: Icons.book_online,
          page: BookingListPage(),
        ),
        _adminButton(
          context,
          title: 'Analytics',
          icon: Icons.pie_chart,
          page: BookingAnalyticsPage(),
        ),
      ],
    );
  }

  Widget _adminButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget page,
      }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== LOGOUT =====
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
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

// ===== SUMMARY CARD WIDGET =====
class DashboardCountCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String collection;

  const DashboardCountCard({
    super.key,
    required this.title,
    required this.icon,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          final count =
          snapshot.hasData ? snapshot.data!.docs.length : 0;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(icon, color: Colors.blueGrey),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(title),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
