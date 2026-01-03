import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project_new_version/organizer/model/event_model.dart';
import 'package:exhibition_project_new_version/organizer/model/request_model.dart';

class OrganizerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final getRequestCount = await _firestore.collection('requests').get();
      return getRequestCount.size;
    } catch (e) {
      log('Error getting events with booths: $e');
      return 0;
    }
  }

  Future<int> getPendingRequest() async {
    try {
      final getPendingRequest = await _firestore
          .collection('requests')
          .where('requestStatus', isEqualTo: 'Pending')
          .get();
      return getPendingRequest.size;
    } catch (e) {
      log('Error getting events with booths: $e');
      return 0;
    }
  }

  Future<int> getApprovedRequest() async {
    try {
      final getApprovedRequest = await _firestore
          .collection('requests')
          .where('requestStatus', isEqualTo: 'Approved')
          .get();
      return getApprovedRequest.size;
    } catch (e) {
      log('Error getting events with booths: $e');
      return 0;
    }
  }

  // Get all requests with event and booth details
  Future<List<Request>> getAllRequests() async {
    try {
      // Get all requests
      final requestsSnapshot = await _firestore
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .get();

      // Process each request to get additional details
      final requests = await Future.wait(
        requestsSnapshot.docs.map((requestDoc) async {
          final requestData = requestDoc.data();

          // Create base request without event/booth names
          Request request = Request(
            id: requestDoc.id,
            boothId: requestData['boothId'] ?? '',
            eventId: requestData['eventId'] ?? '',
            requestStatus: requestData['requestStatus'] ?? 'pending',
            reason: requestData['reason'],
            userEmail: requestData['userEmail'] ?? '',
            userName: requestData['userName'],
            eventName: requestData['eventName'],
            boothName: requestData['boothName'],
            createdAt: requestData['createdAt'] != null
                ? (requestData['createdAt'] as Timestamp).toDate()
                : null,
            updatedAt: requestData['updatedAt'] != null
                ? (requestData['updatedAt'] as Timestamp).toDate()
                : null,
          );

          // If eventName is not in request, fetch it from events collection
          if (request.eventName == null && request.eventId.isNotEmpty) {
            try {
              final eventDoc = await _firestore
                  .collection('events')
                  .doc(request.eventId)
                  .get();

              if (eventDoc.exists) {
                request = request.copyWith(
                  eventName: eventDoc.data()?['eventName'] ?? 'Unknown Event',
                );
              }
            } catch (e) {
              log('Error fetching event name: $e');
            }
          }

          // If boothName is not in request, fetch it from booth collection
          if (request.boothName == null &&
              request.eventId.isNotEmpty &&
              request.boothId.isNotEmpty) {
            try {
              final boothDoc = await _firestore
                  .collection('events')
                  .doc(request.eventId)
                  .collection('booth')
                  .doc(request.boothId)
                  .get();

              if (boothDoc.exists) {
                request = request.copyWith(
                  boothName: boothDoc.data()?['boothName'] ?? 'Unknown Booth',
                );
              }
            } catch (e) {
              log('Error fetching booth name: $e');
            }
          }

          // If userName is not in request, fetch it from users collection
          if (request.userName == null && request.userEmail.isNotEmpty) {
            try {
              final usersSnapshot = await _firestore
                  .collection('users')
                  .where('email', isEqualTo: request.userEmail)
                  .limit(1)
                  .get();

              if (usersSnapshot.docs.isNotEmpty) {
                final userData = usersSnapshot.docs.first.data();
                final firstName = userData['firstName'] ?? '';
                final lastName = userData['lastName'] ?? '';
                final userName = '$firstName $lastName'.trim();
                if (userName.isNotEmpty) {
                  request = request.copyWith(userName: userName);
                }
              }
            } catch (e) {
              log('Error fetching user name: $e');
            }
          }

          return request;
        }).toList(),
      );

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
            (request) =>
                request.requestStatus.toLowerCase() == status.toLowerCase(),
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

  // Update request status
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? boothId,
    String? eventId,
    String? reason,
  }) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'requestStatus': status,
        'reason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If request is approved, update booth status to booked
      if (status.toLowerCase() == 'approved' &&
          boothId != null &&
          eventId != null) {
        await _firestore
            .collection('events')
            .doc(eventId)
            .collection('booth')
            .doc(boothId)
            .update({
              'boothStatus': 'Booked',
              'boothAvailability': false,
              'updatedAt': FieldValue.serverTimestamp(),
            });
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
            .update({
              'boothStatus': 'Available',
              'boothAvailability': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      log('Error updating request status: $e');
      rethrow;
    }
  }

  // Get request by ID
  Future<Request?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection('requests').doc(requestId).get();
      if (doc.exists) {
        return Request.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      log('Error getting request by ID: $e');
      return null;
    }
  }

  // Create a request
  Future<String?> createRequest({
    required String boothId,
    required String eventId,
    required String userEmail,
    String requestStatus = 'pending',
    String? userName,
    String? eventName,
    String? boothName,
  }) async {
    try {
      final docRef = await _firestore.collection('requests').add({
        'boothId': boothId,
        'eventId': eventId,
        'userEmail': userEmail,
        'requestStatus': requestStatus,
        if (userName != null) 'userName': userName,
        if (eventName != null) 'eventName': eventName,
        if (boothName != null) 'boothName': boothName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final requests = await Future.wait(
            snapshot.docs.map((doc) async {
              final request = Request.fromFirestore(doc);

              // Fetch additional details if needed
              if (request.eventName == null && request.eventId.isNotEmpty) {
                final eventDoc = await _firestore
                    .collection('events')
                    .doc(request.eventId)
                    .get();
                if (eventDoc.exists) {
                  return request.copyWith(
                    eventName: eventDoc.data()?['eventName'] ?? 'Unknown Event',
                  );
                }
              }

              return request;
            }).toList(),
          );

          return requests;
        });
  }
}
