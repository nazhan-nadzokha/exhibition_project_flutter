import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BookingAnalyticsPage extends StatelessWidget {
  const BookingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Analytics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          int pending = 0, approved = 0, cancelled = 0;

          for (var doc in snapshot.data!.docs) {
            switch (doc['status']) {
              case 'Pending':
                pending++;
                break;
              case 'Approved':
                approved++;
                break;
              case 'Cancelled':
                cancelled++;
                break;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Booking Status Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: pending.toDouble(),
                          title: 'Pending',
                        ),
                        PieChartSectionData(
                          value: approved.toDouble(),
                          title: 'Approved',
                        ),
                        PieChartSectionData(
                          value: cancelled.toDouble(),
                          title: 'Cancelled',
                        ),
                      ],
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
}
