import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantae_project/forgetPassword.dart';

class UserAuth {
  static Future<bool> signupWithEmailPass({
    required String username,
    required String pass,
    required String email,
    required Position location,
  }) async {
    try {
      // Firebase Authentication
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      String userId = cred.user!.uid;

      // Firestore: Store user info with location as a map
      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'uid': userId,
        'username': username,
        'email': email,
        'location': GeoPoint(location.latitude, location.longitude),
      });

      return true;
    } catch (e) {
      print("Error during signup: $e");
      return false;
    }
  }

  //signIn function
  static Future<bool> signInWithEmailPass({
    required String pass,
    required String email,
  }) async {
    try {
      // Firebase Authentication
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      String userId = cred.user!.uid;
      return true;
    } catch (e) {
      print("Error during signup: $e");
      return false;
    }
  }

  //forget password
  static Future<bool> Forgetpassword({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  //get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  //logout 
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
