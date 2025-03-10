import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:badges/badges.dart' as badges;

ValueNotifier<int> unreadNotifCount = ValueNotifier<int>(0);

class BottomNavBar extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  final int initialIndex; // ✅ Added initial index

  const BottomNavBar({super.key, required this.onMenuItemSelected, this.initialIndex = 1});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // ✅ Use provided initial index
  }

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
          icon: Icons.mail_outline,
          label: 'Inbox',
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
    Widget iconWidget = Icon(
      icon,
      color: _selectedIndex == index ? Colors.white : Colors.grey,
    );

    if (index == 0) {
      iconWidget = ValueListenableBuilder<int>(
        valueListenable: unreadNotifCount,
        builder: (context, count, child) {
          return badges.Badge(
            badgeContent: count > 0
                ? Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 12))
                : null,
            showBadge: count > 0,
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
            ),
            child: Icon(
              icon,
              color: _selectedIndex == index ? Colors.white : Colors.grey,
            ),
          );
        },
      );
    }

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? AppColors.primaryColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      ),
      label: label,
    );
  }
}
