import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserService userService = UserService();

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?>get authStateChanges => firebaseAuth.authStateChanges();
//login
  Future<UserCredential> signIn({
    required String email,
    required String password,
}) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
  //register
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dob,
    required String phone,
    String role = 'user',
  }) async {
    try {
      print('=== REGISTRATION DEBUG ===');
      print('1. Creating Firebase Auth user...');

      // 1. Create auth user
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = userCredential.user!.uid;
      print('✅ Auth created. User ID: $userId');
      print('User email: ${userCredential.user!.email}');
      print('Is email verified: ${userCredential.user!.emailVerified}');

      // 2. Prepare data for Firestore
      final userData = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('2. Preparing to save to Firestore...');
      print('Collection: users');
      print('Document ID: $userId');
      print('Data to save:');
      userData.forEach((key, value) => print('  - $key: $value'));

      // 3. Save to Firestore
      print('3. Saving to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      print('✅ Firestore write successful!');

      // 4. Send verification email
      print('4. Sending verification email...');
      await userCredential.user!.sendEmailVerification();
      print('✅ Verification email sent');

      print('=== REGISTRATION COMPLETE ===');
      return userCredential;

    } catch (e) {
      print('❌ REGISTRATION ERROR: $e');
      print('Error type: ${e.runtimeType}');

      // Check if it's a FirebaseAuthException
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      }

      // Check if it's a FirebaseException (Firestore)
      if (e is FirebaseException) {
        print('Firestore Error Code: ${e.code}');
        print('Firestore Error Message: ${e.message}');
      }

      rethrow;
    }
  }
  //logout
  Future<void> signOut() async {
     await firebaseAuth.signOut();
  }
  //forgot password
  Future<void> resetPassword({
    required String email,
  }) async {
     await firebaseAuth.sendPasswordResetEmail(email: email);
  }
//Email Verification
  Future<void> sendEmailVerification() async {
    await firebaseAuth.currentUser?.sendEmailVerification();
  }
}
//User Profile
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String dob,
    required String phone,
    String role = 'user',
  }) async {
    try{
      print('Creating Firestore document for: $userId'); // Debug log

      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Firestore document created successfully'); // Debug log
    }catch(e){
      print('Error creating Firestore profile: $e'); // Debug log
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
  Future<void> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? dob,
    String? phone,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (dob != null) updates['dob'] = dob;
    if (phone != null) updates['phone'] = phone;

    await _firestore.collection('users').doc(userId).update(updates);
  }
  // Real-time stream of user profile
  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  // Real-time stream of all users (for admin)
  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList());
  }

  // Real-time stream with filtering (e.g., by role)
  Stream<List<Map<String, dynamic>>> streamUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList());
  }

  // Add this method to get user role
  Future<String> getUserRole(String uid) async {
    try {
      print('=== GET USER ROLE DEBUG ===');
      print('Fetching role for user: $uid');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final role = doc.data()!['role'] ?? 'user';
        print('✅ Found role: $role');
        return role;
      } else {
        print('⚠️ No user document found for uid: $uid');
        return 'user'; // Default role if not found
      }
    } catch (e) {
      print('❌ Error getting user role: $e');
      print('Error type: ${e.runtimeType}');
      return 'user'; // Default on error
    }
  }

  // method to update user role (for admin use)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Updated role to $newRole for user: $userId');
    } catch (e) {
      print('❌ Error updating user role: $e');
      rethrow;
    }
  }
}
}