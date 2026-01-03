import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:exhibition_project_new_version/organizer/model/request_model.dart';
import 'package:exhibition_project_new_version/services/organizer_service.dart';

class RequestsListPage extends StatefulWidget {
  final String title;
  final RequestFilterType filterType;

  const RequestsListPage({
    super.key,
    required this.title,
    required this.filterType,
  });

  @override
  State<RequestsListPage> createState() => _RequestsListPageState();
}

enum RequestFilterType { all, pending, approved, rejected }

class _RequestsListPageState extends State<RequestsListPage> {
  final OrganizerService _organizerService = OrganizerService();
  List<Request> requests = [];
  bool isLoading = true;
  bool isRefreshing = false;

  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);

    try {
      List<Request> fetchedRequests;

      switch (widget.filterType) {
        case RequestFilterType.pending:
          fetchedRequests = await _organizerService.getPendingRequests();
          break;
        case RequestFilterType.approved:
          fetchedRequests = await _organizerService.getApprovedRequests();
          break;
        case RequestFilterType.rejected:
          fetchedRequests = await _organizerService.getRequestsByStatus(
            'rejected',
          );
          break;
        case RequestFilterType.all:
          fetchedRequests = await _organizerService.getAllRequests();
          break;
      }

      setState(() => requests = fetchedRequests);
    } catch (e) {
      log('Error loading requests: $e');
      _showErrorSnackBar('Failed to load requests');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshRequests() async {
    setState(() => isRefreshing = true);
    await _loadRequests();
    setState(() => isRefreshing = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showRequestDetails(Request request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RequestDetailsBottomSheet(
          request: request,
          onStatusUpdated: _loadRequests,
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildRequestCard(Request request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.eventName ?? 'Unknown Event',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        request.requestStatus,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(request.requestStatus),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.requestStatus),
                          size: 14,
                          color: _getStatusColor(request.requestStatus),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.requestStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(request.requestStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.storefront,
                'Booth:',
                request.boothName ?? 'Unknown',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                'User:',
                request.userName ?? request.userEmail,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, 'Email:', request.userEmail),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(widget.filterType.name),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.filterType.name} requests',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you have ${widget.filterType.name} requests, they\'ll appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshRequests,
              child: requests.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(requests[index]);
                      },
                    ),
            ),
    );
  }
}

// Bottom Sheet for Request Details
class RequestDetailsBottomSheet extends StatelessWidget {
  final Request request;
  final VoidCallback onStatusUpdated;

  const RequestDetailsBottomSheet({
    super.key,
    required this.request,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailItem('Event Name', request.eventName ?? 'N/A'),
            _buildDetailItem('Booth Name', request.boothName ?? 'N/A'),
            _buildDetailItem('User Name', request.userName ?? 'N/A'),
            _buildDetailItem('User Email', request.userEmail),
            _buildDetailItem('Status', request.requestStatus.toUpperCase()),
            _buildDetailItem('Reason', request.reason ?? 'N/A'),
            _buildDetailItem(
              'Submitted',
              request.createdAt != null
                  ? '${request.createdAt!.day}/${request.createdAt!.month}/${request.createdAt!.year} ${request.createdAt!.hour}:${request.createdAt!.minute.toString().padLeft(2, '0')}'
                  : 'N/A',
            ),
            const SizedBox(height: 30),
            if (request.isPending) ...{
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Dismiss keyboard first
                        FocusScope.of(context).unfocus();

                        Navigator.pop(context);
                        try {
                          final organizerService = OrganizerService();

                          await organizerService.updateRequestStatus(
                            requestId: request.id,
                            status: 'Approved',
                            boothId: request.boothId,
                            eventId: request.eventId,
                          );
                          onStatusUpdated();

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request approved successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          log('Error updating request status: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve Request'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Dismiss keyboard first
                        FocusScope.of(context).unfocus();

                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => RejectDialog(
                            request: request,
                            onRejected: onStatusUpdated,
                            organizerService: OrganizerService(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject Request'),
                    ),
                  ),
                ],
              ),
            } else if (request.isApproved) ...{
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Dismiss keyboard first
                    FocusScope.of(context).unfocus();

                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => RejectDialog(
                        request: request,
                        onRejected: onStatusUpdated,
                        organizerService: OrganizerService(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject Request'),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class RejectDialog extends StatefulWidget {
  final Request request;
  final VoidCallback onRejected;
  final OrganizerService organizerService;

  const RejectDialog({
    super.key,
    required this.request,
    required this.onRejected,
    required this.organizerService,
  });

  @override
  State<RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<RejectDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  final FocusNode _reasonFocusNode = FocusNode();

  @override
  void dispose() {
    _reasonFocusNode.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRejection() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    if (_reasonController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.organizerService.updateRequestStatus(
        requestId: widget.request.id,
        status: 'Rejected',
        boothId: widget.request.boothId,
        eventId: widget.request.eventId,
        reason: _reasonController.text,
      );
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      widget.onRejected(); // Refresh parent list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _dismissDialog() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        // Handle Android back button
        canPop: !_isSubmitting,
        onPopInvoked: (didPop) {
          if (didPop) {
            FocusScope.of(context).unfocus();
          }
        },
        child: SimpleDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          contentPadding: const EdgeInsets.all(12),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Reject Request',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Are you sure you want to reject this request?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Please provide a reason:'),
                    ),
                    TextFormField(
                      focusNode: _reasonFocusNode,
                      controller: _reasonController,
                      maxLines: 3,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        // Handle enter key press
                        _submitRejection();
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : _dismissDialog,
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRejection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm Reject'),
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
