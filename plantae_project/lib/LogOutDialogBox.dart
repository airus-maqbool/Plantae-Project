import 'package:flutter/material.dart';

class Logoutdialogbox extends StatelessWidget{
  @override
  Widget build (BuildContext context){
    return AlertDialog(
                  title: Text("Log Out"),
                  content: Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Add your logout logic here
                      },
                      child: Text("Yes"),
                    ),
                  ],
                );
  }
}