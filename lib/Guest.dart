import 'Login.dart';
import 'package:flutter/material.dart';
import 'ExhibitionGuest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../organizer/model/event_model.dart'; // Import your Event model

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 69,
          backgroundColor: Colors.blueGrey,
          title: const Text('Berjaya Convention'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
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
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade500,
                    ),
                    child: const Text(
                      'Explore More Our Service',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Exhibition'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExhibitionGuest(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login/Register'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Welcome Header
              Container(
                width: double.infinity,
                height: 130,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2563eb),
                      Color(0xFF1e40af),
                    ],
                  ),
                ),
                child: const Text(
                  'Welcome to \nBerjaya International Convention Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // "Current Event" Title
              const CurrentEventsTitle(),

              // Current Events from Organizer's Database
              const CurrentEventsSection(),

              const SizedBox(height: 40),

              // "Upcoming Event" Title
              const UpcomingEventsTitle(),

              // Upcoming Events from Organizer's Database
              const UpcomingEventsSection(),

              const SizedBox(height: 40),

              // Booth Layout Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: Colors.blueGrey,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Booth Layout',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const LayoutCard(),
              const SizedBox(height: 20),
              const BookButton(),
              const NoticeText(),
              const SizedBox(height: 40),

              // Contact us title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.contact_mail,
                      color: Colors.blueGrey,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const ContactCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== CURRENT EVENTS SECTION ==============

class CurrentEventsTitle extends StatelessWidget {
  const CurrentEventsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(
            Icons.event,
            color: Colors.blueGrey,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Current Events',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExhibitionGuest(),
                ),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentEventsSection extends StatelessWidget {
  const CurrentEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events') // Organizer's events collection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const  Center(child: CircularProgressIndicator()
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading events')
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events available')
          );
        }

        // We'll fetch booth data and process events in a separate async call
        return FutureBuilder<List<Event>>(
          future: _processEvents(snapshot.data!.docs),
          builder: (context, eventsSnapshot) {
            if (eventsSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!eventsSnapshot.hasData || eventsSnapshot.data!.isEmpty) {
              return Container(
                height: 220,
                child: const Center(child: Text('No current events')),
              );
            }

            // Filter to only current events
            final currentEvents = eventsSnapshot.data!
                .where((event) => event.isOngoing)
                .take(2)
                .toList();

            if (currentEvents.isEmpty) {
              return Container(
                height: 220,
                child: const Center(child: Text('No current events')),
              );
            }

            return Column(
              children: [
                for (var event in currentEvents)
                  CurrentEventCard(event: event),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Event>> _processEvents(List<QueryDocumentSnapshot> docs) async {
    final List<Event> events = [];

    for (var doc in docs) {
      try {
        // Get booths for this event
        final booths = await _getBoothsForEvent(doc.id);

        // Create Event object using your model
        final event = Event.fromFirestore(doc, booths);
        events.add(event);
      } catch (e) {
        print('Error processing event ${doc.id}: $e');
      }
    }

    return events;
  }

  Future<List<Booth>> _getBoothsForEvent(String eventId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('booths')
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs
          .map((doc) => Booth.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching booths: $e');
      return [];
    }
  }
}

class CurrentEventCard extends StatelessWidget {
  final Event event;

  const CurrentEventCard({super.key, required this.event});

  // TODO:add image method
  ImageProvider _getEventImage(String eventName) {
    // You can customize this based on event types
    if (eventName.toLowerCase().contains('tech') ||
        eventName.toLowerCase().contains('digital')) {
      return const AssetImage('assets/BrandDay.jpg');
    } else if (eventName.toLowerCase().contains('car') ||
        eventName.toLowerCase().contains('auto')) {
      return const AssetImage('assets/Cars.jpg');
    } else {
      return const AssetImage('assets/BrandDay.jpg');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        constraints: const BoxConstraints(
          minHeight: 180, // Minimum height instead of fixed
          maxHeight: 250, // Optional: set a maximum
        ),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: _getEventImage(event.eventName),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // This is key
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMM d, yyyy').format(event.eventStartDate)} • ${DateFormat('h:mm a').format(event.eventStartTime)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(
                          '${event.availableBoothsCount} Booths Available',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Chip(
                        label: Text(
                          'Ongoing',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== UPCOMING EVENTS SECTION ==============

class UpcomingEventsTitle extends StatelessWidget {
  const UpcomingEventsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(
            Icons.event,
            color: Colors.blueGrey,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExhibitionGuest(),
                ),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events') // Organizer's events collection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const  Center(child: CircularProgressIndicator()
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading events')
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return  const Center(child: Text('No upcoming events')
          );
        }

        // We'll fetch booth data and process events in a separate async call
        return FutureBuilder<List<Event>>(
          future: _processEvents(snapshot.data!.docs),
          builder: (context, eventsSnapshot) {
            if (eventsSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!eventsSnapshot.hasData || eventsSnapshot.data!.isEmpty) {
              return Container(
                height: 120,
                child: const Center(child: Text('No upcoming events')),
              );
            }

            // Filter to only upcoming events and sort by date
            final upcomingEvents = eventsSnapshot.data!
                .where((event) => event.isUpcoming)
                .toList();

            upcomingEvents.sort((a, b) => a.fullStartDateTime.compareTo(b.fullStartDateTime));

            final limitedEvents = upcomingEvents.take(2).toList();

            if (limitedEvents.isEmpty) {
              return Container(
                height: 120,
                child: const Center(child: Text('No upcoming events')),
              );
            }

            return Column(
              children: [
                for (var event in limitedEvents)
                  UpcomingEventCard(event: event),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Event>> _processEvents(List<QueryDocumentSnapshot> docs) async {
    final List<Event> events = [];

    for (var doc in docs) {
      try {
        // Get booths for this event
        final booths = await _getBoothsForEvent(doc.id);

        // Create Event object using your model
        final event = Event.fromFirestore(doc, booths);
        events.add(event);
      } catch (e) {
        print('Error processing event ${doc.id}: $e');
      }
    }

    return events;
  }

  Future<List<Booth>> _getBoothsForEvent(String eventId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('booths')
          .where('eventId', isEqualTo: eventId)
          .get();

      return querySnapshot.docs
          .map((doc) => Booth.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching booths: $e');
      return [];
    }
  }
}

class UpcomingEventCard extends StatelessWidget {
  final Event event;

  const UpcomingEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM').format(event.eventStartDate);
    final day = event.eventStartDate.day.toString();
    final time = DateFormat('h:mm a').format(event.eventStartTime);

    return Center(
      child: Container(
        width: 350,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IntrinsicHeight( // Use IntrinsicHeight for equal height columns
          child: Row(
            children: [
              // Date Box
              Container(
                width: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2563eb),
                      Color(0xFF1e40af),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Event Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.eventName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2, // Allow wrapping
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Starts at $time',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              '${event.availableBoothsCount} Available',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.green[100],
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              DateFormat('MMM d, yyyy').format(event.eventStartDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class LayoutCard extends StatelessWidget {
  const LayoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
          image: const DecorationImage(
            image: AssetImage('assets/Layout.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class BookButton extends StatelessWidget {
  const BookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        label: const Text('Booking'),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('LOGIN FIRST!!'),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        },
      ),
    );
  }
}

class NoticeText extends StatelessWidget {
  const NoticeText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Log In First',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact us now!!!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Send us an email:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'berjaya@gmail.com',
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Convention Info',
                    }),
                  );

                  if (await canLaunchUrl(emailLaunchUri)) {
                    launchUrl(emailLaunchUri);
                  } else {
                    throw Exception('Could not launch $emailLaunchUri');
                  }
                },
                icon: const Icon(Icons.email, size: 20),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'berjaya@gmail.com',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.brown,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SMS us:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final Uri telLaunchUri = Uri(
                    scheme: 'tel',
                    path: '+1-555-010-999',
                  );
                  launchUrl(telLaunchUri);
                },
                icon: const Icon(Icons.phone, size: 20),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '+1-555-010-999',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.brown),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}