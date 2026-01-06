import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all events
  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').snapshots();
  }

  // Get booths inside a specific event
  Stream<QuerySnapshot> getBooths(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .snapshots();
  }

  // Save booking request
  Future<void> submitBoothApplication({
    required String eventId,
    required String eventTitle,
    required String boothId,
    required String companyName,
    required String companyDesc,
    required String companyEmail,
    required String exhibitProfile,
    required String startDate,
    required String endDate,
    required bool extraFurniture,
    required bool promoSpots,
    required bool extendedWifi,
  }) async {
    await _db.collection('booth_applications').add({
      'eventTitle': eventTitle,
      'boothId': boothId,
      'companyName': companyName,
      'companyDesc': companyDesc,
      'companyEmail': companyEmail,
      'exhibitProfile': exhibitProfile,
      'startDate': startDate,
      'endDate': endDate,
      'addons': {
        'extraFurniture': extraFurniture,
        'promoSpots': promoSpots,
        'extendedWifi': extendedWifi,
      },
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
