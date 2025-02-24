import 'package:flutter/material.dart';

class BorrowItemsScreen extends StatelessWidget {
  const BorrowItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the Borrow Items Section!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here, you can browse and request items to borrow. Please follow the instructions below:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Example instructions (replace with your actual instructions)
            const Text(
              '1. Browse the available items.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '2. Select the item you wish to borrow.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '3. Fill out the borrow request form.',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              '4. Wait for approval from the item owner.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Add your item list and borrow request functionality here
            Expanded(
              child: ListView(
                children: [
                  // Example item cards (replace with your actual item data)
                  _buildItemCard(
                    context: context,
                    itemName: 'Drill',
                    itemDescription: 'A powerful drill for your home projects.',
                    onTap: () {
                      // Navigate to item details or borrow request page
                      _showBorrowRequestDialog(context, 'Drill');
                    },
                  ),
                  _buildItemCard(
                    context: context,
                    itemName: 'Ladder',
                    itemDescription: 'A sturdy ladder for reaching high places.',
                    onTap: () {
                      _showBorrowRequestDialog(context, 'Ladder');
                    },
                  ),
                  // Add more item cards...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required BuildContext context,
    required String itemName,
    required String itemDescription,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(itemName),
        subtitle: Text(itemDescription),
        onTap: onTap,
      ),
    );
  }

  void _showBorrowRequestDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Borrow Request: $itemName'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter details for your borrow request:'),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Borrow Date'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Return Date'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Reason for Borrowing'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Borrow request submitted!')),
                );
              },
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );
  }
}