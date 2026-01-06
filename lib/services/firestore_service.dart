import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== EVENTS =====
  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').snapshots();
  }

  // ===== BOOTHS =====
  Stream<QuerySnapshot> getBooths(String eventId) {
    return _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .snapshots();
  }

  // ===== SUBMIT APPLICATION (USER) =====
  Future<void> submitBoothApplication({
    required String eventId,
    required String eventTitle,
    required String boothId,
    required String boothNumber,
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
    final uid = _auth.currentUser!.uid;

    await _db.collection('booth_applications').add({
      'userId': uid,                     // 🔥 IMPORTANT
      'eventId': eventId,
      'eventTitle': eventTitle,
      'boothId': boothId,
      'boothNumber': boothNumber,

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

      'status': 'pending',               // pending | approved | rejected
      'reason': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ===== USER: GET MY APPLICATIONS =====
  Stream<QuerySnapshot> getMyApplications() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('booth_applications')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  // ===== ORGANIZER: GET ALL APPLICATIONS =====
  Stream<QuerySnapshot> getAllApplications() {
    return _db
        .collection('booth_applications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ===== ORGANIZER: APPROVE =====
  Future<void> approveApplication(String docId, String eventId, String boothId) async {
    // update application status
    await _db.collection('booth_applications').doc(docId).update({
      'status': 'approved',
      'reason': '',
    });

    // 🔒 lock booth
    await _db
        .collection('events')
        .doc(eventId)
        .collection('booths')
        .doc(boothId)
        .update({'boothStatus': 'booked'});
  }

  // ===== ORGANIZER: REJECT =====
  Future<void> rejectApplication(String docId, String reason) async {
    await _db.collection('booth_applications').doc(docId).update({
      'status': 'rejected',
      'reason': reason,
    });
  }
}
