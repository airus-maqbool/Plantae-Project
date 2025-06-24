import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plantae_project/util/AppRoutes.dart';

class Forgetpassword extends StatelessWidget {
  TextEditingController _password = TextEditingController();
  TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Forget Password?",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 32, 124, 36),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

              TextField(
                controller: _email,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: const Color.fromARGB(255, 32, 124, 36),
                  ),
                  hintText: "Enter email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                
              ),
            SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person,
                  color: const Color.fromARGB(255, 32, 124, 36),
                ),
                hintText: "Enter password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.allow(RegExp("[a-z A-Z]"))
              ],
            ),
            SizedBox(height: 20),

            // Password Field
            TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: const Color.fromARGB(255, 32, 124, 36),
                  ),
                  hintText: "Confirm password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]"))
                ]),
            SizedBox(height: 10),

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.Login_PAGE);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 124, 36),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 252, 252, 252)),
              ),
            ),
            SizedBox(height: 20),

            // Sign Up Option

            Text(
              "Version 1.0 © 2025",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), // Light Green Background
    );
  }
}
