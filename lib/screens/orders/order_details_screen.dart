import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/review_rating_dialog.dart';
import '../product_details/product_details_screen.dart';
import '../main_nav_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final createdDateStr = DateFormat('MMMM d, yyyy • h:mm a').format(order.createdAt);
    final estDelivery = DateFormat('EEEE, MMMM d, yyyy').format(order.createdAt.add(const Duration(days: 4)));

    return Scaffold(
      appBar: AppBar(
        title: Text(order.id),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavScreen(initialIndex: 2),
                ),
                (route) => false,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavScreen(initialIndex: 0),
              ),
              (route) => false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Digital Receipt',
            onPressed: () => _showReceiptModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Banner Card
            _buildStatusCard(context, isDark, estDelivery, createdDateStr),
            const SizedBox(height: 20),

            // Parcel Delivered Review Card (if delivered)
            if (order.status == OrderStatus.delivered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC29B38).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC29B38).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Color(0xFFC29B38), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PARCEL DELIVERED TO YOU',
                            style: TextStyle(
                              color: Color(0xFFC29B38),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'How did your pieces fit and feel? Share your verified rating with the atelier.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC29B38),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (order.items.isNotEmpty) {
                          AtelierReviewDialog.show(context, order: order, item: order.items.first);
                        }
                      },
                      child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 2. Order Fulfillment Stepper
            _buildOrderTimeline(context, isDark),
            const SizedBox(height: 24),

            // 3. Products List
            _buildSectionHeader(context, 'PIECES IN THIS ORDER', '${order.items.length} item${order.items.length == 1 ? '' : 's'}'),
            const SizedBox(height: 10),
            _buildProductsList(context, isDark),
            const SizedBox(height: 24),

            // 4. Delivery & Contact Information
            _buildSectionHeader(context, 'DELIVERY & COURIER DESTINATION', null),
            const SizedBox(height: 10),
            _buildDeliveryCard(context, isDark),
            const SizedBox(height: 24),

            // 5. Payment & Financial Summary
            _buildSectionHeader(context, 'PAYMENT & BILLING SUMMARY', null),
            const SizedBox(height: 10),
            _buildPaymentCard(context, isDark),
            const SizedBox(height: 28),

            // 6. Action Buttons
            _buildActionButtons(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AtelierBottomNavBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 2 && Navigator.canPop(context)) {
            Navigator.pop(context);
            return;
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavScreen(initialIndex: index),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFFC29B38),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isDark, String estDelivery, String createdDateStr) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC29B38).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER REFERENCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    createdDateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              _buildStatusPill(order.status),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Color(0xFFC29B38), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED ATELIER ARRIVAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estDelivery,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(OrderStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final steps = [
      {'title': 'Order Placed', 'subtitle': DateFormat('MMM d, h:mm a').format(order.createdAt), 'done': true},
      {'title': 'Atelier Quality Inspection', 'subtitle': 'In Progress', 'done': order.status != OrderStatus.placed},
      {'title': 'Handed to Courier', 'subtitle': 'Tracking: NU-${order.id.replaceAll(RegExp(r'[^0-9]'), '')}-EX', 'done': order.status == OrderStatus.shipped || order.status == OrderStatus.delivered},
      {'title': 'Delivered', 'subtitle': 'Signature Required', 'done': order.status == OrderStatus.delivered},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE TRACKING TIMELINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'NU-${order.id.replaceAll(RegExp(r'[^0-9]'), '')}-EX'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Courier tracking number copied to clipboard!')),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.copy_rounded, size: 14, color: Color(0xFFC29B38)),
                    SizedBox(width: 4),
                    Text(
                      'Copy Tracking',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC29B38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: (steps[i]['done'] as bool)
                            ? const Color(0xFFC29B38)
                            : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: (steps[i]['done'] as bool)
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color: (steps[i]['done'] as bool)
                            ? const Color(0xFFC29B38).withValues(alpha: 0.5)
                            : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i]['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: (steps[i]['done'] as bool) ? FontWeight.w700 : FontWeight.w500,
                            color: (steps[i]['done'] as bool)
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[i]['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    if (order.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
          ),
        ),
        child: const Center(
          child: Text(
            'Order items recorded in atelier archive.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: order.items.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: item.product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 78,
                    child: CustomImage(
                      imagePath: item.product.mainImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Color(0xFFC29B38),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Size: ${item.selectedSize}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item.selectedColor.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 0.5),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.selectedColor.name,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${item.quantity} × LKR ${item.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
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
                                  order.isProductReviewed(item.product.id) ? Icons.verified : Icons.star_rounded,
                                  size: 13,
                                  color: order.isProductReviewed(item.product.id) ? Colors.green : const Color(0xFFC29B38),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order.isProductReviewed(item.product.id) ? 'Reviewed ★' : 'Rate & Review',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: order.isProductReviewed(item.product.id) ? Colors.green : const Color(0xFFC29B38),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFC29B38), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SHIPPING ADDRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingAddress.isNotEmpty
                          ? order.shippingAddress
                          : 'Standard Atelier Delivery Address',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Color(0xFFC29B38), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PHONE NUMBER (FOR COURIER UPDATES)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.phoneNumber.isNotEmpty
                          ? order.phoneNumber
                          : 'Registered phone on profile',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_shipping_outlined, color: Color(0xFFC29B38), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DISPATCH COURIER PARTNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.courierName.isNotEmpty
                          ? order.courierName
                          : 'Nuance White Glove Express',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFFC29B38)),
                        const SizedBox(width: 4),
                        Text(
                          'Hotline: ${order.courierPhone.isNotEmpty ? order.courierPhone : "+1 (800) 555-0199"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (order.trackingNumber.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFC29B38).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Tracking: ${order.trackingNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'monospace',
                            color: Color(0xFFC29B38),
                          ),
                        ),
                      ),
                    ],
                    if (order.deliveryNotes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Dispatch Note: "${order.deliveryNotes}"',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: Color(0xFFC29B38), size: 20),
              const SizedBox(width: 10),
              Text(
                'Paid via ${order.paymentMethod}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PAID & CONFIRMED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildSummaryRow('Subtotal', 'LKR ${order.subtotal.toStringAsFixed(2)}'),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Promotion Discount',
              '-LKR ${order.discount.toStringAsFixed(2)}',
              valueColor: const Color(0xFFC29B38),
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Service',
            order.shippingFee == 0 ? 'Complimentary' : 'LKR ${order.shippingFee.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                'LKR ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
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

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (order.status == OrderStatus.delivered) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29B38),
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.star_rounded, size: 20),
              label: const Text('★ RATE & REVIEW GARMENTS', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (order.items.isNotEmpty) {
                  AtelierReviewDialog.show(context, order: order, item: order.items.first);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('DOWNLOAD DIGITAL INVOICE'),
            onPressed: () => _showReceiptModal(context),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('REORDER THESE PIECES'),
            onPressed: () {
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
                const SnackBar(
                  content: Text('All pieces added to your shopping bag.'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReceiptModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'N U A N C E',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Color(0xFFC29B38),
                    ),
                  ),
                  Text(
                    'OFFICIAL INVOICE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Order Reference: ${order.id}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Date: ${DateFormat('MMMM d, yyyy • h:mm a').format(order.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}× ${item.product.name} (${item.selectedSize})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'LKR ${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 24),
              _buildSummaryRow('Subtotal', 'LKR ${order.subtotal.toStringAsFixed(2)}'),
              if (order.discount > 0) ...[
                const SizedBox(height: 4),
                _buildSummaryRow('Promotional Voucher', '-LKR ${order.discount.toStringAsFixed(2)}', valueColor: const Color(0xFFC29B38)),
              ],
              const SizedBox(height: 4),
              _buildSummaryRow('Courier Delivery', order.shippingFee == 0 ? 'Complimentary' : 'LKR ${order.shippingFee.toStringAsFixed(2)}'),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Charged', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    'LKR ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFFC29B38),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('PRINT / EXPORT RECEIPT'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digital receipt sent to your registered email.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
