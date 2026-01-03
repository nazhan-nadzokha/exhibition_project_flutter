// --- PAGE 2: CREATE EVENT ---
import 'package:flutter/material.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: Colors.blueAccent,
      ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernTextField("Event Name", Icons.title),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          "Date",
                          Icons.calendar_month,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernTextField(
                          "Venue",
                          Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    "Description",
                    Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    "Cancel",
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrimaryButton(
                    "Create Event",
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

// A prettier Text Field with Label included
Widget _buildModernTextField(
  String label,
  IconData icon, {
  int maxLines = 1,
  String? initialValue,
  bool readOnly = false,
}) {
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
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}


Widget _buildPrimaryButton(
  String text,
  VoidCallback onPressed, {
  Color color = Colors.blueGrey,
}) {
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

Widget _buildSecondaryButton(
  String text,
  VoidCallback onPressed, {
  Color color = Colors.white,
  Color textColor = Colors.black87,
}) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textColor,
      side: BorderSide(
        color: textColor == Colors.black87
            ? Colors.black26
            : textColor.withOpacity(0.3),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onPressed: onPressed,
    child: Text(text),
  );
}
