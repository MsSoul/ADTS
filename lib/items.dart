// filenmae: items.dart
import 'package:flutter/material.dart';
import 'borrow_items_screen.dart';
import 'lend_items_screen.dart';
import 'design/colors.dart';

typedef OnItemSelected = void Function(Widget selectedScreen);

class ItemsPopup {
  static void show(BuildContext context, int empId, int currentDptId, OnItemSelected onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Please Select Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onSelect(BorrowItemsScreen(empId: empId, currentDptId: currentDptId));
                },
                child: const Text("Borrow Item", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onSelect(LendingItemsScreen(empId: empId, currentDptId: currentDptId));
                },
                child: const Text("Lend Item", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 234, 234), // Set background color if needed
                foregroundColor: AppColors.primaryColor, // Set text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            ],
          ),
        );
      },
    );
  }
}
