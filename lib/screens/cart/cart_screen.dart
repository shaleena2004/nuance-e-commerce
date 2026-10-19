import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_image.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  bool _isPromoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOPPING BAG'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              tooltip: 'Clear Bag',
              onPressed: () {
                _confirmClearCart(context);
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyBag(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 80,
                                height: 95,
                                child: CustomImage(
                                  imagePath: item.product.mainImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.product.brand.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                          color: Color(0xFFC29B38),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          cartProvider.removeItem(item.id);
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Selected variant details (Size & Color)
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF24242A)
                                              : const Color(0xFFEDEDF0),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Size: ${item.selectedSize}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: item.selectedColor.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.selectedColor.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white54 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Price & Quantity control
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'LKR ${item.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF222227)
                                              : const Color(0xFFF1F1F4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                  minWidth: 32, minHeight: 32),
                                              icon: const Icon(Icons.remove, size: 14),
                                              onPressed: () {
                                                cartProvider.updateQuantity(
                                                    item.id, item.quantity - 1);
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                  minWidth: 32, minHeight: 32),
                                              icon: const Icon(Icons.add, size: 14),
                                              onPressed: () {
                                                cartProvider.updateQuantity(
                                                    item.id, item.quantity + 1);
                                              },
                                            ),
                                          ],
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
                  ),
                ),

                // Bottom Checkout & Promo Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF242428) : const Color(0xFFEEEEEE),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Promo code bar
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: 'Promo code (try NUANCE10)',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 42,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (_promoController.text.trim().isEmpty) return;
                                  final success = cartProvider
                                      .applyPromo(_promoController.text.trim());
                                  setState(() {
                                    _isPromoSuccess = success;
                                    _promoMessage = success
                                        ? 'Applied successfully!'
                                        : 'Invalid coupon code';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: const Text('Apply', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                        if (_promoMessage != null) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _promoMessage!,
                              style: TextStyle(
                                fontSize: 11,
                                color: _isPromoSuccess
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Subtotal & Calculations
                        _buildCalculationRow(
                          'Subtotal',
                          'LKR ${cartProvider.subtotal.toStringAsFixed(2)}',
                        ),
                        if (cartProvider.discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          _buildCalculationRow(
                            'Privilege Discount (${cartProvider.appliedPromoCode})',
                            '-LKR ${cartProvider.discountAmount.toStringAsFixed(2)}',
                            color: const Color(0xFFC29B38),
                          ),
                        ],
                        const SizedBox(height: 6),
                        _buildCalculationRow(
                          'Shipping',
                          cartProvider.shippingFee == 0
                              ? 'COMPLIMENTARY'
                              : 'LKR ${cartProvider.shippingFee.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: isDark ? const Color(0xFF28282D) : const Color(0xFFE5E5E5),
                        ),
                        const SizedBox(height: 6),

                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'LKR ${cartProvider.grandTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ),
                              );
                            },
                            child: const Text('PROCEED TO CHECKOUT'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {Color? color}) {
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
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBag(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 18),
          const Text(
            'Your shopping bag is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore our luxury wardrobe and discover enduring design',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('EXPLORE CATALOGUE'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Shopping Bag?'),
        content: const Text(
          'Are you sure you want to remove all items from your bag?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
