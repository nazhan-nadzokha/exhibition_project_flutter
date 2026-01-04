// --- PAGE 5: INCOMING REQUEST ---
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Process Request"),
        backgroundColor: Colors.blueAccent,
      ),
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
                  _buildModernTextField(
                    "Booth Name",
                    Icons.store,
                    initialValue: "Tech Booth A",
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          "Type",
                          Icons.category,
                          initialValue: "Standard",
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernTextField(
                          "Price",
                          Icons.attach_money,
                          initialValue: "RM 500",
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    "Applicant Note",
                    Icons.comment,
                    initialValue: "Selling accessories...",
                    readOnly: true,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader("Action"),
            const SizedBox(height: 15),

            // Decision Buttons
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    "Reject",
                    () {},
                    color: Colors.red[50]!,
                    textColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSecondaryButton(
                    "Withdraw",
                    () {},
                    color: Colors.orange[50]!,
                    textColor: Colors.orange[800]!,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPrimaryButton(
                    "Approve",
                    () {},
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text(
              "Reason for Rejection/Cancellation:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter reason here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    "Cancel",
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildPrimaryButton("Submit Reason", () {})),
              ],
            ),
          ],
        ),
      ),
    );
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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

}
