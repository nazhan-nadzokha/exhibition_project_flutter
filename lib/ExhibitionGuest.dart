import 'package:flutter/material.dart';
import 'Login.dart';
import 'Guest.dart';

class ExhibitionGuest extends StatelessWidget {
  const ExhibitionGuest({super.key});

  // =======================
  // Event Model
  // =======================
  static final List<Map<String, String>> events = [
    {
      'title': 'Malaysia Brand Day 2026',
      'desc':
          'Malaysia First-Ever National Brand Showcase\n8th -10th Jan 2026\n10:00 AM to 6:00 PM\nHall 1 - Hall 4',
      'status': 'Ongoing',
      'image': 'assets/BrandDay.jpg',
    },
    {
      'title': 'Comic Fiesta 2026',
      'desc':
          'Malaysia event related to the Anime, Comics and Games (ACG) culture!\n\n20th - 21st December 2026\n9:30AM to 10PM\nHall 2 - 5',
      'status': 'Upcoming',
      'image': 'assets/Comic.jpg',
    },
    {
      'title': 'International Automodified 2026',
      'desc':
          'The world fastest growing car tuning & lifestyle show series\n\n8th - 9th January 2026\n10AM to 7PM\nHall 5 - 8',
      'status': 'Ongoing',
      'image': 'assets/Cars.jpg',
    },
    {
      'title': 'Healthcare Innovation',
      'desc':
          'Latest medical technologies and innovations transforming modern healthcare.\n\n16th - 18th June 2026\n10AM to 8PM\nHall 3 - 5',
      'status': 'Upcoming',
      'image': 'assets/care.jpg',
    },
    {
      'title': 'Cybersecurity Talk',
      'desc': 'Cyber technology expo...',
      'status': 'Upcoming',
      'image': 'assets/cyber.jpg',
    },
  ];

  // =======================
  // Build Event Cards
  // =======================
  List<Widget> _buildGridCards(BuildContext context) {
    return events.map((event) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 30 / 11, //TODO:sizing of card
                  child: Image.asset(event['image']!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: event['status'] == 'Ongoing'
                          ? Colors.green
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event['status'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                event['title'] ?? 'No title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                event['desc'] ?? 'No description',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Book Now'),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 69,
        backgroundColor: Colors.blueAccent,
        title: const Text('Berjaya Convention'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),

      // Drawer
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
                    MaterialPageRoute(builder: (_) => const GuestPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.book_online_outlined),
                title: const Text('Booking'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exhibition Events',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover and explore upcoming exhibition events.\nBrowse available booths and book your space today.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Stats
            const Row(
              children: [
                _StatCard(
                  title: 'Total',
                  value: '5',
                  titleColor: Colors.purple,
                ),
                _StatCard(
                  title: 'Ongoing',
                  value: '2',
                  titleColor: Colors.green,
                ),
                _StatCard(
                  title: 'Upcoming',
                  value: '3',
                  titleColor: Colors.lightBlue,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.58,
              children: _buildGridCards(context),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// Stat Card Widget
// =======================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color titleColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
