// wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plantae_project/login.dart';
import 'package:plantae_project/mainPage.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 21, 91, 24)),
              ),
            ),
          );
        }
        
        // User is not signed in
        if (!snapshot.hasData) {
          return Login();
        }
        
        // User is signed in
        return MainPage();
      },
    );
  }
}
