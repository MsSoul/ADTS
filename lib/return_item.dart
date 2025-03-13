import 'package:flutter/material.dart';

class ReturnItemScreen extends StatelessWidget {
  final int empId;
  final int currentDptId;

  const ReturnItemScreen({super.key, required this.empId, required this.currentDptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Return Item"),
      ),
      body: Center(
        child: Text("Return item screen for empId: $empId, Dept: $currentDptId"),
      ),
    );
  }
}
