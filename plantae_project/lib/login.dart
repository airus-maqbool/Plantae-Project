import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plantae_project/util/AppRoutes.dart';
import 'package:plantae_project/util/user_auth.dart';
import 'package:plantae_project/signUp.dart';

class Login extends StatelessWidget {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Image.asset(
                'assets/p5.png',
                height: 200,
                width: 200,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "LogIn",
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

              // Password Field
              TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
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
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.allow(RegExp("[a-z A-Z 0-9]"))
                  ]),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_email.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter your email")),
                        );
                        return;
                      }

                      bool result =
                          await UserAuth.Forgetpassword(email: _email.text);
                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Password reset email sent")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to send email")),
                        );
                      }
                    },
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 17, 18, 17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Future<bool> f = UserAuth.signInWithEmailPass(
                    email: _email.text,
                    pass: _password.text,
                  );

                  f.then((val) {
                    if (val) {
                      String msg = "Login successfully";
                      _email.clear();
                      _password.clear();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    } else {
                      String msg = "Invalid user credentials, try again";
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
                      _email.clear();
                      _password.clear();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 32, 124, 36),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 252, 252, 252)),
                ),
              ),
              SizedBox(height: 20),

              // Sign Up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Replace current page with SignUp
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 84, 145, 87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Text(
                "Version 1.0 © 2025",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), // Light Green Background
    );
  }
}
