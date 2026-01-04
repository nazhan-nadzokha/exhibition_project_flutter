import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project_new_version/organizer/model/event_model.dart';
import 'package:exhibition_project_new_version/organizer/model/request_model.dart';

class OrganizerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _requestsCollection =
      'booth_applications'; // Updated collection name

  // Update this method to return List<Event>
  Future<List<Event>> getAllEventsWithBooths() async {
    try {
      final eventsSnapshot = await _firestore.collection('events').get();

      // Create a list of futures to fetch booths for each event
      final eventsWithBoothsFutures = eventsSnapshot.docs.map((eventDoc) async {
        // Get booths for this event
        final boothsSnapshot = await _firestore
            .collection('events')
            .doc(eventDoc.id)
            .collection('booth')
            .get();

        // Convert booths to Booth models
        final List<Booth> booths = boothsSnapshot.docs.map((boothDoc) {
          final boothData = boothDoc.data();
          return Booth(
            id: boothDoc.id,
            eventId: eventDoc.id,
            boothName: boothData['boothName'] ?? '',
            boothStatus: boothData['boothStatus'] ?? 'Unknown',
            boothAvailability: boothData['boothAvailability'] ?? false,
          );
        }).toList();

        // Create Event model from document data
        final eventData = eventDoc.data();
        return Event(
          id: eventDoc.id,
          eventName: eventData['eventName'] ?? '',
          eventStartDate: (eventData['eventStartDate'] as Timestamp).toDate(),
          eventStartTime: (eventData['eventStartTime'] as Timestamp).toDate(),
          eventEndDate: (eventData['eventEndDate'] as Timestamp).toDate(),
          eventEndTime: (eventData['eventEndTime'] as Timestamp).toDate(),
          booths: booths,
        );
      }).toList();

      // Wait for all futures to complete
      return await Future.wait(eventsWithBoothsFutures);
    } catch (e) {
      log('Error getting events with booths: $e');
      return [];
    }
  }

  Future<int> getRequestCount() async {
    try {
      final getRequestCount = await _firestore
          .collection(_requestsCollection)
          .get();
      return getRequestCount.size;
    } catch (e) {
      log('Error getting request count: $e');
      return 0;
    }
  }

  Future<int> getPendingRequest() async {
    try {
      final getPendingRequest = await _firestore
          .collection(_requestsCollection)
          .where(
            'status',
            isEqualTo: 'pending',
          ) // Changed from 'requestStatus' to 'status'
          .get();
      return getPendingRequest.size;
    } catch (e) {
      log('Error getting pending requests: $e');
      return 0;
    }
  }

  Future<int> getApprovedRequest() async {
    try {
      final getApprovedRequest = await _firestore
          .collection(_requestsCollection)
          .where(
            'status',
            isEqualTo: 'approved',
          ) // Changed from 'requestStatus' to 'status'
          .get();
      return getApprovedRequest.size;
    } catch (e) {
      log('Error getting approved requests: $e');
      return 0;
    }
  }

  Future<int> getRejectedRequest() async {
    try {
      final getRejectedRequest = await _firestore
          .collection(_requestsCollection)
          .where(
            'status',
            isEqualTo: 'rejected',
          ) // Changed from 'requestStatus' to 'status'
          .get();
      return getRejectedRequest.size;
    } catch (e) {
      log('Error getting rejected requests: $e');
      return 0;
    }
  }

  // Get all requests with event and booth details
  Future<List<Request>> getAllRequests() async {
    try {
      // Get all requests from correct collection
      final requestsSnapshot = await _firestore
          .collection(_requestsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      // Process each request
      final requests = requestsSnapshot.docs.map((requestDoc) {
        final requestData = requestDoc.data();

        // Extract addons map
        final Map<String, dynamic> addons =
            requestData['addons'] is Map<String, dynamic>
            ? requestData['addons'] as Map<String, dynamic>
            : {};

        // Create Request model from document data
        return Request(
          id: requestDoc.id,
          boothId: requestData['boothId'] ?? '',
          boothName: requestData['boothName'] ?? '',
          companyName: requestData['companyName'] ?? '',
          companyEmail: requestData['companyEmail'] ?? '',
          companyDesc: requestData['companyDesc'] ?? '',
          exhibitProfile: requestData['exhibitProfile'] ?? '',
          eventId: requestData['eventId'] ?? '',
          eventTitle: requestData['eventTitle'] ?? '',
          startDate: requestData['startDate'] ?? '',
          endDate: requestData['endDate'] ?? '',
          status: requestData['status'] ?? 'pending',
          reason: requestData['reason'],
          createdAt: requestData['createdAt'] != null
              ? (requestData['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          extendedWifi: addons['extendedWifi'] ?? false,
          extraFurniture: addons['extraFurniture'] ?? false,
          promoSpots: addons['promoSpots'] ?? false,
        );
      }).toList();

      return requests;
    } catch (e) {
      log('Error getting requests: $e');
      return [];
    }
  }

  // Get requests by status
  Future<List<Request>> getRequestsByStatus(String status) async {
    try {
      final requests = await getAllRequests();
      return requests
          .where(
            (request) => request.status.toLowerCase() == status.toLowerCase(),
          )
          .toList();
    } catch (e) {
      log('Error getting requests by status: $e');
      return [];
    }
  }

  // Get pending requests only
  Future<List<Request>> getPendingRequests() async {
    return getRequestsByStatus('pending');
  }

  // Get approved requests only
  Future<List<Request>> getApprovedRequests() async {
    return getRequestsByStatus('approved');
  }

  // Get rejected requests only
  Future<List<Request>> getRejectedRequests() async {
    return getRequestsByStatus('rejected');
  }

  // Update request status
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? boothId,
    String? eventId,
    String? reason,
  }) async {
    try {
      final updateData = {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      await _firestore
          .collection(_requestsCollection)
          .doc(requestId)
          .update(updateData);

      // If request is approved, update booth status to booked
      if (status.toLowerCase() == 'approved' &&
          boothId != null &&
          eventId != null) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('booth')
            .doc(boothId)
            .update({'boothStatus': 'Booked', 'boothAvailability': false});
      }

      // If request is rejected, update booth status back to available
      if (status.toLowerCase() == 'rejected' &&
          boothId != null &&
          eventId != null) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('booth')
            .doc(boothId)
            .update({'boothStatus': 'Available', 'boothAvailability': true});
      }
    } catch (e) {
      log('Error updating request status: $e');
      rethrow;
    }
  }

  // Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection(_requestsCollection)
          .doc(requestId)
          .get();
      if (doc.exists) {
        final requestData = doc.data() as Map<String, dynamic>;

        // Extract addons map
        final Map<String, dynamic> addons =
            requestData['addons'] is Map<String, dynamic>
            ? requestData['addons'] as Map<String, dynamic>
            : {};

        return Request(
          id: doc.id,
          boothId: requestData['boothId'] ?? '',
          boothName: requestData['boothName'] ?? '',
          companyName: requestData['companyName'] ?? '',
          companyEmail: requestData['companyEmail'] ?? '',
          companyDesc: requestData['companyDesc'] ?? '',
          exhibitProfile: requestData['exhibitProfile'] ?? '',
          eventId: requestData['eventId'] ?? '',
          eventTitle: requestData['eventTitle'] ?? '',
          startDate: requestData['startDate'] ?? '',
          endDate: requestData['endDate'] ?? '',
          status: requestData['status'] ?? 'pending',
          reason: requestData['reason'],
          createdAt: requestData['createdAt'] != null
              ? (requestData['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          extendedWifi: addons['extendedWifi'] ?? false,
          extraFurniture: addons['extraFurniture'] ?? false,
          promoSpots: addons['promoSpots'] ?? false,
        );
      }
      return null;
    } catch (e) {
      log('Error getting request by ID: $e');
      return null;
    }
  }

  // Create a request (for exhibitor to apply for booth)
  Future<String?> createRequest({
    required String boothId,
    required String boothName,
    required String eventId,
    required String eventTitle,
    required String companyName,
    required String companyEmail,
    required String companyDesc,
    required String exhibitProfile,
    required String startDate,
    required String endDate,
    bool extendedWifi = false,
    bool extraFurniture = false,
    bool promoSpots = false,
    String status = 'pending',
    String? reason,
  }) async {
    try {
      final docRef = await _firestore.collection(_requestsCollection).add({
        'boothId': boothId,
        'boothName': boothName,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'companyName': companyName,
        'companyEmail': companyEmail,
        'companyDesc': companyDesc,
        'exhibitProfile': exhibitProfile,
        'startDate': startDate,
        'endDate': endDate,
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'addons': {
          'extendedWifi': extendedWifi,
          'extraFurniture': extraFurniture,
          'promoSpots': promoSpots,
        },
      });

      return docRef.id;
    } catch (e) {
      log('Error creating request: $e');
      return null;
    }
  }

  // Stream for real-time requests updates
  Stream<List<Request>> getRequestsStream() {
    return _firestore
        .collection(_requestsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final requestData = doc.data();

            // Extract addons map
            final Map<String, dynamic> addons =
                requestData['addons'] is Map<String, dynamic>
                ? requestData['addons'] as Map<String, dynamic>
                : {};

            return Request(
              id: doc.id,
              boothId: requestData['boothId'] ?? '',
              boothName: requestData['boothName'] ?? '',
              companyName: requestData['companyName'] ?? '',
              companyEmail: requestData['companyEmail'] ?? '',
              companyDesc: requestData['companyDesc'] ?? '',
              exhibitProfile: requestData['exhibitProfile'] ?? '',
              eventId: requestData['eventId'] ?? '',
              eventTitle: requestData['eventTitle'] ?? '',
              startDate: requestData['startDate'] ?? '',
              endDate: requestData['endDate'] ?? '',
              status: requestData['status'] ?? 'pending',
              reason: requestData['reason'],
              createdAt: requestData['createdAt'] != null
                  ? (requestData['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              extendedWifi: addons['extendedWifi'] ?? false,
              extraFurniture: addons['extraFurniture'] ?? false,
              promoSpots: addons['promoSpots'] ?? false,
            );
          }).toList();
        });
  }

  // Get requests by company email
  Future<List<Request>> getRequestsByCompanyEmail(String companyEmail) async {
    try {
      final requestsSnapshot = await _firestore
          .collection(_requestsCollection)
          .where('companyEmail', isEqualTo: companyEmail)
          .orderBy('createdAt', descending: true)
          .get();

      return requestsSnapshot.docs.map((doc) {
        final requestData = doc.data();

        // Extract addons map
        final Map<String, dynamic> addons =
            requestData['addons'] is Map<String, dynamic>
            ? requestData['addons'] as Map<String, dynamic>
            : {};

        return Request(
          id: doc.id,
          boothId: requestData['boothId'] ?? '',
          boothName: requestData['boothName'] ?? '',
          companyName: requestData['companyName'] ?? '',
          companyEmail: requestData['companyEmail'] ?? '',
          companyDesc: requestData['companyDesc'] ?? '',
          exhibitProfile: requestData['exhibitProfile'] ?? '',
          eventId: requestData['eventId'] ?? '',
          eventTitle: requestData['eventTitle'] ?? '',
          startDate: requestData['startDate'] ?? '',
          endDate: requestData['endDate'] ?? '',
          status: requestData['status'] ?? 'pending',
          reason: requestData['reason'],
          createdAt: requestData['createdAt'] != null
              ? (requestData['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          extendedWifi: addons['extendedWifi'] ?? false,
          extraFurniture: addons['extraFurniture'] ?? false,
          promoSpots: addons['promoSpots'] ?? false,
        );
      }).toList();
    } catch (e) {
      log('Error getting requests by company email: $e');
      return [];
    }
  }
}
