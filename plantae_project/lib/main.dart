import 'package:flutter/material.dart';

import 'package:plantae_project/EditUserProfile.dart';
import 'package:plantae_project/login.dart';
import 'package:plantae_project/mainPage.dart';
import 'package:plantae_project/signUp.dart';
import 'package:plantae_project/addPost.dart';
import 'package:plantae_project/util/user_auth.dart';
import 'package:plantae_project/userProfile.dart';
import 'package:plantae_project/util/AppRoutes.dart';
import 'package:flutter/services.dart';
import 'package:plantae_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plantae_project/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Plantae_App());
}

class Plantae_App extends StatelessWidget {
  const Plantae_App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Wrapper(),
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}



// list view each item taking full width
// 
