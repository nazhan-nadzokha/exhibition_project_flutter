import 'package:flutter/material.dart';
import 'UserHome.dart';
import 'services/firestore_service.dart';
import 'Exhibition.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 69,
        backgroundColor: Colors.blueGrey,
        title: const Text('Berjaya Convention'),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey.shade200,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blueGrey.shade500),
                  child: const Text(
                    'Explore More Our Service',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ExhibitionDropdown(),
          ],
        ),
      ),
    );
  }
}

// ===== Firestore-safe ExhibitionDropdown =====
class ExhibitionDropdown extends StatefulWidget {
  const ExhibitionDropdown({super.key});

  @override
  State<ExhibitionDropdown> createState() => _ExhibitionDropdownState();
}

class _ExhibitionDropdownState extends State<ExhibitionDropdown> {
  String? selectedEventId;          // Firestore document ID
  Map<String, dynamic>? selectedEventData;  // event fields
  Map<String, dynamic>? selectedBooth;
  bool showBoothDetails = false;
  bool showPendingMessage = false;

  final _formKey = GlobalKey<FormState>();
  final companyNameCtrl = TextEditingController();
  final companyEmailCtrl = TextEditingController();
  final companyDescCtrl = TextEditingController();
  final exhibitProfileCtrl = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  bool extraFurniture = false;
  bool promoSpots = false;
  bool extendedWifi = false;

  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Exhibition:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // ===== Event Dropdown =====
        StreamBuilder(
          stream: _fs.getEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final events = snapshot.data!.docs;
            if (events.isEmpty) return const Text('No events found');

            return DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Choose an exhibition'),
              value: selectedEventId,
              items: events.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem<String>(
                  value: doc.id, // 🔥 UNIQUE ID
                  child: Text(data['eventName'] ?? 'No title'),
                );
              }).toList(),
              onChanged: (value) {
                final selectedDoc =
                events.firstWhere((doc) => doc.id == value);

                setState(() {
                  selectedEventId = value;
                  selectedEventData =
                  selectedDoc.data() as Map<String, dynamic>;
                  selectedBooth = null;
                  showBoothDetails = false;
                  showPendingMessage = false;
                });
              },
            );
          },
        ),


        const SizedBox(height: 20),

        // ===== Booth Grid =====
        if (selectedEventId != null)
          StreamBuilder(
            stream: _fs.getBooths(selectedEventId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final booths = snapshot.data!.docs;
              if (booths.isEmpty) return const Text('No booths found');

              final boothWidgets = booths.map<Widget>((doc) {
                final booth = doc.data() as Map<String, dynamic>;

                final status =
                (booth['boothStatus'] ?? '').toString().toLowerCase().trim();

                Color color;
                if (status == 'booked') {
                  color = Colors.red;
                } else if (selectedBooth != null &&
                    selectedBooth!['boothId'] == booth['boothId']) {
                  color = Colors.blue;
                } else {
                  color = Colors.green;
                }

                return InkWell(
                  onTap: status == 'available'
                      ? () {
                    setState(() {
                      selectedBooth = booth;
                      showBoothDetails = true;
                      showPendingMessage = false;
                    });
                  }
                      : null,
                  child: Container(
                    width: 60,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booth['boothId'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList();

              return Column(
                children: [
                  // ===== TOP ROW =====
                  Row(
                    children: [
                      // Entry 1
                      Column(
                        children: const [
                          Icon(Icons.door_front_door, size: 36),
                          Text("Entry 1", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Booths 1–4
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: boothWidgets.take(4).toList(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Entry 2
                      Column(
                        children: const [
                          Icon(Icons.door_front_door, size: 36),
                          Text("Entry 2", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ===== BOTTOM ROW =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      boothWidgets[4],
                      const SizedBox(width: 12),
                      boothWidgets[5],
                      const SizedBox(width: 20),

                      Column(
                        children: const [
                          Icon(Icons.wc, size: 36),
                          Text("Toilet", style: TextStyle(fontSize: 12)),
                        ],
                      ),

                      const SizedBox(width: 20),
                      boothWidgets[6],
                      const SizedBox(width: 12),
                      boothWidgets[7],
                    ],
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 20),

        // ===== Booth Details Form =====
        if (showBoothDetails && selectedBooth != null)
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: companyNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: companyEmailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: companyDescCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: exhibitProfileCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Exhibit Profile',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Event Start Date',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      startDateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Event End Date',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      endDateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                    }
                  },
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                CheckboxListTile(
                  title: const Text('Extra Furniture'),
                  value: extraFurniture,
                  onChanged: (val) => setState(() => extraFurniture = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Promotional Spots'),
                  value: promoSpots,
                  onChanged: (val) => setState(() => promoSpots = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Extended WiFi'),
                  value: extendedWifi,
                  onChanged: (val) => setState(() => extendedWifi = val ?? false),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedEventId != null &&
                        selectedBooth != null) {
                      await _fs.submitBoothApplication(
                        eventId: selectedEventId!,
                        eventTitle: selectedEventData!['title'] ?? '',
                        boothId: selectedBooth!['boothId'] ?? '',
                        companyName: companyNameCtrl.text,
                        companyEmail: companyEmailCtrl.text,
                        companyDesc: companyDescCtrl.text,
                        exhibitProfile: exhibitProfileCtrl.text,
                        startDate: startDateController.text,
                        endDate: endDateController.text,
                        extraFurniture: extraFurniture,
                        promoSpots: promoSpots,
                        extendedWifi: extendedWifi,
                      );

                      setState(() => showPendingMessage = true);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Application Submitted'),
                          content: const Text('Your booth application is now Pending Review!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Application'),
                ),

                if (showPendingMessage)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Your application is pending review',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
