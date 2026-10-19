import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/theme_mode_selector.dart';
import '../../widgets/department_nav_bar.dart';
import '../../widgets/department_explore_banner.dart';
import '../../models/category.dart';
import '../cart/cart_screen.dart';
import '../auth/login_screen.dart';
import '../chatbot/atelier_chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToShop;

  const HomeScreen({
    super.key,
    required this.onNavigateToShop,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();

    final isSearching = productsProvider.searchQuery.trim().isNotEmpty;
    final isFiltered = productsProvider.selectedCategory != 'All' || isSearching;
    final displayProducts = productsProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'N U A N C E',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.0,
          ),
        ),
        actions: [
          // 3-Mode Theme Selector: Light (Alabaster), Dark (Obsidian), Automatic (System)
          AtelierThemeModeSelector(appState: appState, isDark: isDark),
          const SizedBox(width: 4),

          // Logout / Sign In Button
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 21),
              tooltip: 'Sign Out (${authProvider.user?.displayName})',
              onPressed: () => _confirmSignOut(context, authProvider),
            )
          else
            IconButton(
              icon: const Icon(Icons.login_rounded, size: 21),
              tooltip: 'Sign In / Register',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),

          // Shopping Bag with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC29B38),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartProvider.itemCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productsProvider.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carnage-Style Department Navigation Bar (WOMEN, MEN, ACCESSORIES, LAST CHANCE, ALL)
              const DepartmentNavBar(),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    productsProvider.setSearchQuery(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search collection (coats, suits, linen, silk)...',
                    hintStyle: const TextStyle(fontSize: 13),
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

              // Department Visual Explore Banner (Carnage Style)
              const DepartmentExploreBanner(),

              const SizedBox(height: 4),

              // Category Filter Bar
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
                      isSelected: isSelected,
                      icon: category.name == 'All' ? Icons.apps_rounded : null,
                      onTap: () {
                        productsProvider.selectCategory(category.name);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Loading Indicator
              if (productsProvider.isLoading) ...[
                const SizedBox(height: 80),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2.5),
                      SizedBox(height: 16),
                      Text(
                        'Loading luxury pieces...',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ] else if (isFiltered) ...[
                // Filtered Results Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${displayProducts.length} ${displayProducts.length == 1 ? 'PIECE' : 'PIECES'} FOUND',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          productsProvider.setSearchQuery('');
                          productsProvider.selectCategory('All');
                        },
                        child: const Text(
                          'Reset Filter',
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

                // Filtered Products Grid
                if (displayProducts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No garments match your search', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: displayProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: displayProducts[index]);
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ] else ...[
                // Hero Editorial Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: widget.onNavigateToShop,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const CustomImage(
                              imagePath: 'assets/images/hero_banner.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC29B38),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIMITED EDITION',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Autumn / Winter 2024',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Text(
                                      'Discover Minimal Tailoring',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFFC29B38)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Atelier Categories Visual Section
                SectionHeader(
                  title: 'Atelier Categories',
                  subtitle: 'Curated silhouettes, bespoke tailoring & couture',
                  actionText: 'All Pieces',
                  onActionTap: () {
                    productsProvider.selectCategory('All');
                    widget.onNavigateToShop();
                  },
                ),
                SizedBox(
                  height: 135,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: productsProvider.categories.where((c) => c.name != 'All').length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = productsProvider.categories.where((c) => c.name != 'All').toList()[index];
                      final count = productsProvider.products.where((p) => p.category.toLowerCase() == category.name.toLowerCase()).length;
                      return _buildCategoryShowcaseCard(context, category, count, productsProvider, isDark);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // New Arrivals Horizontal Section
                SectionHeader(
                  title: 'New Arrivals',
                  subtitle: 'Fresh silhouettes from our atelier',
                  actionText: 'Explore',
                  onActionTap: widget.onNavigateToShop,
                ),

                SizedBox(
                  height: 315,
                  child: productsProvider.newArrivals.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: productsProvider.newArrivals.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final product = productsProvider.newArrivals[index];
                            return SizedBox(
                              width: 175,
                              child: ProductCard(product: product),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Promotional Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E22) : const Color(0xFF18181A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC29B38).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            color: Color(0xFFC29B38),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'WELCOME PRIVILEGE',
                                style: TextStyle(
                                  color: Color(0xFFC29B38),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Use code NUANCE10 for 10% off',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Stylist Concierge Feature Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1E28), const Color(0xFF14141A)]
                            : [const Color(0xFF23232B), const Color(0xFF111115)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFC29B38).withValues(alpha: 0.45),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC29B38).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC29B38), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'NUANCE AI WARDROBE STYLIST',
                              style: TextStyle(
                                color: Color(0xFFC29B38),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Unsure What to Wear? Let Our AI Curate It',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Share your upcoming event, preferred fabrics, or aesthetic opinions. Our AI stylist will instantly generate personalized garment pairings.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AtelierChatbotScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC29B38),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('Consult AI Stylist Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Curated Essentials
                SectionHeader(
                  title: 'Curated Essentials',
                  subtitle: 'Seasonal highlights and timeless tailoring',
                  actionText: 'View All',
                  onActionTap: widget.onNavigateToShop,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: productsProvider.featuredProducts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: productsProvider.featuredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemBuilder: (context, index) {
                            final product = productsProvider.featuredProducts[index];
                            return ProductCard(product: product);
                          },
                        ),
                ),

                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AtelierChatbotScreen()),
          );
        },
        backgroundColor: const Color(0xFF141418),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFC29B38), width: 1.5),
        ),
        icon: Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFC29B38), Color(0xFFF3E5AB)],
            ),
          ),
          child: const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.black),
        ),
        label: const Text(
          'AI Stylist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.signOut();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShowcaseCard(
    BuildContext context,
    CategoryItem category,
    int count,
    ProductsProvider productsProvider,
    bool isDark,
  ) {
    final isSelected = productsProvider.selectedCategory == category.name;
    return GestureDetector(
      onTap: () {
        productsProvider.selectCategory(category.name);
        widget.onNavigateToShop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC29B38)
                : (isDark ? const Color(0xFF2C2C32) : const Color(0xFFE5E5EA)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomImage(
                imagePath: category.image.isNotEmpty ? category.image : 'assets/images/hero_banner.jpg',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC29B38).withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    size: 14,
                    color: const Color(0xFFC29B38),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC29B38).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$count ${count == 1 ? 'PIECE' : 'PIECES'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
