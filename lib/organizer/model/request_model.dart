import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String id;
  final String boothId;
  final String eventId;
  final String requestStatus;
  final String? reason;
  final String userEmail;
  final String? userName;
  final String? eventName;
  final String? boothName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Request({
    required this.id,
    required this.boothId,
    required this.eventId,
    required this.requestStatus,
    required this.userEmail,
    this.reason,
    this.userName,
    this.eventName,
    this.boothName,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Request from Firestore document
  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      boothId: data['boothId'] ?? '',
      eventId: data['eventId'] ?? '',
      requestStatus: data['requestStatus'] ?? 'pending',
      reason: data['reason'],
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'],
      eventName: data['eventName'],
      boothName: data['boothName'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory constructor to create Request from Map
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] ?? '',
      boothId: map['boothId'] ?? '',
      eventId: map['eventId'] ?? '',
      requestStatus: map['requestStatus'] ?? 'pending',
      reason: map['reason'],
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'],
      eventName: map['eventName'],
      boothName: map['boothName'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
                ? (map['createdAt'] as Timestamp).toDate()
                : DateTime.parse(map['createdAt'].toString()))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt'].toString()))
          : null,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'boothId': boothId,
      'eventId': eventId,
      'requestStatus': requestStatus,

      'userEmail': userEmail,
      if (reason != null) 'reason': reason,
      if (userName != null) 'userName': userName,
      if (eventName != null) 'eventName': eventName,
      if (boothName != null) 'boothName': boothName,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Copy with method
  Request copyWith({
    String? id,
    String? boothId,
    String? eventId,
    String? requestStatus,
    String? reason,
    String? userEmail,
    String? userName,
    String? eventName,
    String? boothName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Request(
      id: id ?? this.id,
      boothId: boothId ?? this.boothId,
      eventId: eventId ?? this.eventId,
      requestStatus: requestStatus ?? this.requestStatus,
      reason: reason ?? this.reason,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      eventName: eventName ?? this.eventName,
      boothName: boothName ?? this.boothName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getter
  bool get isPending => requestStatus.toLowerCase() == 'pending';
  bool get isApproved => requestStatus.toLowerCase() == 'approved';
  bool get isRejected => requestStatus.toLowerCase() == 'rejected';

  @override
  String toString() {
    return 'Request(id: $id, status: $requestStatus, user: $userEmail, booth: $boothId, event: $eventId)';
  }
}
