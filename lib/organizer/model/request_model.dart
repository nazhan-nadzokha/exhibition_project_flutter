import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String id;
  final String boothId;
  final String boothName;
  final String companyName;
  final String companyEmail;
  final String companyDesc;
  final String exhibitProfile;
  final String eventId;
  final String eventTitle;
  final String startDate;
  final String endDate;
  final String status;
  final String? reason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool extendedWifi;
  final bool extraFurniture;
  final bool promoSpots;

  Request({
    required this.id,
    required this.boothId,
    required this.boothName,
    required this.companyName,
    required this.companyEmail,
    required this.companyDesc,
    required this.exhibitProfile,
    required this.eventId,
    required this.eventTitle,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.extendedWifi,
    required this.extraFurniture,
    required this.promoSpots,
    this.reason,
    this.updatedAt,
  });

  // Factory constructor to create Request from Firestore document
  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle addons map
    final Map<String, dynamic> addons = data['addons'] is Map<String, dynamic>
        ? data['addons'] as Map<String, dynamic>
        : {};

    // Parse timestamp to DateTime
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Request(
      id: doc.id,
      boothId: data['boothId'] ?? '',
      boothName: data['boothName'] ?? '',
      companyName: data['companyName'] ?? '',
      companyEmail: data['companyEmail'] ?? '',
      companyDesc: data['companyDesc'] ?? '',
      exhibitProfile: data['exhibitProfile'] ?? '',
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      status: data['status'] ?? 'pending',
      reason: data['reason'],
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      extendedWifi: addons['extendedWifi'] ?? false,
      extraFurniture: addons['extraFurniture'] ?? false,
      promoSpots: addons['promoSpots'] ?? false,
    );
  }

  // Factory constructor to create Request from Map
  factory Request.fromMap(Map<String, dynamic> map) {
    // Handle addons map
    final Map<String, dynamic> addons = map['addons'] is Map<String, dynamic>
        ? map['addons'] as Map<String, dynamic>
        : {};

    // Parse timestamp to DateTime
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Request(
      id: map['id'] ?? '',
      boothId: map['boothId'] ?? '',
      boothName: map['boothName'] ?? '',
      companyName: map['companyName'] ?? '',
      companyEmail: map['companyEmail'] ?? '',
      companyDesc: map['companyDesc'] ?? '',
      exhibitProfile: map['exhibitProfile'] ?? '',
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      status: map['status'] ?? 'pending',
      reason: map['reason'],
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
      extendedWifi: addons['extendedWifi'] ?? false,
      extraFurniture: addons['extraFurniture'] ?? false,
      promoSpots: addons['promoSpots'] ?? false,
    );
  }

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'boothId': boothId,
      'boothName': boothName,
      'companyName': companyName,
      'companyEmail': companyEmail,
      'companyDesc': companyDesc,
      'exhibitProfile': exhibitProfile,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'addons': {
        'extendedWifi': extendedWifi,
        'extraFurniture': extraFurniture,
        'promoSpots': promoSpots,
      },
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Copy with method
  Request copyWith({
    String? id,
    String? boothId,
    String? boothName,
    String? companyName,
    String? companyEmail,
    String? companyDesc,
    String? exhibitProfile,
    String? eventId,
    String? eventTitle,
    String? startDate,
    String? endDate,
    String? status,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? extendedWifi,
    bool? extraFurniture,
    bool? promoSpots,
  }) {
    return Request(
      id: id ?? this.id,
      boothId: boothId ?? this.boothId,
      boothName: boothName ?? this.boothName,
      companyName: companyName ?? this.companyName,
      companyEmail: companyEmail ?? this.companyEmail,
      companyDesc: companyDesc ?? this.companyDesc,
      exhibitProfile: exhibitProfile ?? this.exhibitProfile,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extendedWifi: extendedWifi ?? this.extendedWifi,
      extraFurniture: extraFurniture ?? this.extraFurniture,
      promoSpots: promoSpots ?? this.promoSpots,
    );
  }

  // Helper getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  // Format date for display
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Format date range
  String get dateRange {
    return '$startDate - $endDate';
  }

  // Get addons list as string
  String get addonsList {
    List<String> selectedAddons = [];
    if (extendedWifi) selectedAddons.add('Extended WiFi');
    if (extraFurniture) selectedAddons.add('Extra Furniture');
    if (promoSpots) selectedAddons.add('Promo Spots');

    return selectedAddons.isEmpty ? 'None' : selectedAddons.join(', ');
  }

  @override
  String toString() {
    return 'Request(id: $id, status: $status, company: $companyName, booth: $boothName, event: $eventTitle)';
  }
}
