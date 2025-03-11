import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../design/colors.dart';
import '../services/items_api.dart';

final Logger log = Logger();

class DashboardScreen extends StatefulWidget {
  final int empId;
  final int currentDptId;

  const DashboardScreen(
      {super.key, required this.empId, required this.currentDptId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final ItemsApi _itemsApi = ItemsApi();
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    log.i("Fetching items for emp_id: ${widget.empId}");
    try {
      final items = await _itemsApi.fetchItems(widget.empId);
      if (mounted) {
        setState(() {
          _items = items;
          _filteredItems = items;
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

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        return item['name'].toString().toLowerCase().contains(query) ||
            item['description'].toString().toLowerCase().contains(query) ||
            item['serial_no'].toString().toLowerCase().contains(query);
      }).toList();
      _currentPage = 0;
    });
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredItems.sublist(
        startIndex, endIndex.clamp(0, _filteredItems.length));
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredItems.length) {
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
    int totalPages = (_filteredItems.length / _itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: RefreshIndicator(
  onRefresh: _loadItems,
  child: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                '⚠ $_errorMessage',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Items',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 3),
                      ),
                    ),
                    onChanged: (value) => _filterItems(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 0 ? _previousPage : null,
                    ),
                    Text("Page ${_currentPage + 1} of $totalPages"),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: (_currentPage + 1) * _itemsPerPage <
                              _filteredItems.length
                          ? _nextPage
                          : null,
                    ),
                  ],
                ),
                Expanded(
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0), // Add padding here
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(
                color: AppColors.primaryColor, width: 1.5),
            dataRowMinHeight: 40,
            dataRowMaxHeight: 40,
            headingRowColor: WidgetStateColor.resolveWith(
              (states) => AppColors.primaryColor,
            ),
            headingRowHeight: 40,
            columns: const [
              DataColumn(
                  label: Center(child: Text('Name',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Description',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Available Quantity',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Original Quantity',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('ICS',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('ARE No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Prop No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Serial No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Unit Value',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Total Value',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
              DataColumn(
                  label: Center(child: Text('Remarks',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
            ],
            rows: _paginatedItems.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['name']?.toString() ?? 'N/A')),
                DataCell(Text(item['description']?.toString() ?? 'N/A')),
                DataCell(Text(item['quantity']?.toString() ?? 'N/A')),
                DataCell(Text(item['ORIGINAL_QUANTITY']?.toString() ?? 'N/A')),
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
      ),
    ],
  ),
),

              ],
            ),
),

    );
  }
}
