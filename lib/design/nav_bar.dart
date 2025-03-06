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
        widget.onMenuItemSelected('Notification'); // Changed from Notification to Inbox
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
          icon: Icons.mail_outline, // Changed icon to mail outline
          label: 'Inbox', // Changed label from Notification to Inbox
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
