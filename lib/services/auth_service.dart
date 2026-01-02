import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
}