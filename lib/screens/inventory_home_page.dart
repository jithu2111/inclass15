import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/user_role.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'add_edit_item_screen.dart';
import 'login_screen.dart';

class InventoryHomePage extends StatefulWidget {
  InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  UserRole? _userRole;
  String? _displayName;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStockStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final role = await _authService.getUserRole();
    final name = await _authService.getDisplayName();
    if (mounted) {
      setState(() {
        _userRole = role;
        _displayName = name;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      // Navigate directly to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Get stock status for an item
  String _getStockStatus(Item item) {
    if (item.quantity == 0) return 'Out of Stock';
    if (item.quantity <= 10) return 'Low Stock';
    return 'In Stock';
  }

  // Get unique categories from items
  List<String> _getCategories(List<Item> items) {
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedStockStatus = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userRole != null
              ? 'Inventory (${_userRole!.displayName})'
              : 'Inventory Management',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_displayName != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  _displayName!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Filters Section
          StreamBuilder<List<Item>>(
            stream: _firestoreService.getItemsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final allItems = snapshot.data!;
              final categories = _getCategories(allItems);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters Row
                    Row(
                      children: [
                        // Category Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Clear Filters Button
                        if (_selectedCategory != 'All' ||
                            _selectedStockStatus != 'All' ||
                            _searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.filter_alt_off),
                            onPressed: _clearFilters,
                            tooltip: 'Clear Filters',
                            color: Colors.red,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stock Status Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text(
                            'Stock: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedStockStatus == 'All',
                            onSelected: (selected) {
                              setState(() {
                                _selectedStockStatus = 'All';
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('In Stock'),
                            selected: _selectedStockStatus == 'In Stock',
                            onSelected: (selected) {
                              setState(() {
                                _selectedStockStatus = 'In Stock';
                              });
                            },
                            selectedColor: Colors.green[100],
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Low Stock'),
                            selected: _selectedStockStatus == 'Low Stock',
                            onSelected: (selected) {
                              setState(() {
                                _selectedStockStatus = 'Low Stock';
                              });
                            },
                            selectedColor: Colors.orange[100],
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Out of Stock'),
                            selected: _selectedStockStatus == 'Out of Stock',
                            onSelected: (selected) {
                              setState(() {
                                _selectedStockStatus = 'Out of Stock';
                              });
                            },
                            selectedColor: Colors.red[100],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),

          // Item List
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _firestoreService.getItemsStream(),
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Handle error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Handle empty state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in inventory',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter items based on search query, category, and stock status
                final allItems = snapshot.data!;
                final filteredItems = allItems.where((item) {
                  // Search filter
                  final matchesSearch = _searchQuery.isEmpty ||
                      item.name.toLowerCase().contains(_searchQuery) ||
                      item.category.toLowerCase().contains(_searchQuery);

                  // Category filter
                  final matchesCategory = _selectedCategory == 'All' ||
                      item.category == _selectedCategory;

                  // Stock status filter
                  final itemStockStatus = _getStockStatus(item);
                  final matchesStockStatus = _selectedStockStatus == 'All' ||
                      itemStockStatus == _selectedStockStatus;

                  return matchesSearch && matchesCategory && matchesStockStatus;
                }).toList();

                // Show "no results" if filtered list is empty
                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Build ListView with filtered item data
                return ListView.builder(
                  itemCount: filteredItems.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Category: ${item.category}'),
                            Text(
                              'Quantity: ${item.quantity} | Price: \$${item.price.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: _userRole?.canEdit == true
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditItemScreen(item: item),
                                  ),
                                );
                              }
                            : null,
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _userRole?.canCreate == true
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditItemScreen(),
                  ),
                );
              },
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}