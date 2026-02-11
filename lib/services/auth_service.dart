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
}