import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plantae_project/parts/locationInputField.dart';
import 'package:plantae_project/util/user_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantae_project/util/locationServices.dart';
import 'package:plantae_project/util/AppRoutes.dart';
import 'package:plantae_project/login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _email = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _country = TextEditingController();
  TextEditingController _city = TextEditingController();

 Position? _userLocation;

  void _setLocation(Position pos) {
    setState(() {
      _userLocation = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset('assets/p1.png', height: 150, width: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 32, 124, 36),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person,
                      color: Color.fromARGB(255, 32, 124, 36)),
                  hintText: "Enter username",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                  FilteringTextInputFormatter.allow(RegExp("[a-z A-Z]"))
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email,
                      color: Color.fromARGB(255, 32, 124, 36)),
                  hintText: "Enter email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.lock, color: Color.fromARGB(255, 32, 124, 36)),
                  hintText: "Enter password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]"))
                ],
              ),
              SizedBox(height: 10),

              // Location Picker
              LocationInputField(onLocationSelected: _setLocation),
              SizedBox(height: 10),
              

            // Sign Up Option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    // Replace current page with Login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 84, 145, 87),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
             SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_userLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please pick a location")),
                    );
                    return;
                  }

                  print("Entered email: ${_email.text}");

                  Map m = {
                    "email": _email.text,
                    "username": _username.text,
                    "password": _password.text,
                    "location": _userLocation,
                  };

                  Future<bool> f = UserAuth.signupWithEmailPass(
                    email: _email.text,
                    pass: _password.text,
                    username: _username.text,
                    location: _userLocation!,
                  );

                  f.then((val) {
                    if (val) {
                      String msg = "Sign up successfully";
                      _email.clear();
                      _username.clear();
                      _password.clear();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
                      // Remove all routes and go to wrapper which will redirect to main page
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                    else{
                      String msg = "Something went wrong, try again";
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg))); 
                         _email.clear();
                         _username.clear();
                         _password.clear();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 32, 124, 36),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text("Version 1.0 © 2025",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
