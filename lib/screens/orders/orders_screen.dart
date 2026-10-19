import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/review_rating_dialog.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<AuthProvider>().user;
      final orders = await _firestoreService.getUserOrders(user?.id ?? '');
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to sync orders. Pull to refresh.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmReceivedParcel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: Color(0xFFC29B38), size: 22),
            SizedBox(width: 10),
            Text('Confirm Parcel Received', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Have you safely received your parcel for Order ${order.id}? This will mark your order as Delivered.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC29B38),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Received Parcel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.confirmParcelReceived(order.id);
      await _fetchOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E24),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Order ${order.id} marked as Delivered! How did your garments fit?',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            action: order.items.isNotEmpty
                ? SnackBarAction(
                    label: 'RATE PIECES',
                    textColor: const Color(0xFFC29B38),
                    onPressed: () {
                      AtelierReviewDialog.show(
                        context,
                        order: order,
                        item: order.items.first,
                        onReviewSubmitted: _fetchOrders,
                      );
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  void _buyAgain(OrderModel order) {
    final cart = context.read<CartProvider>();
    for (final item in order.items) {
      cart.addToCart(
        product: item.product,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
        quantity: item.quantity,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E24),
        content: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Color(0xFFC29B38), size: 18),
            const SizedBox(width: 8),
            Text(
              '${order.items.length} piece${order.items.length == 1 ? '' : 's'} added to your shopping bag.',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  List<OrderModel> get _filteredOrders {
    var list = _orders;

    if (_selectedFilter == 'Active') {
      list = list.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();
    } else if (_selectedFilter == 'Completed') {
      list = list.where((o) => o.status == OrderStatus.delivered).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((o) {
        final matchesId = o.id.toLowerCase().contains(query);
        final matchesItem = o.items.any((i) => i.product.name.toLowerCase().contains(query));
        return matchesId || matchesItem;
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PURCHASE ARCHIVE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Orders',
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID or garment name...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All', _orders.length),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Active',
                      _orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Completed',
                      _orders.where((o) => o.status == OrderStatus.delivered).length,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC29B38)),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredOrders.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            color: const Color(0xFFC29B38),
                            onRefresh: _fetchOrders,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: _filteredOrders.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return _buildOrderCard(context, order, isDark);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC29B38)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC29B38) : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, bool isDark) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header: ID, Date, Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const Divider(height: 20),

            // Item Thumbnails & Names
            if (order.items.isNotEmpty) ...[
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 52,
                          child: CustomImage(
                            imagePath: item.product.mainImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Size ${item.selectedSize} • ${item.selectedColor.name} • Qty ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            if (order.status == OrderStatus.delivered) ...[
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                                  AtelierReviewDialog.show(
                                    context,
                                    order: order,
                                    item: item,
                                    onReviewSubmitted: _fetchOrders,
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: order.isProductReviewed(item.product.id)
                                        ? Colors.green.withValues(alpha: 0.12)
                                        : const Color(0xFFC29B38).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: order.isProductReviewed(item.product.id)
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : const Color(0xFFC29B38).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        order.isProductReviewed(item.product.id)
                                            ? Icons.verified
                                            : Icons.star_rounded,
                                        size: 13,
                                        color: order.isProductReviewed(item.product.id)
                                            ? Colors.green
                                            : const Color(0xFFC29B38),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        order.isProductReviewed(item.product.id)
                                            ? 'Reviewed ★'
                                            : 'Rate & Review',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: order.isProductReviewed(item.product.id)
                                              ? Colors.green
                                              : const Color(0xFFC29B38),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        'LKR ${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 16),
            ],

            // Delivery & View Details Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFC29B38)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Standard Delivery',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Text(
                      'Total: LKR ${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC29B38),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFC29B38)),
                  ],
                ),
              ],
            ),

            // Post-Delivery / Parcel Actions Strip
            if (order.status == OrderStatus.delivered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1B22) : const Color(0xFFF6F6F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE8E8EE),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC29B38)),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          if (order.items.isNotEmpty) {
                            AtelierReviewDialog.show(
                              context,
                              order: order,
                              item: order.items.first,
                              onReviewSubmitted: _fetchOrders,
                            );
                          }
                        },
                        icon: const Icon(Icons.star_rounded, size: 16, color: Color(0xFFC29B38)),
                        label: Text(
                          order.reviewedProductIds.isNotEmpty ? 'WRITE REVIEW' : '★ RATE & REVIEW',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC29B38),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF282832) : const Color(0xFFE2E2E8),
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _buyAgain(order),
                        icon: const Icon(Icons.replay_rounded, size: 15),
                        label: const Text(
                          'BUY AGAIN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (order.status == OrderStatus.shipped) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmReceivedParcel(order),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text(
                    'CONFIRM PARCEL RECEIVED',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case OrderStatus.placed:
        bg = const Color(0xFFC29B38).withValues(alpha: 0.15);
        fg = const Color(0xFFC29B38);
        break;
      case OrderStatus.processing:
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade700;
        break;
      case OrderStatus.shipped:
        bg = Colors.purple.withValues(alpha: 0.15);
        fg = Colors.purple.shade700;
        break;
      case OrderStatus.delivered:
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade700;
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error loading orders',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFC29B38).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFFC29B38)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your atelier garment purchases and tracking updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('EXPLORE COLLECTION'),
            ),
          ],
        ),
      ),
    );
  }
}
