import 'package:flutter/material.dart';
import 'Login.dart';
import 'UserHome.dart';

// --- THEME CONSTANTS ---
const Color kPrimaryColor = Color(0xFF263238); // Dark Blue Grey
const Color kAccentColor = Color(0xFF009688);  // Teal
const Color kBackgroundColor = Color(0xFFF5F5F5); // Light Grey
const Color kDarkBackground = Color(0xFF1A1A1A); // Dashboard Dark Theme

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  // Mock Data
  int activeEvents = 8;
  int totalBooths = 8;
  int pendingRequests = 8;
  int approvedBookings = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      appBar: AppBar(
        title: const Text("Organizer Dashboard", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage()));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 5),
            const Text(
              "Najmii bin Nasruddin",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
                _buildStatCard("Active Events", activeEvents.toString(), Icons.event_available, Colors.blue),
                _buildStatCard("Total Booths", totalBooths.toString(), Icons.storefront, Colors.orange, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BoothManagementPage()));
                }),
                _buildStatCard("Pending Requests", pendingRequests.toString(), Icons.hourglass_top, Colors.redAccent, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const IncomingRequestPage()));
                }),
                _buildStatCard("Approved Bookings", approvedBookings.toString(), Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context, 
                    "Create Event", 
                    Icons.add, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventPage()))
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context, 
                    "Modify Event", 
                    Icons.edit, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ModifyEventPage()))
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Recent Events List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Recent Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        TextButton(onPressed: (){}, child: const Text("View All"))
                      ],
                    ),
                  ),
                  _buildEventListItem(isLast: false),
                  _buildEventListItem(isLast: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Modern Stat Card
  Widget _buildStatCard(String title, String count, IconData icon, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Slightly lighter than background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modern Event List Item
  Widget _buildEventListItem({required bool isLast}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.calendar_today, color: Colors.blue),
        ),
        title: const Text("Tech Innovation Summit", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Dec 24 • Hall 1 • Active"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kPrimaryColor),
            accountName: const Text("Najmii bin Nasruddin"),
            accountEmail: const Text("organizer@berjaya.com"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: kPrimaryColor)),
          ),
          ListTile(
            leading: const Icon(Icons.home), title: const Text('Home'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage())),
          ),
        ],
      ),
    );
  }
}

// --- PAGE 2: CREATE EVENT ---
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Create Event"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Event Details"),
            const SizedBox(height: 20),
            
            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  _buildModernTextField("Event Name", Icons.title),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildModernTextField("Date", Icons.calendar_month)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernTextField("Venue", Icons.location_on)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField("Description", Icons.description, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Action Buttons
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("Cancel", () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildPrimaryButton("Create Event", () => Navigator.pop(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAGE 3: MODIFY EVENT ---
class ModifyEventPage extends StatelessWidget {
  const ModifyEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Modify Event"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Edit Event"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  _buildModernTextField("Event Name", Icons.title, initialValue: "Existing Event A"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildModernTextField("Date", Icons.calendar_month, initialValue: "12/12/2025")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernTextField("Venue", Icons.location_on, initialValue: "Hall 1")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField("Description", Icons.description, maxLines: 3, initialValue: "Tech expo..."),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("Delete", () {}, color: Colors.red[50]!, textColor: Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildPrimaryButton("Save Changes", () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAGE 4: BOOTH MANAGEMENT ---
class BoothManagementPage extends StatelessWidget {
  const BoothManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Booth Management"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Create New Booth"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  _buildModernTextField("Booth Name/Number", Icons.store),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildModernTextField("Type", Icons.category)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernTextField("Price (RM)", Icons.attach_money)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField("Description", Icons.description, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("Cancel", () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildPrimaryButton("Create Booth", () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAGE 5: INCOMING REQUEST ---
class IncomingRequestPage extends StatefulWidget {
  const IncomingRequestPage({super.key});

  @override
  State<IncomingRequestPage> createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text("Process Request"), backgroundColor: kPrimaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildSectionHeader("Application Details"),
            const SizedBox(height: 20),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  _buildModernTextField("Booth Name", Icons.store, initialValue: "Tech Booth A", readOnly: true),
                  const SizedBox(height: 16),
                   Row(
                    children: [
                      Expanded(child: _buildModernTextField("Type", Icons.category, initialValue: "Standard", readOnly: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernTextField("Price", Icons.attach_money, initialValue: "RM 500", readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField("Applicant Note", Icons.comment, initialValue: "Selling accessories...", readOnly: true, maxLines: 2),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("Action"),
            const SizedBox(height: 15),

            // Decision Buttons
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("Reject", () {}, color: Colors.red[50]!, textColor: Colors.red)),
                const SizedBox(width: 10),
                Expanded(child: _buildSecondaryButton("Withdraw", () {}, color: Colors.orange[50]!, textColor: Colors.orange[800]!)),
                const SizedBox(width: 10),
                Expanded(child: _buildPrimaryButton("Approve", () {}, color: Colors.green)),
              ],
            ),
            
            const SizedBox(height: 25),
            const Text("Reason for Rejection/Cancellation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter reason here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
              ),
            ),

            const SizedBox(height: 30),
             Row(
              children: [
                Expanded(child: _buildSecondaryButton("Cancel", () => Navigator.pop(context))),
                const SizedBox(width: 16),
                Expanded(child: _buildPrimaryButton("Submit Reason", () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODERN UI HELPERS ---

Widget _buildSectionHeader(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
  );
}

// A prettier Text Field with Label included
Widget _buildModernTextField(String label, IconData icon, {int maxLines = 1, String? initialValue, bool readOnly = false}) {
  return TextFormField(
    initialValue: initialValue,
    readOnly: readOnly,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: readOnly ? Colors.grey[100] : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAccentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

Widget _buildPrimaryButton(String text, VoidCallback onPressed, {Color color = kPrimaryColor}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onPressed: onPressed,
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _buildSecondaryButton(String text, VoidCallback onPressed, {Color color = Colors.white, Color textColor = Colors.black87}) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textColor,
      side: BorderSide(color: textColor == Colors.black87 ? Colors.black26 : textColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onPressed: onPressed,
    child: Text(text),
  );
}