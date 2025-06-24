import 'package:flutter/material.dart';

class PrivacySwitch extends StatefulWidget {
  @override
  _PrivacySwitchState createState() => _PrivacySwitchState();
}

class _PrivacySwitchState extends State<PrivacySwitch> {
  bool isPrivate = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Private account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "With a private account, your post will not be published for all app users and will not circulate.Make your account public for sharing your posts with others.",
                  style: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 128, 128, 128)),
                ),
              ],
            ),
          ),
          Switch(
            value: isPrivate,
            onChanged: (value) {
              setState(() {
                isPrivate = value;
              });
            },
            activeColor: const Color.fromARGB(255, 9, 96, 12), // Green color when ON
            inactiveThumbColor: const Color.fromARGB(255, 126, 126, 126), // Grey when OFF
            inactiveTrackColor: const Color.fromARGB(255, 206, 206, 206), // Light grey track when OFF
          ),
        ],
      ),
    );
  }
}
