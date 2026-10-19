import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_state.dart';
import '../../providers/products_provider.dart';
import '../../widgets/custom_image.dart';
import '../auth/login_screen.dart';
import '../main_nav_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _orderSearchQuery = '';
  String _orderStatusFilter = 'All';
  String _productSearchQuery = '';

  static const List<ProductColor> _presetAtelierColors = [
    ProductColor(name: 'Obsidian Black', colorValue: 0xFF1C1C1C),
    ProductColor(name: 'Champagne Gold', colorValue: 0xFFC29B38),
    ProductColor(name: 'Chalk White', colorValue: 0xFFF5F5F0),
    ProductColor(name: 'Midnight Navy', colorValue: 0xFF1B263B),
    ProductColor(name: 'Olive Sage', colorValue: 0xFF556B2F),
    ProductColor(name: 'Burgundy Wine', colorValue: 0xFF722F37),
    ProductColor(name: 'Camel Tan', colorValue: 0xFFC19A6B),
    ProductColor(name: 'Charcoal Grey', colorValue: 0xFF36454F),
    ProductColor(name: 'Dusty Rose', colorValue: 0xFFDCAE96),
    ProductColor(name: 'Forest Emerald', colorValue: 0xFF1B4D3E),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final appState = context.watch<AppStateProvider>();
    final isDark = appState.isDarkTheme(context);

    final bgColor = isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F6F9);
    final appBarColor = isDark ? const Color(0xFF16161B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textColor = isDark ? Colors.white : const Color(0xFF121217);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF4A4A55);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC29B38),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'NUANCE ATELIER HUB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Mode Selector (Dark Mode / Light Mode / Automatic Option)
          PopupMenuButton<ThemeMode>(
            tooltip: 'Aesthetic Theme Mode (Light / Dark / Auto)',
            icon: Icon(
              appState.themeMode == ThemeMode.light
                  ? Icons.light_mode_rounded
                  : (appState.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.brightness_auto_rounded),
              color: const Color(0xFFC29B38),
            ),
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor),
            ),
            onSelected: (ThemeMode mode) {
              appState.setThemeMode(mode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode_rounded, size: 18, color: Color(0xFFC29B38)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Light Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (appState.themeMode == ThemeMode.light)
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded, size: 18, color: Color(0xFFC29B38)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (appState.themeMode == ThemeMode.dark)
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto_rounded, size: 18, color: Color(0xFFC29B38)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatic (System)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (appState.themeMode == ThemeMode.system)
                      const Icon(Icons.check_rounded, size: 16, color: Color(0xFFC29B38)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),

          // Cloud Live Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Cloud Firestore Live',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: subTextColor),
            tooltip: 'Sync Firestore',
            onPressed: () => admin.fetchAllData(),
          ),

          // Exit to Storefront
          IconButton(
            icon: const Icon(Icons.storefront_rounded, color: Color(0xFFC29B38)),
            tooltip: 'Return to Boutique',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Admin Logout',
            onPressed: () {
              admin.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC29B38),
          labelColor: const Color(0xFFC29B38),
          unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF777785),
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
          tabs: [
            Tab(
              icon: const Icon(Icons.analytics_outlined, size: 18),
              text: 'OVERVIEW (${admin.totalOrdersCount})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              text: 'ORDERS (${admin.totalOrdersCount})',
            ),
            Tab(
              icon: const Icon(Icons.checkroom_rounded, size: 18),
              text: 'CATALOG (${admin.totalProductsCount})',
            ),
            Tab(
              icon: const Icon(Icons.people_alt_outlined, size: 18),
              text: 'CLIENTS (${admin.totalCustomersCount})',
            ),
          ],
        ),
      ),
      body: admin.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC29B38)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, admin, isDark),
                _buildOrdersTab(context, admin, isDark),
                _buildCatalogTab(context, admin, isDark),
                _buildClientsTab(context, admin, isDark),
              ],
            ),
    );
  }

  // ===========================================================================
  // 1. OVERVIEW & ANALYTICS TAB
  // ===========================================================================

  Widget _buildOverviewTab(BuildContext context, AdminProvider admin, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENTERPRISE METRICS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Color(0xFFC29B38),
            ),
          ),
          const SizedBox(height: 12),

          // 4 KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _buildKpiCard(
                    title: 'GROSS REVENUE',
                    value: 'LKR ${admin.totalRevenue.toStringAsFixed(2)}',
                    subtext: 'From verified orders',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFFC29B38),
                    width: isWide ? (constraints.maxWidth - 42) / 4 : (constraints.maxWidth - 14) / 2,
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    title: 'TOTAL ORDERS',
                    value: '${admin.totalOrdersCount}',
                    subtext: '${admin.pendingOrdersCount} pending fulfillment',
                    icon: Icons.local_mall_outlined,
                    color: Colors.blueAccent,
                    width: isWide ? (constraints.maxWidth - 42) / 4 : (constraints.maxWidth - 14) / 2,
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    title: 'ACTIVE CATALOG',
                    value: '${admin.totalProductsCount}',
                    subtext: 'Luxury bespoke pieces',
                    icon: Icons.checkroom_rounded,
                    color: Colors.purpleAccent,
                    width: isWide ? (constraints.maxWidth - 42) / 4 : (constraints.maxWidth - 14) / 2,
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    title: 'REGISTERED CLIENTS',
                    value: '${admin.totalCustomersCount}',
                    subtext: 'Synced from Firestore',
                    icon: Icons.people_outline_rounded,
                    color: Colors.tealAccent,
                    width: isWide ? (constraints.maxWidth - 42) / 4 : (constraints.maxWidth - 14) / 2,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QUICK DISPATCH QUEUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFFC29B38),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFFC29B38)),
                label: const Text(
                  'Add New Garment',
                  style: TextStyle(color: Color(0xFFC29B38), fontWeight: FontWeight.w700, fontSize: 12),
                ),
                onPressed: () => _showAddProductDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recent Orders Feed
          if (admin.orders.isEmpty)
            _buildEmptyCard('No orders received yet. Test by placing an order in the boutique!')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: admin.orders.take(5).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = admin.orders[index];
                return _buildOrderRow(context, order, admin, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required double width,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF18181E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textCol = isDark ? Colors.white : const Color(0xFF121217);
    final subTextCol = isDark ? Colors.white38 : const Color(0xFF888899);

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white54 : const Color(0xFF777785),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textCol,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11,
              color: subTextCol,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. ORDERS MANAGEMENT TAB
  // ===========================================================================

  Widget _buildOrdersTab(BuildContext context, AdminProvider admin, bool isDark) {
    var filtered = admin.orders;

    if (_orderStatusFilter != 'All') {
      if (_orderStatusFilter == 'Completed' || _orderStatusFilter == 'Delivered') {
        filtered = filtered.where((o) => o.status == OrderStatus.delivered).toList();
      } else {
        filtered = filtered.where((o) => o.status.name.toLowerCase() == _orderStatusFilter.toLowerCase()).toList();
      }
    }

    if (_orderSearchQuery.trim().isNotEmpty) {
      final q = _orderSearchQuery.trim().toLowerCase();
      filtered = filtered.where((o) {
        final cust = admin.customers.firstWhere(
          (c) => c.id == o.userId,
          orElse: () => UserModel(id: o.userId, email: '', displayName: ''),
        );
        final custName = o.customerName.isNotEmpty ? o.customerName : cust.displayName;
        return o.id.toLowerCase().contains(q) ||
            o.shippingAddress.toLowerCase().contains(q) ||
            o.phoneNumber.contains(q) ||
            o.userId.toLowerCase().contains(q) ||
            custName.toLowerCase().contains(q);
      }).toList();
    }

    final headerBg = isDark ? const Color(0xFF141418) : Colors.white;
    final inputFill = isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F3F7);
    final borderColor = isDark ? const Color(0xFF2A2A32) : const Color(0xFFE2E2EA);
    final chipBg = isDark ? const Color(0xFF1E1E24) : const Color(0xFFEEEEF3);

    return Column(
      children: [
        // Filter & Search Controls
        Container(
          padding: const EdgeInsets.all(16),
          color: headerBg,
          child: Column(
            children: [
              TextField(
                onChanged: (val) {
                  setState(() {
                    _orderSearchQuery = val;
                  });
                },
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121217), fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search by Client Name, Order ID, Phone, or Shipping Destination...',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : const Color(0xFF9999AA), fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : const Color(0xFF777785), size: 20),
                  filled: true,
                  fillColor: inputFill,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Placed',
                    'Processing',
                    'Shipped',
                    'Completed',
                    'Cancelled',
                  ].map((status) {
                    final isSel = _orderStatusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSel,
                        selectedColor: const Color(0xFFC29B38),
                        backgroundColor: chipBg,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF4A4A55)),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFC29B38) : borderColor,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _orderStatusFilter = status;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyCard('No orders match your filter criteria.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final isDelivered = order.status == OrderStatus.delivered;
                    final isInAllTab = _orderStatusFilter == 'All';

                    // In "All" tab: after the customer gets the order (delivered), only show compact summary row with customer name
                    if (isInAllTab && isDelivered) {
                      return _buildCompactCompletedOrderRow(context, order, admin, isDark);
                    }

                    // In Completed tab or for active orders: show full comprehensive details
                    return _buildOrderRow(context, order, admin, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactCompletedOrderRow(
    BuildContext context,
    OrderModel order,
    AdminProvider admin,
    bool isDark,
  ) {
    final customer = admin.customers.firstWhere(
      (c) => c.id == order.userId,
      orElse: () => UserModel(id: order.userId, email: '', displayName: ''),
    );
    final clientName = order.customerName.isNotEmpty
        ? order.customerName
        : (customer.displayName.isNotEmpty ? customer.displayName : 'Valued Client');

    final cardBg = isDark ? const Color(0xFF18181E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textCol = isDark ? Colors.white : const Color(0xFF121217);
    final mutedTextCol = isDark ? Colors.white38 : const Color(0xFF8E8E9B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: isDark ? 0.15 : 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        clientName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textCol,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'DELIVERED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC29B38),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  ${DateFormat('MMM d, yyyy').format(order.createdAt)}',
                      style: TextStyle(fontSize: 11, color: mutedTextCol),
                    ),
                    if (order.phoneNumber.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•  ${order.phoneNumber}',
                        style: TextStyle(fontSize: 11, color: mutedTextCol),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LKR ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC29B38),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    _orderStatusFilter = 'Completed';
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Completed Tab',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : const Color(0xFF555562),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: isDark ? Colors.white60 : const Color(0xFF555562),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(BuildContext context, OrderModel order, AdminProvider admin, bool isDark) {
    final customer = admin.customers.firstWhere(
      (c) => c.id == order.userId,
      orElse: () => UserModel(id: order.userId, email: '', displayName: ''),
    );
    final clientName = order.customerName.isNotEmpty
        ? order.customerName
        : (customer.displayName.isNotEmpty ? customer.displayName : 'Valued Client');

    final cardBg = isDark ? const Color(0xFF18181E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textCol = isDark ? Colors.white : const Color(0xFF121217);
    final subTextCol = isDark ? Colors.white70 : const Color(0xFF4A4A55);
    final mutedTextCol = isDark ? Colors.white38 : const Color(0xFF8E8E9B);
    final innerBoxBg = isDark ? const Color(0xFF131317) : const Color(0xFFF7F7FA);
    final innerBorder = isDark ? const Color(0xFF282832) : const Color(0xFFE4E4EC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID, Client Name & Status Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textCol,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${order.id})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC29B38),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.paymentMethod,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC29B38),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt),
                      style: TextStyle(fontSize: 11, color: mutedTextCol),
                    ),
                  ],
                ),
              ),

              // Interactive Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF24242C) : const Color(0xFFF1F1F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF33333E) : const Color(0xFFDBDBE5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<OrderStatus>(
                    value: order.status,
                    dropdownColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
                    style: TextStyle(color: textCol, fontSize: 11, fontWeight: FontWeight.w700),
                    items: OrderStatus.values.map((status) {
                      return DropdownMenuItem<OrderStatus>(
                        value: status,
                        child: Text(
                          status.displayName.toUpperCase(),
                          style: TextStyle(
                            color: status == OrderStatus.delivered
                                ? Colors.green
                                : status == OrderStatus.shipped
                                    ? Colors.purpleAccent
                                    : const Color(0xFFC29B38),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        admin.updateOrderStatus(order.id, newStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order ${order.id} status updated to ${newStatus.displayName}.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: borderColor),

          // Recipient Phone & Shipping Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFC29B38), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Standard Atelier Address',
                  style: TextStyle(fontSize: 12, color: subTextCol, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.phone_outlined, color: Color(0xFFC29B38), size: 16),
              const SizedBox(width: 6),
              Text(
                order.phoneNumber.isNotEmpty ? order.phoneNumber : 'No phone listed',
                style: TextStyle(fontSize: 12, color: subTextCol, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Courier Service & Contact Information Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: innerBoxBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: innerBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Color(0xFFC29B38), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.courierName.isNotEmpty ? order.courierName : 'Nuance White Glove Express',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textCol,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (order.trackingNumber.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.trackingNumber,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: subTextCol,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.support_agent_rounded, size: 13, color: Color(0xFFC29B38)),
                          const SizedBox(width: 4),
                          Text(
                            order.courierPhone.isNotEmpty ? order.courierPhone : '+1 (800) 555-0199',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF666675), fontWeight: FontWeight.w500),
                          ),
                          if (order.deliveryNotes.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: mutedTextCol, fontSize: 10)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.deliveryNotes,
                                style: TextStyle(fontSize: 10, color: mutedTextCol, fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditOrderCourierDialog(context, order),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF22222A) : const Color(0xFFEAEAEE),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: innerBorder),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFC29B38)),
                  label: const Text(
                    'Edit Details',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC29B38),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Items Preview
          if (order.items.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: innerBoxBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: innerBorder),
              ),
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 34,
                            height: 40,
                            child: CustomImage(imagePath: item.product.mainImage, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.quantity}× ${item.product.name} (Size: ${item.selectedSize}, Color: ${item.selectedColor.name})',
                            style: TextStyle(fontSize: 11, color: subTextCol),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'LKR ${item.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textCol),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer with Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Client ID: ${order.userId}',
                style: TextStyle(fontSize: 10, color: mutedTextCol),
              ),
              Text(
                'Total: LKR ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC29B38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. CATALOG MANAGEMENT TAB
  // ===========================================================================

  Widget _buildCatalogTab(BuildContext context, AdminProvider admin, bool isDark) {
    var filtered = admin.products;

    if (_productSearchQuery.trim().isNotEmpty) {
      final q = _productSearchQuery.trim().toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
    }

    final headerBg = isDark ? const Color(0xFF141418) : Colors.white;
    final inputFill = isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F3F7);
    final borderCol = isDark ? const Color(0xFF2A2A32) : const Color(0xFFE2E2EA);

    return Column(
      children: [
        // Header Controls
        Container(
          padding: const EdgeInsets.all(16),
          color: headerBg,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _productSearchQuery = val;
                    });
                  },
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121217), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or category...',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : const Color(0xFF9999AA), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : const Color(0xFF777785), size: 20),
                    filled: true,
                    fillColor: inputFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderCol),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderCol),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Piece'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC29B38),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showAddProductDialog(context),
              ),
            ],
          ),
        ),

        // Product Cards
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyCard('No products found.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _buildProductRow(context, product, admin, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductRow(BuildContext context, Product product, AdminProvider admin, bool isDark) {
    final hasLowStock = product.stockCount > 0 && product.stockCount <= 5;
    final isOutOfStock = !product.inStock || product.stockCount <= 0;

    final cardBg = isDark ? const Color(0xFF18181E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textCol = isDark ? Colors.white : const Color(0xFF121217);
    final subTextCol = isDark ? Colors.white54 : const Color(0xFF666675);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 74,
              child: CustomImage(imagePath: product.mainImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.department.toUpperCase()} • ${product.category.toUpperCase()}',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFFC29B38)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Out of Stock', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                      )
                    else if (hasLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Low Stock (${product.stockCount} left)', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.orangeAccent)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${product.stockCount} in stock', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.greenAccent)),
                      ),
                    if (product.sku.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF888899), fontFamily: 'monospace'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textCol),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'LKR ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFC29B38)),
                    ),
                    if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        'LKR ${product.originalPrice!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : const Color(0xFF888899),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      'Sizes: ${product.sizes.join(", ")}',
                      style: TextStyle(fontSize: 10, color: subTextCol),
                    ),
                    if (product.colors.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: product.colors.take(3).map((c) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: c.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.white24 : Colors.black26, width: 0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: isDark ? Colors.white70 : const Color(0xFF555562), size: 18),
            tooltip: 'Edit Piece & Inventory',
            onPressed: () => _showEditProductDialog(context, product),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
            tooltip: 'Delete Piece',
            onPressed: () => _confirmDeleteProduct(context, product),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. CLIENTS TAB
  // ===========================================================================

  Widget _buildClientsTab(BuildContext context, AdminProvider admin, bool isDark) {
    if (admin.customers.isEmpty) {
      return _buildEmptyCard('No customer accounts registered in Firestore yet.');
    }

    final cardBg = isDark ? const Color(0xFF18181E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF26262F) : const Color(0xFFE2E2EA);
    final textCol = isDark ? Colors.white : const Color(0xFF121217);
    final subTextCol = isDark ? Colors.white70 : const Color(0xFF555562);
    final mutedTextCol = isDark ? Colors.white54 : const Color(0xFF888899);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: admin.customers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = admin.customers[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFC29B38).withValues(alpha: 0.2),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'C',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC29B38)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textCol),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: mutedTextCol),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 13, color: Color(0xFFC29B38)),
                        const SizedBox(width: 4),
                        Text(
                          user.phoneNumber.isNotEmpty ? user.phoneNumber : 'No phone saved',
                          style: TextStyle(fontSize: 11, color: subTextCol),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFC29B38)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.address.isNotEmpty ? user.address : 'No address saved',
                            style: TextStyle(fontSize: 11, color: subTextCol),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODALS & DIALOGS
  // ===========================================================================

  Widget _buildEmptyCard(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrderCourierDialog(BuildContext context, OrderModel order) {
    final courierNameCtrl = TextEditingController(
      text: order.courierName.isNotEmpty ? order.courierName : 'Nuance White Glove Express',
    );
    final courierPhoneCtrl = TextEditingController(
      text: order.courierPhone.isNotEmpty ? order.courierPhone : '+1 (800) 555-0199',
    );
    final trackingCtrl = TextEditingController(
      text: order.trackingNumber.isNotEmpty ? order.trackingNumber : 'NUANCE-TRK-${order.id.replaceAll('ORD-', '')}',
    );
    final addressCtrl = TextEditingController(text: order.shippingAddress);
    final phoneCtrl = TextEditingController(text: order.phoneNumber);
    final notesCtrl = TextEditingController(text: order.deliveryNotes);
    OrderStatus selectedStatus = order.status;

    final presetCouriers = [
      {'name': 'Nuance White Glove Express', 'phone': '+1 (800) 555-0199'},
      {'name': 'DHL Express Worldwide', 'phone': '+1 (800) 225-5345'},
      {'name': 'FedEx Luxury Priority', 'phone': '+1 (800) 463-3339'},
      {'name': 'UPS Atelier Saver', 'phone': '+1 (800) 742-5877'},
      {'name': 'Pronto Luxury Courier', 'phone': '+94 11 234 5678'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E2E38)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: Color(0xFFC29B38), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Courier & Dispatch Details',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order ${order.id} • Real-time Cloud Sync',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POPULAR COURIER PRESETS',
                    style: TextStyle(
                      color: Color(0xFFC29B38),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: presetCouriers.map((preset) {
                      final isSelected = courierNameCtrl.text == preset['name'];
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            courierNameCtrl.text = preset['name']!;
                            courierPhoneCtrl.text = preset['phone']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC29B38).withValues(alpha: 0.25)
                                : const Color(0xFF141418),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF2A2A34),
                            ),
                          ),
                          child: Text(
                            preset['name']!,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFC29B38) : Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Courier Service Name & Courier Contact No
                  Row(
                    children: [
                      Expanded(
                        child: _buildDarkTextField(
                          courierNameCtrl,
                          'Courier Service Name',
                          'e.g. DHL Express, Nuance Express',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDarkTextField(
                          courierPhoneCtrl,
                          'Courier Contact Number',
                          'e.g. +1 (800) 555-0199',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tracking ID & Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDarkTextField(
                          trackingCtrl,
                          'Tracking Reference Code',
                          'e.g. NUANCE-TRK-78901',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Status',
                              style: TextStyle(
                                color: Color(0xFFC29B38),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141418),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF2E2E38)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<OrderStatus>(
                                  value: selectedStatus,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E1E24),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: OrderStatus.values.map((status) {
                                    return DropdownMenuItem<OrderStatus>(
                                      value: status,
                                      child: Text(
                                        status.displayName,
                                        style: TextStyle(
                                          color: status == OrderStatus.delivered
                                              ? Colors.greenAccent
                                              : status == OrderStatus.shipped
                                                  ? Colors.purpleAccent
                                                  : Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedStatus = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Customer Contact Number
                  _buildDarkTextField(
                    phoneCtrl,
                    'Customer Phone Number',
                    'Recipient contact number',
                  ),
                  const SizedBox(height: 12),

                  // Destination Address
                  _buildDarkTextField(
                    addressCtrl,
                    'Delivery Shipping Address',
                    'Apartment / House / Street Address',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Delivery Notes
                  _buildDarkTextField(
                    notesCtrl,
                    'Courier Dispatch Notes',
                    'e.g. Leave with concierge, signature verified',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const Text('Save & Update Dispatch', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () async {
                final cName = courierNameCtrl.text.trim();
                final cPhone = courierPhoneCtrl.text.trim();
                final trk = trackingCtrl.text.trim();
                final addr = addressCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final notes = notesCtrl.text.trim();

                Navigator.pop(ctx);

                await context.read<AdminProvider>().updateOrderDetails(
                  orderId: order.id,
                  status: selectedStatus,
                  courierName: cName.isNotEmpty ? cName : 'Nuance White Glove Express',
                  courierPhone: cPhone.isNotEmpty ? cPhone : '+1 (800) 555-0199',
                  trackingNumber: trk,
                  shippingAddress: addr.isNotEmpty ? addr : order.shippingAddress,
                  customerPhone: phone.isNotEmpty ? phone : order.phoneNumber,
                  deliveryNotes: notes,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.cloud_done_rounded, color: Colors.greenAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Order ${order.id} courier ($cName) & contact ($cPhone) saved.',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF1E1E24),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static final List<String> _luxuryCategories = [
    'Tailored Suits',
    'Silk & Satin',
    'Linen & Resort',
    'Outerwear',
    'Knitwear',
    'Bags & Acc',
    'Evening Wear',
    'Luxury Accessories',
  ];

  static const List<String> _departments = [
    'Women',
    'Men',
    'Accessories',
    'Unisex',
  ];

  static const List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'One Size'];

  static const List<Map<String, dynamic>> _studioPhotoPresets = [
    {
      'title': 'Silk Slip Dress',
      'url': 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Double-Breasted Suit',
      'url': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Minimalist Overcoat',
      'url': 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Washed Linen Set',
      'url': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Cashmere Sweater',
      'url': 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=1000&q=80',
    },
  ];

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController(
      text: 'NNC-INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    String selectedCategory = _luxuryCategories.first;
    String selectedDepartment = 'Women';
    final priceCtrl = TextEditingController(text: '280.0');
    final comparePriceCtrl = TextEditingController(text: '350.0');
    final stockCtrl = TextEditingController(text: '24');
    final descCtrl = TextEditingController(
      text: 'Handcrafted luxury atelier piece tailored from bespoke natural fibers.',
    );
    final customUrlCtrl = TextEditingController();

    String currentImage = '';
    String? uploadedFileName;
    int? uploadedFileSize;
    bool showUrlField = false;

    final Set<String> selectedSizes = {'S', 'M', 'L', 'XL'};
    final List<ProductColor> selectedColors = [
      _presetAtelierColors[0],
      _presetAtelierColors[1],
    ];
    final Map<String, int> variantQuantities = {};
    for (final c in selectedColors) {
      for (final s in selectedSizes) {
        variantQuantities['${c.name}_$s'] = 5;
      }
    }
    bool inStock = true;
    bool isFeatured = false;
    bool isNew = true;

    Future<void> pickPngImage(StateSetter setDialogState) async {
      try {
        final files = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        );
        if (files.isNotEmpty) {
          final file = files.first;
          final bytes = await file.readAsBytes();
          final size = await file.length() ?? bytes.length;
          final ext = file.extension?.toLowerCase() ?? 'png';
          final mime = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
          final base64String = base64Encode(bytes);
          setDialogState(() {
            currentImage = 'data:$mime;base64,$base64String';
            uploadedFileName = file.name;
            uploadedFileSize = size;
            customUrlCtrl.clear();
          });
        }
      } catch (e) {
        debugPrint('[Admin] File picker error: $e');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF2E2E38)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFC29B38), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Inventory Garment',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live Catalog & Firestore Stock Sync',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: PRODUCT IMAGE UPLOAD (PNG / PHOTOS) ---
                  const Text(
                    'PRODUCT PHOTOGRAPHY / PNG UPLOAD',
                    style: TextStyle(
                      color: Color(0xFFC29B38),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131317),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentImage.isNotEmpty ? const Color(0xFFC29B38).withValues(alpha: 0.6) : const Color(0xFF282832),
                        width: currentImage.isNotEmpty ? 1.5 : 1.0,
                      ),
                    ),
                    child: currentImage.isNotEmpty
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 88,
                                  child: CustomImage(imagePath: currentImage, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            uploadedFileName ?? 'Garment Image Ready',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      uploadedFileSize != null
                                          ? '${(uploadedFileSize! / 1024).toStringAsFixed(1)} KB • PNG Attached'
                                          : 'High-Resolution Luxury Asset',
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => pickPngImage(setDialogState),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFC29B38)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.upload_file_rounded, size: 14, color: Color(0xFFC29B38)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Change PNG',
                                                  style: TextStyle(
                                                    color: Color(0xFFC29B38),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () {
                                            setDialogState(() {
                                              currentImage = '';
                                              uploadedFileName = null;
                                              uploadedFileSize = null;
                                            });
                                          },
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () => pickPngImage(setDialogState),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFC29B38), size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Click to Upload PNG / Image',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Browse local PNG, JPG, or WEBP from your computer',
                                    style: TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Luxury Presets
                  Row(
                    children: [
                      const Text(
                        'Studio Presets:',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _studioPhotoPresets.map((preset) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      currentImage = preset['url']!;
                                      uploadedFileName = '${preset['title']}.jpg';
                                      uploadedFileSize = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141418),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF2E2E38)),
                                    ),
                                    child: Text(
                                      preset['title']!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setDialogState(() {
                            showUrlField = !showUrlField;
                          });
                        },
                        child: Text(
                          showUrlField ? 'Hide URL' : 'Paste URL',
                          style: const TextStyle(color: Color(0xFFC29B38), fontSize: 10, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  if (showUrlField) ...[
                    const SizedBox(height: 8),
                    _buildDarkTextField(
                      customUrlCtrl,
                      'Direct Image URL',
                      'https://...',
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (customUrlCtrl.text.trim().isNotEmpty) {
                            setDialogState(() {
                              currentImage = customUrlCtrl.text.trim();
                              uploadedFileName = 'Custom Web Image';
                              uploadedFileSize = null;
                            });
                          }
                        },
                        child: const Text('Apply URL', style: TextStyle(color: Color(0xFFC29B38), fontSize: 11)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF282832), height: 1),
                  const SizedBox(height: 16),

                  // --- SECTION 2: REAL-LIFE INVENTORY ATTRIBUTES ---
                  const Text(
                    'INVENTORY SPECIFICATIONS & SKU',
                    style: TextStyle(
                      color: Color(0xFFC29B38),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Name & SKU Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDarkTextField(nameCtrl, 'Garment Name', 'e.g. Fluid Silk Satin Slip Dress'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDarkTextField(skuCtrl, 'SKU Code', 'e.g. NNC-INV-001'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Department / Gender Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATALOGUE DEPARTMENT',
                        style: TextStyle(
                          color: Color(0xFFC29B38),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _departments.map((dept) {
                          final isSelected = selectedDepartment == dept;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedDepartment = dept;
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF141418),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF282832),
                                ),
                              ),
                              child: Text(
                                dept == 'Women' ? 'Women\'s Wear' : (dept == 'Men' ? 'Men\'s Wear' : dept),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category & Stock Count Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Collection Category',
                                  style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    _showAddNewCategoryDialog(ctx, setDialogState, (newCat) {
                                      selectedCategory = newCat;
                                    });
                                  },
                                  child: const Text(
                                    '+ New Category',
                                    style: TextStyle(
                                      color: Color(0xFFC29B38),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141418),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF282832)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1A1A20),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  items: _luxuryCategories.map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedCategory = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDarkTextField(stockCtrl, 'Units in Inventory', 'e.g. 25', isNum: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pricing Row: Retail Price & Compare-at MSRP
                  Row(
                    children: [
                      Expanded(
                        child: _buildDarkTextField(priceCtrl, 'Retail Price (LKR)', 'e.g. 280.0', isNum: true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDarkTextField(comparePriceCtrl, 'Original MSRP (LKR)', 'e.g. 350.0 (Optional)', isNum: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Available Sizes Matrix (Interactive Multi-Select)
                  const Text(
                    'Available Sizes in Stock',
                    style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: _availableSizes.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        selectedColor: const Color(0xFFC29B38),
                        backgroundColor: const Color(0xFF141418),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF282832),
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              selectedSizes.add(size);
                            } else {
                              if (selectedSizes.length > 1) {
                                selectedSizes.remove(size);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Garment Color Palette Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Garment Color Palette',
                        style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${selectedColors.length} selected',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._presetAtelierColors.map((pc) {
                        final isSel = selectedColors.any((c) => c.name == pc.name);
                        return FilterChip(
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: pc.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 1),
                            ),
                          ),
                          label: Text(pc.name),
                          selected: isSel,
                          selectedColor: const Color(0xFFC29B38).withValues(alpha: 0.25),
                          backgroundColor: const Color(0xFF141418),
                          labelStyle: TextStyle(
                            color: isSel ? const Color(0xFFC29B38) : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSel ? const Color(0xFFC29B38) : const Color(0xFF282832),
                          ),
                          onSelected: (val) {
                            setDialogState(() {
                              if (val) {
                                selectedColors.add(pc);
                              } else {
                                if (selectedColors.length > 1) {
                                  selectedColors.removeWhere((c) => c.name == pc.name);
                                }
                              }
                            });
                          },
                        );
                      }),
                      ...selectedColors
                          .where((c) => !_presetAtelierColors.any((p) => p.name == c.name))
                          .map((customColor) {
                        return Chip(
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: customColor.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30),
                            ),
                          ),
                          label: Text(customColor.name),
                          backgroundColor: const Color(0xFFC29B38).withValues(alpha: 0.25),
                          labelStyle: const TextStyle(
                            color: Color(0xFFC29B38),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFC29B38)),
                          onDeleted: () {
                            setDialogState(() {
                              if (selectedColors.length > 1) {
                                selectedColors.removeWhere((c) => c.name == customColor.name);
                              }
                            });
                          },
                          side: const BorderSide(color: Color(0xFFC29B38)),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 14, color: Color(0xFFC29B38)),
                        label: const Text('+ Custom Color'),
                        labelStyle: const TextStyle(
                          color: Color(0xFFC29B38),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: const Color(0xFF141418),
                        side: BorderSide(color: const Color(0xFFC29B38).withValues(alpha: 0.5)),
                        onPressed: () {
                          _showAddCustomColorDialog(ctx, setDialogState, selectedColors);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Variant Inventory Quantities (Per Color & Per Size)
                  _buildVariantStockMatrix(
                    selectedColors: selectedColors,
                    selectedSizes: selectedSizes,
                    variantQuantities: variantQuantities,
                    stockCtrl: stockCtrl,
                    setDialogState: setDialogState,
                  ),
                  const SizedBox(height: 12),

                  // Description & Tailoring Notes
                  _buildDarkTextField(
                    descCtrl,
                    'Fabric Composition & Atelier Notes',
                    'Describe silhouette, material blend, lining, and care instructions',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Switches: In Stock, Featured, New Arrival
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('In Stock', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: inStock,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => inStock = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isFeatured,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => isFeatured = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('New Season', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isNew,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => isNew = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('Add to Inventory', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final price = double.tryParse(priceCtrl.text) ?? 150.0;
                final originalPrice = double.tryParse(comparePriceCtrl.text);
                final totalStock = variantQuantities.isNotEmpty
                    ? _sumVariantQuantities(variantQuantities)
                    : (int.tryParse(stockCtrl.text) ?? 15);
                final isAvailable = inStock && totalStock > 0;

                final finalImage = currentImage.isNotEmpty
                    ? currentImage
                    : 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=1000&q=80';

                final newProduct = Product(
                  id: 'prod_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  name: nameCtrl.text.trim(),
                  brand: 'NUANCE',
                  category: selectedCategory,
                  department: selectedDepartment,
                  description: descCtrl.text.trim(),
                  price: price,
                  originalPrice: originalPrice,
                  images: [finalImage],
                  sizes: selectedSizes.toList(),
                  colors: selectedColors,
                  inStock: isAvailable,
                  isFeatured: isFeatured,
                  isNew: isNew,
                  sku: skuCtrl.text.trim(),
                  stockCount: totalStock,
                  variantStock: Map<String, int>.from(variantQuantities),
                );

                context.read<AdminProvider>().addProduct(newProduct);
                context.read<ProductsProvider>().addProduct(newProduct);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newProduct.name} (SKU: ${newProduct.sku}) added to Inventory & Firestore.'),
                    backgroundColor: const Color(0xFF1E1E24),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final skuCtrl = TextEditingController(
      text: product.sku.isNotEmpty ? product.sku : 'NNC-SKU-${product.id.toUpperCase()}',
    );
    if (!_luxuryCategories.contains(product.category) && product.category.isNotEmpty) {
      _luxuryCategories.add(product.category);
    }
    String selectedCategory = product.category.isNotEmpty
        ? product.category
        : _luxuryCategories.first;
    String selectedDepartment = _departments.contains(product.department)
        ? product.department
        : 'Women';
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final comparePriceCtrl = TextEditingController(
      text: product.originalPrice != null ? product.originalPrice!.toStringAsFixed(2) : '',
    );
    final stockCtrl = TextEditingController(text: product.stockCount.toString());
    final descCtrl = TextEditingController(text: product.description);
    final customUrlCtrl = TextEditingController();

    String currentImage = product.mainImage;
    String? uploadedFileName;
    int? uploadedFileSize;
    bool showUrlField = false;

    final Set<String> selectedSizes = Set<String>.from(
      product.sizes.isNotEmpty ? product.sizes : ['S', 'M', 'L'],
    );
    final List<ProductColor> selectedColors = List<ProductColor>.from(
      product.colors.isNotEmpty ? product.colors : _presetAtelierColors.take(2),
    );
    final Map<String, int> variantQuantities = Map<String, int>.from(product.variantStock);
    if (variantQuantities.isEmpty && product.stockCount > 0 && selectedColors.isNotEmpty && selectedSizes.isNotEmpty) {
      final totalCombos = selectedColors.length * selectedSizes.length;
      final baseUnits = product.stockCount ~/ totalCombos;
      int rem = product.stockCount % totalCombos;
      for (final c in selectedColors) {
        for (final s in selectedSizes) {
          final extra = rem > 0 ? 1 : 0;
          if (rem > 0) rem--;
          variantQuantities['${c.name}_$s'] = baseUnits + extra;
        }
      }
    }
    bool inStock = product.inStock;
    bool isFeatured = product.isFeatured;
    bool isNew = product.isNew;

    Future<void> pickPngImage(StateSetter setDialogState) async {
      try {
        final files = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        );
        if (files.isNotEmpty) {
          final file = files.first;
          final bytes = await file.readAsBytes();
          final size = await file.length() ?? bytes.length;
          final ext = file.extension?.toLowerCase() ?? 'png';
          final mime = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
          final base64String = base64Encode(bytes);
          setDialogState(() {
            currentImage = 'data:$mime;base64,$base64String';
            uploadedFileName = file.name;
            uploadedFileSize = size;
            customUrlCtrl.clear();
          });
        }
      } catch (e) {
        debugPrint('[Admin] File picker error: $e');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF2E2E38)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_note_rounded, color: Color(0xFFC29B38), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit ${product.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${product.sku.isNotEmpty ? product.sku : product.id} • Real-time Firestore Sync',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: PRODUCT IMAGE UPLOAD (PNG / PHOTOS) ---
                  const Text(
                    'PRODUCT PHOTOGRAPHY / PNG UPLOAD',
                    style: TextStyle(
                      color: Color(0xFFC29B38),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131317),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentImage.isNotEmpty ? const Color(0xFFC29B38).withValues(alpha: 0.6) : const Color(0xFF282832),
                        width: currentImage.isNotEmpty ? 1.5 : 1.0,
                      ),
                    ),
                    child: currentImage.isNotEmpty
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 88,
                                  child: CustomImage(imagePath: currentImage, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            uploadedFileName ?? 'Current Piece Photography',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      uploadedFileSize != null
                                          ? '${(uploadedFileSize! / 1024).toStringAsFixed(1)} KB • PNG Attached'
                                          : (currentImage.startsWith('data:') ? 'Custom PNG In-Memory' : 'Live High-Res Studio Asset'),
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => pickPngImage(setDialogState),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFC29B38)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.upload_file_rounded, size: 14, color: Color(0xFFC29B38)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Upload New PNG',
                                                  style: TextStyle(
                                                    color: Color(0xFFC29B38),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        TextButton(
                                          onPressed: () {
                                            setDialogState(() {
                                              currentImage = '';
                                              uploadedFileName = null;
                                              uploadedFileSize = null;
                                            });
                                          },
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () => pickPngImage(setDialogState),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFC29B38), size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Click to Upload PNG / Image',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Browse local PNG, JPG, or WEBP from your computer',
                                    style: TextStyle(color: Colors.white38, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Presets
                  Row(
                    children: [
                      const Text(
                        'Studio Presets:',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _studioPhotoPresets.map((preset) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      currentImage = preset['url']!;
                                      uploadedFileName = '${preset['title']}.jpg';
                                      uploadedFileSize = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF141418),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF2E2E38)),
                                    ),
                                    child: Text(
                                      preset['title']!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setDialogState(() {
                            showUrlField = !showUrlField;
                          });
                        },
                        child: Text(
                          showUrlField ? 'Hide URL' : 'Paste URL',
                          style: const TextStyle(color: Color(0xFFC29B38), fontSize: 10, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  if (showUrlField) ...[
                    const SizedBox(height: 8),
                    _buildDarkTextField(
                      customUrlCtrl,
                      'Direct Image URL',
                      'https://...',
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (customUrlCtrl.text.trim().isNotEmpty) {
                            setDialogState(() {
                              currentImage = customUrlCtrl.text.trim();
                              uploadedFileName = 'Custom Web Image';
                              uploadedFileSize = null;
                            });
                          }
                        },
                        child: const Text('Apply URL', style: TextStyle(color: Color(0xFFC29B38), fontSize: 11)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF282832), height: 1),
                  const SizedBox(height: 16),

                  // --- SECTION 2: REAL-LIFE INVENTORY ATTRIBUTES ---
                  const Text(
                    'INVENTORY SPECIFICATIONS & SKU',
                    style: TextStyle(
                      color: Color(0xFFC29B38),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Product Name & SKU Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDarkTextField(nameCtrl, 'Garment Name', ''),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDarkTextField(skuCtrl, 'SKU Code', 'e.g. NNC-INV-001'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Department / Gender Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATALOGUE DEPARTMENT',
                        style: TextStyle(
                          color: Color(0xFFC29B38),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _departments.map((dept) {
                          final isSelected = selectedDepartment == dept;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedDepartment = dept;
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF141418),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF282832),
                                ),
                              ),
                              child: Text(
                                dept == 'Women' ? 'Women\'s Wear' : (dept == 'Men' ? 'Men\'s Wear' : dept),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category & Stock Count Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Collection Category',
                                  style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    _showAddNewCategoryDialog(ctx, setDialogState, (newCat) {
                                      selectedCategory = newCat;
                                    });
                                  },
                                  child: const Text(
                                    '+ New Category',
                                    style: TextStyle(
                                      color: Color(0xFFC29B38),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141418),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF282832)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1A1A20),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  items: _luxuryCategories.map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedCategory = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDarkTextField(stockCtrl, 'Units in Inventory', '', isNum: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pricing Row: Retail Price & Compare-at MSRP
                  Row(
                    children: [
                      Expanded(
                        child: _buildDarkTextField(priceCtrl, 'Retail Price (LKR)', '', isNum: true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDarkTextField(comparePriceCtrl, 'Original MSRP (LKR)', 'Compare price', isNum: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Available Sizes Matrix (Interactive Multi-Select)
                  const Text(
                    'Available Sizes in Stock',
                    style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: _availableSizes.map((size) {
                      final isSelected = selectedSizes.contains(size);
                      return FilterChip(
                        label: Text(size),
                        selected: isSelected,
                        selectedColor: const Color(0xFFC29B38),
                        backgroundColor: const Color(0xFF141418),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFC29B38) : const Color(0xFF282832),
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              selectedSizes.add(size);
                            } else {
                              if (selectedSizes.length > 1) {
                                selectedSizes.remove(size);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Garment Color Palette Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Garment Color Palette',
                        style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${selectedColors.length} selected',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._presetAtelierColors.map((pc) {
                        final isSel = selectedColors.any((c) => c.name == pc.name);
                        return FilterChip(
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: pc.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 1),
                            ),
                          ),
                          label: Text(pc.name),
                          selected: isSel,
                          selectedColor: const Color(0xFFC29B38).withValues(alpha: 0.25),
                          backgroundColor: const Color(0xFF141418),
                          labelStyle: TextStyle(
                            color: isSel ? const Color(0xFFC29B38) : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSel ? const Color(0xFFC29B38) : const Color(0xFF282832),
                          ),
                          onSelected: (val) {
                            setDialogState(() {
                              if (val) {
                                selectedColors.add(pc);
                              } else {
                                if (selectedColors.length > 1) {
                                  selectedColors.removeWhere((c) => c.name == pc.name);
                                }
                              }
                            });
                          },
                        );
                      }),
                      ...selectedColors
                          .where((c) => !_presetAtelierColors.any((p) => p.name == c.name))
                          .map((customColor) {
                        return Chip(
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: customColor.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30),
                            ),
                          ),
                          label: Text(customColor.name),
                          backgroundColor: const Color(0xFFC29B38).withValues(alpha: 0.25),
                          labelStyle: const TextStyle(
                            color: Color(0xFFC29B38),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFC29B38)),
                          onDeleted: () {
                            setDialogState(() {
                              if (selectedColors.length > 1) {
                                selectedColors.removeWhere((c) => c.name == customColor.name);
                              }
                            });
                          },
                          side: const BorderSide(color: Color(0xFFC29B38)),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 14, color: Color(0xFFC29B38)),
                        label: const Text('+ Custom Color'),
                        labelStyle: const TextStyle(
                          color: Color(0xFFC29B38),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: const Color(0xFF141418),
                        side: BorderSide(color: const Color(0xFFC29B38).withValues(alpha: 0.5)),
                        onPressed: () {
                          _showAddCustomColorDialog(ctx, setDialogState, selectedColors);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Variant Inventory Quantities (Per Color & Per Size)
                  _buildVariantStockMatrix(
                    selectedColors: selectedColors,
                    selectedSizes: selectedSizes,
                    variantQuantities: variantQuantities,
                    stockCtrl: stockCtrl,
                    setDialogState: setDialogState,
                  ),
                  const SizedBox(height: 12),

                  // Description & Tailoring Notes
                  _buildDarkTextField(
                    descCtrl,
                    'Fabric Composition & Atelier Notes',
                    'Describe silhouette, material blend, lining, and care instructions',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Switches: In Stock, Featured, New Arrival
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('In Stock', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: inStock,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => inStock = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isFeatured,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => isFeatured = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('New Season', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: isNew,
                          activeThumbColor: const Color(0xFFC29B38),
                          onChanged: (val) {
                            setDialogState(() => isNew = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                final price = double.tryParse(priceCtrl.text) ?? product.price;
                final originalPrice = double.tryParse(comparePriceCtrl.text) ?? product.originalPrice;
                final totalStock = variantQuantities.isNotEmpty
                    ? _sumVariantQuantities(variantQuantities)
                    : (int.tryParse(stockCtrl.text) ?? product.stockCount);
                final isAvailable = inStock && totalStock > 0;

                final updated = product.copyWith(
                  name: nameCtrl.text.trim(),
                  category: selectedCategory,
                  department: selectedDepartment,
                  description: descCtrl.text.trim(),
                  price: price,
                  originalPrice: originalPrice,
                  images: currentImage.isNotEmpty ? [currentImage] : product.images,
                  sizes: selectedSizes.toList(),
                  colors: selectedColors,
                  inStock: isAvailable,
                  isFeatured: isFeatured,
                  isNew: isNew,
                  sku: skuCtrl.text.trim(),
                  stockCount: totalStock,
                  variantStock: Map<String, int>.from(variantQuantities),
                );

                context.read<AdminProvider>().updateProduct(updated);
                context.read<ProductsProvider>().updateProduct(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${updated.name} updated in Inventory & Cloud Firestore.'),
                    backgroundColor: const Color(0xFF1E1E24),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Remove Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to permanently delete "${product.name}" from Cloud Firestore?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<AdminProvider>().deleteProduct(product.id);
              context.read<ProductsProvider>().deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product removed from Cloud Firestore.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController ctrl, String label, String hint, {bool isNum = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF141418),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _showAddCustomColorDialog(
    BuildContext parentContext,
    StateSetter setParentState,
    List<ProductColor> selectedColors,
  ) {
    final nameCtrl = TextEditingController();
    Color selectedHue = const Color(0xFF1B365D);

    final List<Color> swatchChoices = [
      const Color(0xFF1B365D), // Midnight Navy
      const Color(0xFF2C3E50), // Slate Indigo
      const Color(0xFF1E3A2F), // Forest Hunter
      const Color(0xFF385E38), // Sage Olive
      const Color(0xFF5C1D24), // Bordeaux Wine
      const Color(0xFF78281F), // Crimson Berry
      const Color(0xFF7D5A44), // Mocha Walnut
      const Color(0xFFB8860B), // Antique Gold
      const Color(0xFF8B4513), // Saddle Brown
      const Color(0xFF4A3B32), // Espresso
      const Color(0xFF6B4C70), // Royal Mauve
      const Color(0xFF2F4F4F), // Dark Slate Grey
      const Color(0xFFE8DCC4), // Champagne Cream
      const Color(0xFFC0C0C0), // Sterling Silver
      const Color(0xFF1A1A1A), // Pure Obsidian
    ];

    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setCustomDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E2E38)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.palette_rounded, color: Color(0xFFC29B38), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add Bespoke Color',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDarkTextField(
                  nameCtrl,
                  'Color Shade Name',
                  'e.g. Midnight Sapphire, Terracotta, Bordeaux',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Hue Swatch',
                  style: TextStyle(color: Color(0xFFC29B38), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: swatchChoices.map((c) {
                    final isChosen = selectedHue.toARGB32() == c.toARGB32();
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setCustomDialogState(() => selectedHue = c);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isChosen ? const Color(0xFFC29B38) : Colors.white24,
                            width: isChosen ? 2.5 : 1,
                          ),
                          boxShadow: isChosen
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFC29B38).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isChosen
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setParentState(() {
                  selectedColors.add(ProductColor(
                    name: name,
                    colorValue: selectedHue.toARGB32(),
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add Swatch', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNewCategoryDialog(
    BuildContext parentContext,
    StateSetter setParentState,
    ValueChanged<String> onCategoryAdded,
  ) {
    final catCtrl = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E2E38)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.category_rounded, color: Color(0xFFC29B38), size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Create Atelier Category',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDarkTextField(
                catCtrl,
                'Category Title',
                'e.g. Fine Jewelry, Cashmere Shawls, Footwear',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC29B38),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newCat = catCtrl.text.trim();
              if (newCat.isEmpty) return;
              if (!_luxuryCategories.contains(newCat)) {
                _luxuryCategories.add(newCat);
              }
              parentContext.read<ProductsProvider>().addCategory(newCat);
              setParentState(() {
                onCategoryAdded(newCat);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('Category "$newCat" created successfully.'),
                  backgroundColor: const Color(0xFF1E1E24),
                ),
              );
            },
            child: const Text('Create Category', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _sumVariantQuantities(Map<String, int> map) {
    if (map.isEmpty) return 0;
    return map.values.fold(0, (sum, val) => sum + val);
  }

  Widget _buildVariantStockMatrix({
    required List<ProductColor> selectedColors,
    required Set<String> selectedSizes,
    required Map<String, int> variantQuantities,
    required TextEditingController stockCtrl,
    required StateSetter setDialogState,
  }) {
    final totalUnits = _sumVariantQuantities(variantQuantities);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFFC29B38)),
                  SizedBox(width: 6),
                  Text(
                    'Variant Stock Matrix (Color × Size)',
                    style: TextStyle(color: Color(0xFFC29B38), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: totalUnits == 0
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : (totalUnits <= 5
                          ? const Color(0xFFC29B38).withValues(alpha: 0.2)
                          : const Color(0xFF1C1C24)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: totalUnits == 0
                        ? Colors.redAccent
                        : (totalUnits <= 5 ? const Color(0xFFC29B38) : Colors.white24),
                  ),
                ),
                child: Text(
                  totalUnits == 0
                      ? 'SOLD OUT (0 Units)'
                      : (totalUnits <= 5
                          ? 'ALMOST SOLD OUT ($totalUnits Units)'
                          : 'Total: $totalUnits Units'),
                  style: TextStyle(
                    color: totalUnits == 0
                        ? Colors.redAccent
                        : (totalUnits <= 5 ? const Color(0xFFC29B38) : Colors.white),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (selectedColors.isEmpty || selectedSizes.isEmpty)
            const Text(
              'Select at least one color and one size to set variant quantities.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            )
          else
            ...selectedColors.map((color) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF282832)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            color.name,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: selectedSizes.map((size) {
                          final key = '${color.name}_$size';
                          variantQuantities.putIfAbsent(key, () => 5);
                          final qty = variantQuantities[key] ?? 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141418),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: qty == 0
                                    ? Colors.redAccent.withValues(alpha: 0.6)
                                    : (qty <= 2
                                        ? const Color(0xFFC29B38).withValues(alpha: 0.6)
                                        : const Color(0xFF2C2C36)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$size: ',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (qty > 0) {
                                      setDialogState(() {
                                        variantQuantities[key] = qty - 1;
                                        stockCtrl.text = _sumVariantQuantities(variantQuantities).toString();
                                      });
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Icon(Icons.remove, size: 12, color: Colors.white54),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '$qty',
                                    style: TextStyle(
                                      color: qty == 0 ? Colors.redAccent : Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      variantQuantities[key] = qty + 1;
                                      stockCtrl.text = _sumVariantQuantities(variantQuantities).toString();
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Icon(Icons.add, size: 12, color: Color(0xFFC29B38)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
