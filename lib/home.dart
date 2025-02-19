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
          _currentScreen = BorrowingItemsScreen(currentDptId: currentDptId);
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


/*import 'package:flutter/material.dart';
import 'design/main_design.dart'; 
import 'design/nav_bar.dart'; // Import the bottom nav bar
import 'notification.dart'; 
import 'dashboard.dart';
import 'items.dart'; 
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Widget _currentScreen = const DashboardScreen(); // Set the default screen to Dashboard after login

  void _handleMenuSelection(String title) {
    setState(() {
      if (title == 'Notification') {
        _currentScreen = const NotifScreen();
      } else if (title == 'Dashboard') {
        _currentScreen = const DashboardScreen();
      } else if (title == 'Items') {
        _currentScreen = const BorrowingItemsScreen();
      }
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Ensures standard AppBar height
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
      body: _currentScreen, // Display the Dashboard screen by default
      bottomNavigationBar: BottomNavBar(
        onMenuItemSelected: _handleMenuSelection,
      ),
    );
  }
}
*/


/*import 'package:flutter/material.dart';
import 'design/login_design.dart';
import 'design/main_design.dart';
import 'design/side_bar.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Add a variable to hold the content of the text
  String pageTitle = 'Welcome to the Inventory Borrowing System!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(
        // Pass the function to update the text in the home screen
        onMenuItemSelected: (String title) {
          setState(() {
            pageTitle = title; // Update the text content
          });
        },
      ),
      appBar: const MainDesign(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                child: buildLogo(400),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  pageTitle, // Display the updated title here
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/