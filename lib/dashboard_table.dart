import 'package:flutter/material.dart';
import '../design/colors.dart';

class DashboardTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String selectedFilter; // Added parameter

  const DashboardTable({
    super.key,
    required this.items,
    required this.selectedFilter, // Required in constructor
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: AppColors.primaryColor, width: 1.5),
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        headingRowColor:
            WidgetStateColor.resolveWith((states) => AppColors.primaryColor),
        columns: const [
          DataColumn(label: Center(child: Text('Name', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('Description', style: _headerStyle))),
          DataColumn(
              label: Center(
                  child: Text('Available Quantity', style: _headerStyle))),
          DataColumn(
              label: Center(
                  child: Text('Original Quantity', style: _headerStyle))),
          DataColumn(label: Center(child: Text('ICS', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('ARE No.', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('Prop No.', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('Serial No.', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('Unit Value', style: _headerStyle))),
          DataColumn(
              label: Center(child: Text('Total Value', style: _headerStyle))),
          DataColumn(
              label: Center(
                  child:
                      Text('Remarks', style: _headerStyle))), // Remarks updated
        ],
        rows: items.map((item) {
          String remarks = item['remarks'] ?? '';

          // If filter is "Borrowed", show owner's name in Remarks
          if (selectedFilter == "Borrowed") {
            remarks = item['owner_name'] ?? 'Unknown Owner';
          }

          return DataRow(cells: [
            DataCell(Text(item['name']?.toString() ?? 'N/A')),
            DataCell(Text(item['description']?.toString() ?? 'N/A')),
            DataCell(Text(item['quantity']?.toString() ?? 'N/A')),
            DataCell(Text(item['ORIGINAL_QUANTITY']?.toString() ?? 'N/A')),
            DataCell(Text(item['ics']?.toString() ?? 'N/A')),
            DataCell(Text(item['are_no']?.toString() ?? 'N/A')),
            DataCell(Text(item['prop_no']?.toString() ?? 'N/A')),
            DataCell(Text(item['serial_no']?.toString() ?? 'N/A')),
            DataCell(
                Text('₱ ${(item['unit_value'] ?? 0.0).toStringAsFixed(2)}')),
            DataCell(
                Text('₱ ${(item['total_value'] ?? 0.0).toStringAsFixed(2)}')),
            DataCell(
                Text(remarks)), // Updated to display owner's name if borrowed
          ]);
        }).toList(),
      ),
    );
  }

  // Define a TextStyle for column headers
  static const TextStyle _headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
