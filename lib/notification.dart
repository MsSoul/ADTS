import 'package:flutter/material.dart';
import 'design/nav_bar.dart'; 

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  String pageTitle = 'NO NOTIFICATIONS SO FAR!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: BottomNavBar(
        onMenuItemSelected: (String title) {
          setState(() {
            pageTitle = title; 
          });
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            pageTitle, 
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
