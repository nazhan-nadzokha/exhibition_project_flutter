import 'dart:developer';

import 'package:exhibition_project_new_version/organizer/create_event_page.dart';
import 'package:exhibition_project_new_version/organizer/event_list_page.dart';
import 'package:exhibition_project_new_version/organizer/model/event_model.dart';
import 'package:exhibition_project_new_version/organizer/model/request_model.dart';
import 'package:exhibition_project_new_version/organizer/request_list_page.dart';
import 'package:exhibition_project_new_version/services/organizer_service.dart';
import 'package:flutter/material.dart';
import '../Login.dart';
import '../UserHome.dart';

// --- THEME CONSTANTS ---
const Color kPrimaryColor = Color(0xFF263238); // Dark Blue Grey
const Color kAccentColor = Color(0xFF009688); // Teal
const Color kBackgroundColor = Color(0xFFF5F5F5); // Light Grey
const Color kDarkBackground = Color(0xFF1A1A1A); // Dashboard Dark Theme

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  final OrganizerService _organizerService = OrganizerService();
  List<Event> events = []; // Add this to store events
  bool isLoading = false; // Add loading state
  List<Request> requests = [];

  // Mock Data
  int activeEvents = 0;
  int totalBooths = 0;
  int pendingRequests = 0;
  int approvedBookings = 0;

  @override
  void initState() {
    _getEventDetails();
    _getRequestCount();
    _getPendingRequestCount();
    _getApprovedRequestCount();
    _loadRequests();
    super.initState();
  }

  // Load requests
  Future<void> _loadRequests() async {
    setState(() => isLoading = true);

    try {
      final fetchedRequests = await _organizerService.getAllRequests();

      // Log requests for debugging
      for (final request in fetchedRequests) {
        log(
          'Request: ${request.eventName} - ${request.boothName} - ${request.userName} - ${request.requestStatus}',
        );
      }

      setState(() {
        requests = fetchedRequests;
        pendingRequests = fetchedRequests.where((r) => r.isPending).length;
        approvedBookings = fetchedRequests.where((r) => r.isApproved).length;
      });
    } catch (e) {
      log('Error loading requests: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getRequestCount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final requestCount = await _organizerService.getRequestCount();
      log(requestCount.toString());
      setState(() {
        totalBooths = requestCount;
        isLoading = false;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _getPendingRequestCount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final requestCount = await _organizerService.getPendingRequest();
      log('Pending request ${requestCount.toString()}');

      setState(() {
        pendingRequests = requestCount;
        isLoading = false;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _getApprovedRequestCount() async {
    setState(() {
      isLoading = true;
    });

    try {
      final requestCount = await _organizerService.getApprovedRequest();
      log('Approved request ${requestCount.toString()}');
      setState(() {
        approvedBookings = requestCount;
        isLoading = false;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _getEventDetails() async {
    setState(() => isLoading = true);

    try {
      final List<Event> eventList = await _organizerService
          .getAllEventsWithBooths();

      log('Fetched ${eventList.length} events');

      setState(() {
        events = eventList;
        // Update your statistics
        // activeEvents = eventList.where((e) => e.isOngoing).length;
        activeEvents = eventList.length;

        // totalBooths = eventList.fold(
        //   0,
        //   (sum, event) => sum + event.booths.length,
        // );
        // Calculate pendingRequests and approvedBookings based on booth status
        // pendingRequests = eventList.fold(
        //   0,
        //   (sum, event) =>
        //       sum +
        //       event.booths.where((b) => b.boothStatus == 'Pending').length,
        // );
        // approvedBookings = eventList.fold(
        //   0,
        //   (sum, event) =>
        //       sum + event.booths.where((b) => b.boothStatus == 'Booked').length,
        // );
      });
    } catch (e) {
      log('Error fetching events: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Organizer Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => const LoginPage()),
              // );
              _getEventDetails();
              _getRequestCount();
              _getPendingRequestCount();
              _getApprovedRequestCount();
              _loadRequests();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _getEventDetails();
                _getRequestCount();
                _getPendingRequestCount();
                _getApprovedRequestCount();
                _loadRequests();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    const Text(
                      "Welcome back,",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Najmii bin Nasruddin",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Dashboard Grid Cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          "Total Events",
                          activeEvents.toString(),
                          Icons.event_available,
                          Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventListPage(),
                              ),
                            );
                          },
                        ),
                        _buildStatCard(
                          "Total Requests",
                          totalBooths.toString(),
                          Icons.request_page,
                          Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RequestsListPage(
                                  title: "All Requests",
                                  filterType: RequestFilterType.all,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatCard(
                          "Pending Requests",
                          pendingRequests.toString(),
                          Icons.hourglass_top,
                          Colors.redAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RequestsListPage(
                                  title: "Pending Requests",
                                  filterType: RequestFilterType.pending,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildStatCard(
                          "Approved Requests",
                          approvedBookings.toString(),
                          Icons.check_circle,
                          Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RequestsListPage(
                                  title: "Approved Requests",
                                  filterType: RequestFilterType.approved,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    // Row(
                    //   children: [
                    // Expanded(
                    //   child: _buildActionButton(
                    //     context,
                    //     "Create Event",
                    //     Icons.add,
                    //     () => Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const CreateEventPage(),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildActionButton(
                    //         context,
                    //         "Modify Event",
                    //         Icons.edit,
                    //         () => Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => const ModifyEventPage(),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // Recent Events List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Recent Requests",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                // TextButton(
                                //   onPressed: () {},
                                //   child: const Text("View All"),
                                // ),
                              ],
                            ),
                          ),
                          // Use real events data
                          if (requests.isEmpty && !isLoading)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No events found'),
                            )
                          else if (isLoading)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            ...requests
                                .take(3)
                                .map((request) => _buildEventListItem(request)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blueAccent,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateEventPage()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Modern Stat Card
  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Slightly lighter than background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update the event list item to use Event model
  Widget _buildEventListItem(Request request) {
    return InkWell(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => IncomingRequestPage(event: event)));
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: request.isApproved
                  ? Colors.green[50]
                  : request.isPending
                  ? Colors.orange[50]
                  : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today,
              color: request.isApproved
                  ? Colors.green
                  : request.isPending
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
          title: Text(
            request.eventName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Booth: ${request.boothName}  • ${request.isApproved
                ? 'Approved'
                : request.isPending
                ? 'Pending'
                : 'Rejected'}",
          ),
          // trailing: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
  // Widget _buildActionButton(
  //   BuildContext context,
  //   String label,
  //   IconData icon,
  //   VoidCallback onTap,
  // ) {
  //   return ElevatedButton.icon(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.white,
  //       foregroundColor: kPrimaryColor,
  //       padding: const EdgeInsets.symmetric(vertical: 16),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //     onPressed: onTap,
  //     icon: Icon(icon, size: 20),
  //     label: Text(label),
  //   );
  // }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: kPrimaryColor),
            accountName: Text("Najmii bin Nasruddin"),
            accountEmail: Text("organizer@berjaya.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: kPrimaryColor),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const LoginPage())),
          ),
        ],
      ),
    );
  }
}
