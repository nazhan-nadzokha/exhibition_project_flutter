import 'dart:developer';

import 'package:exhibition_project_new_version/organizer/create_event_page.dart';
import 'package:flutter/material.dart';
import 'package:exhibition_project_new_version/organizer/model/event_model.dart';
import 'package:exhibition_project_new_version/services/organizer_service.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final OrganizerService _organizerService = OrganizerService();
  List<Event> events = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String _searchQuery = '';
  EventFilterType _filterType = EventFilterType.all;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => isLoading = true);

    try {
      final fetchedEvents = await _organizerService.getAllEventsWithBooths();
      setState(() => events = fetchedEvents);
    } catch (e) {
      log('Error loading events: $e');
      _showErrorSnackBar('Failed to load events');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshEvents() async {
    setState(() => isRefreshing = true);
    await _loadEvents();
    setState(() => isRefreshing = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<Event> get _filteredEvents {
    List<Event> filtered = events;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.eventName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();
    }

    // Apply status filter
    switch (_filterType) {
      case EventFilterType.ongoing:
        filtered = filtered.where((event) => event.isOngoing).toList();
        break;
      case EventFilterType.upcoming:
        filtered = filtered.where((event) => event.isUpcoming).toList();
        break;
      case EventFilterType.past:
        filtered = filtered.where((event) => event.isPast).toList();
        break;
      case EventFilterType.all:
        break;
    }

    return filtered;
  }

  Color _getStatusColor(Event event) {
    if (event.isOngoing) return Colors.green;
    if (event.isUpcoming) return Colors.blue;
    return Colors.grey;
  }

  String _getStatusText(Event event) {
    if (event.isOngoing) return 'Ongoing';
    if (event.isUpcoming) return 'Upcoming';
    return 'Past';
  }

  IconData _getStatusIcon(Event event) {
    if (event.isOngoing) return Icons.play_circle_filled;
    if (event.isUpcoming) return Icons.upcoming;
    return Icons.history;
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
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
                    event.eventName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(event), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(event),
                        size: 14,
                        color: _getStatusColor(event),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(event).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(event),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Date:',
              '${_formatDate(event.fullStartDateTime)} - ${_formatDate(event.fullEndDateTime)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Duration:',
              '${event.duration.inHours} hours',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.storefront,
              'Booths:',
              '${event.booths.length} total • ${event.availableBoothsCount} available • ${event.bookedBoothsCount} booked',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                  Icons.event_available,
                  '${event.availableBoothsCount}',
                  'Available',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.event_busy,
                  '${event.bookedBoothsCount}',
                  'Booked',
                  Colors.blue,
                ),
              ],
            ),
          ],
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

  Widget _buildStatChip(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No events found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty)
            Text(
              'Try a different search term',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            )
          else if (_filterType != EventFilterType.all)
            Text(
              'No ${_filterType.name} events',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Create your first event to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildFilterChip(EventFilterType type, String label) {
    final isSelected = _filterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = selected ? type : EventFilterType.all;
        });
      },
      selectedColor: Colors.blueAccent,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEvents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(EventFilterType.all, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(EventFilterType.ongoing, 'Ongoing'),
                  const SizedBox(width: 8),
                  _buildFilterChip(EventFilterType.upcoming, 'Upcoming'),
                  const SizedBox(width: 8),
                  _buildFilterChip(EventFilterType.past, 'Past'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Events List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: _filteredEvents.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildEmptyState(),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filteredEvents.length,
                            itemBuilder: (context, index) {
                              return _buildEventCard(_filteredEvents[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          ).then((_) {
            // Refresh events when returning from create page
            _loadEvents();
          });
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

enum EventFilterType { all, ongoing, upcoming, past }
