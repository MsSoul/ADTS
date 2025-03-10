import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../design/colors.dart';
import '../services/items_api.dart';

final Logger log = Logger();

class DashboardScreen extends StatefulWidget {
  final int empId;
  final int currentDptId;

  const DashboardScreen({super.key, required this.empId, required this.currentDptId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final ItemsApi _itemsApi = ItemsApi();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    log.i("Fetching items for emp_id: ${widget.empId}");
    try {
      final items = await _itemsApi.fetchItems(widget.empId);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
      log.i("Successfully loaded ${items.length} items.");
    } catch (e, stacktrace) {
      log.e("Error loading items: $e", error: e, stackTrace: stacktrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error fetching items. Please check your connection.";
        });
      }
    }
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _items.sublist(startIndex, endIndex.clamp(0, _items.length));
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _items.length) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: RefreshIndicator(
      onRefresh: _loadItems,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Text(
                      'Welcome to your Dashboard!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 0 ? _previousPage : null,
                        ),
                        Text("Page ${_currentPage + 1} of ${( (_items.length / _itemsPerPage).ceil())}"),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: (_currentPage + 1) * _itemsPerPage < _items.length ? _nextPage : null,
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(color: AppColors.primaryColor, width: 1.5),
                        dataRowMinHeight: 40, 
                        dataRowMaxHeight: 40,
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.primaryColor,
                        ),
                        headingRowHeight: 40,
                        columns: const [
                          DataColumn(label: Center(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('ICS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('ARE No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Prop No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Serial No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Unit Value', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Total Value', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                        ],
                        rows: _paginatedItems.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item['name']?.toString() ?? 'N/A')),
                            DataCell(Text(item['description']?.toString() ?? 'N/A')),
                            DataCell(Text(item['quantity']?.toString() ?? 'N/A')),
                            DataCell(Text(item['ics']?.toString() ?? 'N/A')),
                            DataCell(Text(item['are_no']?.toString() ?? 'N/A')),
                            DataCell(Text(item['prop_no']?.toString() ?? 'N/A')),
                            DataCell(Text(item['serial_no']?.toString() ?? 'N/A')),
                            DataCell(Text('₱ ${(item['unit_value'] ?? 0.0).toStringAsFixed(2)}')),
                            DataCell(Text('₱ ${(item['total_value'] ?? 0.0).toStringAsFixed(2)}')),
                            DataCell(Text(item['remarks']?.toString() ?? 'N/A')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    ),
  );
}

}
