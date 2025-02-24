// filename: lib/home.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design/main_design.dart';
import 'design/nav_bar.dart';
import 'notification.dart';
import 'dashboard.dart';
import 'items.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  final int empId;
  final int currentDptId; 

  const HomeScreen({super.key, required this.empId, required this.currentDptId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late int empId;
  late int currentDptId; 
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();
    empId = widget.empId;
    currentDptId = widget.currentDptId; 
    debugPrint("HomeScreen initialized with empId: $empId, currentDptId: $currentDptId");

    // ✅ Initialize the default screen with empId and currentDptId
    _currentScreen = DashboardScreen(empId: empId, currentDptId: currentDptId);
  }

  void _handleMenuSelection(String title) {
  setState(() {
    debugPrint("Selected Menu: $title");
    switch (title) {
      case 'Notification':
        _currentScreen = const NotifScreen();
        break;
      case 'Dashboard':
        _currentScreen = DashboardScreen(empId: empId, currentDptId: currentDptId);
        break;
      case 'Items':
        ItemsPopup.show(context, empId, currentDptId, (Widget selectedScreen) {
          setState(() {
            _currentScreen = selectedScreen;
          });
        });
        break;
    }
  });
}


  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("User logged out, clearing SharedPreferences.");

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // Removes the back button
          title: const MainDesign(),
          toolbarHeight: kToolbarHeight, // Ensures standard AppBar height
          elevation: 0, // Removes any shadow
          backgroundColor: Colors.transparent, // Makes the app bar background transparent
          shape: const Border( // Optional: If you want to ensure a clean bottom edge
            bottom: BorderSide(
              color: Colors.black12, // Light shadow below the AppBar
              width: 1.0,
            ),
          ),
          titleSpacing: 0, // Removes any extra spacing from the title
        ),
      ),
      body: _currentScreen,
      bottomNavigationBar: BottomNavBar(
        onMenuItemSelected: _handleMenuSelection,
      ),
    );
  }
}
