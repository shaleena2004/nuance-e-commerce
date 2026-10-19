import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../main_nav_screen.dart';
import 'order_details_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deliveryDate = DateTime.now().add(const Duration(days: 4));
    final formattedDelivery = DateFormat('EEEE, MMMM d, yyyy').format(deliveryDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Return to Home',
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 1. Luxury Checkmark Avatar
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC29B38),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 42,
                    color: Color(0xFFC29B38),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'EXQUISITE CHOICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.5,
                  color: Color(0xFFC29B38),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Order Placed Successfully',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your patronage. Your order ${order.id} is registered in Cloud Firestore and being tailored.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Ordered Pieces Preview
              if (order.items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
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
                            'ORDERED PIECES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: Color(0xFFC29B38),
                            ),
                          ),
                          Text(
                            '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Size ${item.selectedSize} • ${item.selectedColor.name} • Qty ${item.quantity}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 3. Delivery & Courier Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Order Reference', order.id, isHighlight: true),
                    const Divider(height: 18),
                    _buildInfoRow('Estimated Delivery', formattedDelivery),
                    const Divider(height: 18),
                    _buildInfoRow(
                      'Shipping Destination',
                      order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Recorded on file',
                    ),
                    const Divider(height: 18),
                    _buildInfoRow(
                      'Courier Phone',
                      order.phoneNumber.isNotEmpty ? order.phoneNumber : 'Recorded on profile',
                    ),
                    const Divider(height: 18),
                    _buildInfoRow('Payment Method', order.paymentMethod),
                    const Divider(height: 18),
                    _buildInfoRow(
                      'Total Paid',
                      'LKR ${order.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  label: const Text('VIEW FULL ORDER DETAILS'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('VIEW PURCHASE ARCHIVE'),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavScreen(initialIndex: 2),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('CONTINUE SHOPPING', style: TextStyle(letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AtelierBottomNavBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isBold ? 15 : 12,
              fontWeight: (isBold || isHighlight) ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFFC29B38)
                  : isBold
                      ? const Color(0xFFC29B38)
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
