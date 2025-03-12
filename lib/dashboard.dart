import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../design/colors.dart';
import '../services/items_api.dart';
import 'dashboard_table.dart';

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
  List<Map<String, dynamic>> _borrowedItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final ItemsApi _itemsApi = ItemsApi();
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";

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
    final borrowedItems = await _itemsApi.fetchBorrowedItems(widget.empId);

    log.d("📦 Owned Items: $items");
    log.d("📦 Borrowed Items: $borrowedItems");

    if (mounted) {
      setState(() {
        _items = items;
        _borrowedItems = borrowedItems;
        _filteredItems = [...items, ...borrowedItems];
        _isLoading = false;
      });
    }
    log.i("✅ Successfully loaded ${items.length} owned items.");
    log.i("✅ Successfully loaded ${borrowedItems.length} borrowed items.");
  } catch (e, stacktrace) {
    log.e("❌ Error loading items: $e", error: e, stackTrace: stacktrace);
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
      List<Map<String, dynamic>> itemsToFilter = [];

      if (_selectedFilter == "All") {
        itemsToFilter = [..._items, ..._borrowedItems];
      } else if (_selectedFilter == "Owned") {
        itemsToFilter = _items;
      } else if (_selectedFilter == "Borrowed") {
        itemsToFilter = _borrowedItems;
      }
      _filteredItems = itemsToFilter.where((item) {
        final queryLower = query.toLowerCase();

        return item.values.any((value) =>
            value != null &&
            value.toString().toLowerCase().contains(queryLower));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Items',
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.primaryColor),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) => _filterItems(),
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              items: ["All", "Owned", "Borrowed"].map((filter) {
                                return DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter,
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilter = value!;
                                  _filterItems();
                                });
                              },
                              dropdownColor: AppColors.primaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed:
                                    _currentPage > 0 ? _previousPage : null,
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
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DashboardTable(
                                items: _paginatedItems,
                                selectedFilter:
                                    _selectedFilter, // Pass selected filter
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
