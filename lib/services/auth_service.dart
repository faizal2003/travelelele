import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up: Create Account & Save Role
  Future<String?> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    required String gender,
  }) async {
    try {
      // 1. Create User in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save User Data + Role in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'name': name,
        'gender': gender, // "Laki-laki" or "Perempuan"
        'role': role, // "Customer", "Driver", or "Admin"
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign In: Login & Fetch Role
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login to Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Fetch Role from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (doc.exists) {
        return doc['role']; // Returns "Customer", "Driver", or "Admin"
      } else {
        return "Error: User data not found";
      }
    } on FirebaseAuthException catch (e) {
      return "Auth Error: ${e.message}";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateUserProfile({required String name, required String phone}) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone, // We will add a phone number field
      });
      return null; // Success
    } catch (e) {
      return "Failed to update profile: $e";
    }
  }

  // Get Current User Stream (Real-time updates)
  Stream<DocumentSnapshot> getUserStream() {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }
}

