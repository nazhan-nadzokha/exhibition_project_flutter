import 'package:cloud_firestore/cloud_firestore.dart';

class Booth {
  final String id;
  final String eventId;
  final String boothName;
  final String boothStatus;
  final bool boothAvailability;

  Booth({
    required this.id,
    required this.eventId,
    required this.boothName,
    required this.boothStatus,
    required this.boothAvailability,
  });

  // Factory constructor to create Booth from Firestore document
  factory Booth.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booth(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      boothName: data['boothName'] ?? '',
      boothStatus: data['boothStatus'] ?? 'Unknown',
      boothAvailability: data['boothAvailability'] ?? false,
    );
  }

  // Factory constructor to create Booth from Map
  factory Booth.fromMap(Map<String, dynamic> map) {
    return Booth(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      boothName: map['boothName'] ?? '',
      boothStatus: map['boothStatus'] ?? 'Unknown',
      boothAvailability: map['boothAvailability'] ?? false,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'boothName': boothName,
      'boothStatus': boothStatus,
      'boothAvailability': boothAvailability,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Copy with method for immutability
  Booth copyWith({
    String? id,
    String? eventId,
    String? boothName,
    String? boothStatus,
    bool? boothAvailability,
  }) {
    return Booth(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      boothName: boothName ?? this.boothName,
      boothStatus: boothStatus ?? this.boothStatus,
      boothAvailability: boothAvailability ?? this.boothAvailability,
    );
  }

  @override
  String toString() {
    return 'Booth(id: $id, boothName: $boothName, status: $boothStatus, available: $boothAvailability)';
  }
}

class Event {
  final String id;
  final String eventName;
  final DateTime eventStartDate;
  final DateTime eventStartTime;
  final DateTime eventEndDate;
  final DateTime eventEndTime;
  final List<Booth> booths;

  Event({
    required this.id,
    required this.eventName,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.eventEndDate,
    required this.eventEndTime,
    required this.booths,
  });

  // Factory constructor to create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc, List<Booth> booths) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function to convert Firestore Timestamp to DateTime
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is DateTime) {
        return timestamp;
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }

    return Event(
      id: doc.id,
      eventName: data['eventName'] ?? '',
      eventStartDate: parseTimestamp(data['eventStartDate']),
      eventStartTime: parseTimestamp(data['eventStartTime']),
      eventEndDate: parseTimestamp(data['eventEndDate']),
      eventEndTime: parseTimestamp(data['eventEndTime']),
      booths: booths,
    );
  }

  // Factory constructor to create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    List<Booth> booths = [];
    if (map['booths'] != null && map['booths'] is List) {
      booths = (map['booths'] as List)
          .map((b) => Booth.fromMap(b as Map<String, dynamic>))
          .toList();
    }

    // Helper function to convert dynamic to DateTime
    DateTime parseDateTime(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is DateTime) {
        return date;
      } else if (date is String) {
        return DateTime.parse(date);
      } else if (date is Map && date['_seconds'] != null) {
        // Handle Firestore timestamp in Map format
        return DateTime.fromMillisecondsSinceEpoch(
          (date['_seconds'] as int) * 1000,
        );
      }
      return DateTime.now();
    }

    return Event(
      id: map['id'] ?? '',
      eventName: map['eventName'] ?? '',
      eventStartDate: parseDateTime(map['eventStartDate']),
      eventStartTime: parseDateTime(map['eventStartTime']),
      eventEndDate: parseDateTime(map['eventEndDate']),
      eventEndTime: parseDateTime(map['eventEndTime']),
      booths: booths,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'eventStartDate': Timestamp.fromDate(eventStartDate),
      'eventStartTime': Timestamp.fromDate(eventStartTime),
      'eventEndDate': Timestamp.fromDate(eventEndDate),
      'eventEndTime': Timestamp.fromDate(eventEndTime),
      'booths': booths.map((booth) => booth.toMap()).toList(),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Copy with method for immutability
  Event copyWith({
    String? id,
    String? eventName,
    DateTime? eventStartDate,
    DateTime? eventStartTime,
    DateTime? eventEndDate,
    DateTime? eventEndTime,
    List<Booth>? booths,
  }) {
    return Event(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      eventStartDate: eventStartDate ?? this.eventStartDate,
      eventStartTime: eventStartTime ?? this.eventStartTime,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      eventEndTime: eventEndTime ?? this.eventEndTime,
      booths: booths ?? this.booths,
    );
  }

  // Helper getters
  DateTime get fullStartDateTime => DateTime(
    eventStartDate.year,
    eventStartDate.month,
    eventStartDate.day,
    eventStartTime.hour,
    eventStartTime.minute,
  );

  DateTime get fullEndDateTime => DateTime(
    eventEndDate.year,
    eventEndDate.month,
    eventEndDate.day,
    eventEndTime.hour,
    eventEndTime.minute,
  );

  Duration get duration => fullEndDateTime.difference(fullStartDateTime);

  // Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(fullStartDateTime) && now.isBefore(fullEndDateTime);
  }

  // Check if event is upcoming
  bool get isUpcoming => DateTime.now().isBefore(fullStartDateTime);

  // Check if event is past
  bool get isPast => DateTime.now().isAfter(fullEndDateTime);

  // Get available booths count
  int get availableBoothsCount =>
      booths.where((booth) => booth.boothAvailability).length;

  // Get booked booths count
  int get bookedBoothsCount =>
      booths.where((booth) => !booth.boothAvailability).length;

  // Get booth by status
  List<Booth> getAvailableBooths() =>
      booths.where((booth) => booth.boothAvailability).toList();

  List<Booth> getBookedBooths() =>
      booths.where((booth) => !booth.boothAvailability).toList();

  @override
  String toString() {
    return 'Event(id: $id, name: $eventName, start: $fullStartDateTime, end: $fullEndDateTime, booths: ${booths.length})';
  }
}
