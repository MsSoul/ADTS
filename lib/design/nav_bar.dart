import 'package:flutter/material.dart';
import 'colors.dart'; 

class BottomNavBar extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  
  const BottomNavBar({super.key, required this.onMenuItemSelected});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1; // Default to Dashboard

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        widget.onMenuItemSelected('Notification');
        break;
      case 1:
        widget.onMenuItemSelected('Dashboard');
        break;
      case 2:
        widget.onMenuItemSelected('Items');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, 
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      iconSize: 30,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: [
        _buildNavBarItem(
          icon: Icons.notifications,
          label: 'Notification',
          index: 0,
        ),
        _buildNavBarItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          index: 1,
        ),
        _buildNavBarItem(
          icon: Icons.inventory,
          label: 'Items',
          index: 2,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? AppColors.primaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: _selectedIndex == index ? Colors.white : Colors.grey,
        ),
      ),
      label: label,
    );
  }
}

/*import 'package:flutter/material.dart';
import 'colors.dart'; 
import 'main_design.dart'; 
import '../main.dart';


class SideBar extends StatelessWidget {
  final Function(String) onMenuItemSelected;

  const SideBar({super.key, required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = 100.0; 

    return Drawer(
      child: SizedBox(
        width: sidebarWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  mainLogo(
                    MediaQuery.of(context).size.width * 0.8,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
            leading: const Icon(
              Icons.notifications, // Changed icon to notification
              color: AppColors.primaryColor,
            ),
            title: const Text(
              'Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onTap: () {
              onMenuItemSelected('Notification'); 
              // Close the drawer after selection
              Navigator.pop(context);
            },
          ),

            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: AppColors.primaryColor,
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                onMenuItemSelected('Dashboard'); 
                // Close the drawer after selection
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.inventory,
                color: AppColors.primaryColor,
              ),
              title: const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                onMenuItemSelected('Items'); 
                // Close the drawer after selection
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppColors.primaryColor,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, 
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/