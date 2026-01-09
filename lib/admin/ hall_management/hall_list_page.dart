import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hall_form_page.dart'; // Make sure this exists

class HallListPage extends StatelessWidget {
  const HallListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Halls')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HallFormPage()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('halls').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['name']),
                  subtitle: Text('Capacity: ${doc['capacity']} | RM ${doc['pricePerHour']}/hr'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('halls').doc(doc.id).delete();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HallFormPage(docId: doc.id, data: doc),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
