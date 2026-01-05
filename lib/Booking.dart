import 'package:flutter/material.dart';
import 'UserHome.dart';

import 'Exhibition.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 69,
        backgroundColor: Colors.blueAccent,
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
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Exhibition'),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const Exhibition()));
                },
              ),
            ],
          ),
        ),
      ),

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Exhibition:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ExhibitionDropdown(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// Exhibition Dropdown + Booking Logic
// ======================================================
class ExhibitionDropdown extends StatefulWidget {
  const ExhibitionDropdown({super.key});

  @override
  State<ExhibitionDropdown> createState() => _ExhibitionDropdownState();
}

class _ExhibitionDropdownState extends State<ExhibitionDropdown> {
  Map<String, String>? selectedEvent;
  String? selectedBooth;
  bool showBoothDetails = false;
  bool showPendingMessage = false;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> currentBooths = [];

  // Checkbox states
  bool extraFurniture = false;
  bool promoSpots = false;
  bool extendedWifi = false;

  // Date controllers
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  final Map<String, List<Map<String, String>>> eventBooths = {
    'Malaysia Brand Day 2026': [
      {
        'id': '1',
        'status': 'Booked',
        'size': '3x3',
        'price': 'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '2',
        'status': 'Available',
        'size': '3x3',
        'price': 'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '3',
        'status': 'Booked',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '4',
        'status': 'Available',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '5',
        'status': 'Available',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '6',
        'status': 'Booked',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '7',
        'status': 'Available',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '8',
        'status': 'Booked',
        'size': '4x4',
        'price': 'RM4000',
        'amenities': 'Power, WiFi',
      },
    ],
    'Comic Fiesta 2026': [
      {
        'id': '1',
        'status': 'Booked',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '2',
        'status': 'Available',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '3',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '4',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '5',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '6',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '7',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '8',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
    ],
    'International Automodified 2026': [
      {
        'id': '1',
        'status': 'Booked',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '2',
        'status': 'Available',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '3',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '4',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '5',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '6',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '7',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '8',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
    ],
    'Healthcare Innovation': [
      {
        'id': '1',
        'status': 'Booked',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '2',
        'status': 'Available',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '3',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '4',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '5',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '6',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '7',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '8',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
    ],
    'CyberSecurity Talk': [
      {
        'id': '1',
        'status': 'Booked',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '2',
        'status': 'Booked',
        'size':
            '3x3'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '3',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '4',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '5',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '6',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '7',
        'status': 'Available',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
      {
        'id': '8',
        'status': 'Booked',
        'size':
            '4x4'
            'RM3000',
        'amenities': 'Power, WiFi',
      },
    ],

    // Add other events similarly...
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exhibition Dropdown
        DropdownButton<Map<String, String>>(
          isExpanded: true,
          hint: const Text('Choose an exhibition'),
          value: selectedEvent,
          items: Exhibition.events.map((event) {
            return DropdownMenuItem(value: event, child: Text(event['title']!));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedEvent = value;
              selectedBooth = null;
              showBoothDetails = false;
              showPendingMessage = false;
              currentBooths = eventBooths[value!['title']] ?? [];
            });
          },
        ),

        const SizedBox(height: 20),

        // Event Details
        if (selectedEvent != null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedEvent!['title']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(selectedEvent!['desc']!),
                  const SizedBox(height: 16),

                  // Floor Plan
                  const Text(
                    'Select Booth on Floor Plan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🚪 ENTRY
                      const Column(
                        children: [
                          Icon(Icons.door_front_door, size: 36),
                          Text('Entry', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBooth('1'),
                                _buildBooth('2'),
                                _buildBooth('3'),
                                _buildBooth('4'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBooth('5'),
                                _buildBooth('6'),
                                const Column(
                                  children: [
                                    Icon(Icons.wc, size: 30),
                                    Text(
                                      'Toilet',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                _buildBooth('7'),
                                _buildBooth('8'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Select Button
                  if (selectedBooth != null && !showBoothDetails)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showBoothDetails = true;
                          showPendingMessage = false;
                        });
                      },
                      child: const Text('Select'),
                    ),

                  // Booth Details + Form
                  if (showBoothDetails && selectedBooth != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Booth Details:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Booth ID: $selectedBooth'),
                        Text(
                          'Size: ${currentBooths.firstWhere((b) => b['id'] == selectedBooth)['size']}',
                        ),
                        Text(
                          'Price: ${currentBooths.firstWhere((b) => b['id'] == selectedBooth)['price']}',
                        ),
                        Text(
                          'Amenities: ${currentBooths.firstWhere((b) => b['id'] == selectedBooth)['amenities'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 16),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Company Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Company Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Exhibit Profile',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),

                              const SizedBox(height: 8),
                              // Event Start Date with Calendar
                              TextFormField(
                                controller: startDateController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Event Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                    });
                                  }
                                },
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              // Event End Date with Calendar
                              TextFormField(
                                controller: endDateController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Event End Date',
                                  border: OutlineInputBorder(),
                                ),
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      endDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                    });
                                  }
                                },
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),

                              const SizedBox(height: 12),
                              // Add-Ons Checkboxes
                              CheckboxListTile(
                                title: const Text('Extra Furniture'),
                                value: extraFurniture,
                                onChanged: (val) {
                                  setState(() {
                                    extraFurniture = val ?? false;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Promotional Spots'),
                                value: promoSpots,
                                onChanged: (val) {
                                  setState(() {
                                    promoSpots = val ?? false;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Extended WiFi'),
                                value: extendedWifi,
                                onChanged: (val) {
                                  setState(() {
                                    extendedWifi = val ?? false;
                                  });
                                },
                              ),

                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          'Application Submitted',
                                        ),
                                        content: const Text(
                                          'Your booth application is now Pending Review!',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    setState(() {
                                      showPendingMessage = true;
                                    });
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
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Booth Widget
  Widget _buildBooth(String boothId) {
    final booth = currentBooths.firstWhere(
      (b) => b['id'] == boothId,
      orElse: () => {'status': 'Unavailable'},
    );

    Color color;
    if (booth['status'] == 'Booked') {
      color = Colors.red;
    } else if (selectedBooth == boothId) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: booth['status'] == 'Available'
          ? () {
              setState(() {
                selectedBooth = boothId;
                showBoothDetails = false;
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
          boothId,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
