import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_card.dart';
import '../../widgets/theme_mode_selector.dart';
import '../../widgets/department_nav_bar.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsProvider = context.watch<ProductsProvider>();
    final appState = context.watch<AppStateProvider>();
    final filtered = productsProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CATALOGUE'),
        actions: [
          // 3-Mode Theme Selector: Light (Alabaster), Dark (Obsidian), Automatic (System)
          AtelierThemeModeSelector(appState: appState, isDark: isDark),
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, size: 22),
            onPressed: () => _showSortBottomSheet(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Carnage-Style Department Navigation Bar (WOMEN, MEN, ACCESSORIES, LAST CHANCE, ALL)
          const DepartmentNavBar(),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                productsProvider.setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search coats, silk, linen, suits...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          productsProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Categories Horizontal Bar
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: productsProvider.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = productsProvider.categories[index];
                final isSelected =
                    productsProvider.selectedCategory == category.name;
                return CategoryPill(
                  title: category.name,
                  icon: category.icon,
                  isSelected: isSelected,
                  onTap: () {
                    productsProvider.selectCategory(category.name);
                  },
                );
              },
            ),
          ),

          // Filter Summary & Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'PIECE' : 'PIECES'} AVAILABLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                if (productsProvider.selectedCategory != 'All' ||
                    productsProvider.searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      productsProvider.setSearchQuery('');
                      productsProvider.selectCategory('All');
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC29B38),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: productsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.58,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          return ProductCard(product: filtered[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching apparel found',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or category filter',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final provider = context.read<ProductsProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Collection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSortTile(
                  context,
                  title: 'Featured & Editorial',
                  option: ProductSortOption.featured,
                  current: provider.sortOption,
                ),
                _buildSortTile(
                  context,
                  title: 'Newest Additions',
                  option: ProductSortOption.newest,
                  current: provider.sortOption,
                ),
                _buildSortTile(
                  context,
                  title: 'Price: Low to High',
                  option: ProductSortOption.priceLowToHigh,
                  current: provider.sortOption,
                ),
                _buildSortTile(
                  context,
                  title: 'Price: High to Low',
                  option: ProductSortOption.priceHighToLow,
                  current: provider.sortOption,
                ),
                _buildSortTile(
                  context,
                  title: 'Highest Rated',
                  option: ProductSortOption.rating,
                  current: provider.sortOption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(
    BuildContext context, {
    required String title,
    required ProductSortOption option,
    required ProductSortOption current,
  }) {
    final isSelected = option == current;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFC29B38) : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFFC29B38))
          : null,
      onTap: () {
        context.read<ProductsProvider>().setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = context.watch<ProductsProvider>();
            var range = provider.priceRange;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Options',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.setPriceRange(const RangeValues(50, 600));
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Price Range: LKR ${range.start.round()} - LKR ${range.end.round()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    RangeSlider(
                      values: range,
                      min: 50,
                      max: 600,
                      divisions: 11,
                      activeColor: const Color(0xFFC29B38),
                      labels: RangeLabels(
                        'LKR ${range.start.round()}',
                        'LKR ${range.end.round()}',
                      ),
                      onChanged: (newRange) {
                        provider.setPriceRange(newRange);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
