import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_image.dart';
import '../orders/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedPaymentMethod = 'Apple Pay';
  String _deliveryType = 'Standard Express (Complimentary)';
  bool _isProcessing = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        if (_phoneController.text.isEmpty && user.phoneNumber.isNotEmpty) {
          _phoneController.text = user.phoneNumber;
        }
        if (_addressController.text.isEmpty && user.address.isNotEmpty) {
          _addressController.text = user.address;
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final deliveryFee = _deliveryType.contains('White Glove') ? 25.0 : 0.0;
    final finalTotal = cartProvider.grandTotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECKOUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Banner
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC29B38).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC29B38).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: Color(0xFFC29B38), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ordering as ${user.displayName} (${user.email})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC29B38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 1. Phone & Shipping Address Inputs (Before Order Products)
            _buildSectionTitle('DELIVERY DESTINATION & CONTACT'),
            const SizedBox(height: 10),

            // Phone Number
            const Text(
              'PHONE NUMBER (FOR COURIER UPDATES)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+1 (555) 019-2834',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 18),

            // Shipping Address
            const Text(
              'SHIPPING ADDRESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Street, Apartment, City, State, ZIP',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Pieces In This Order (Order Products)
            _buildSectionTitle('PIECES IN THIS ORDER'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE),
                ),
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cartProvider.items.length,
                separatorBuilder: (context, index) => const Divider(height: 18),
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 54,
                          height: 64,
                          child: CustomImage(
                            imagePath: item.product.images.isNotEmpty
                                ? item.product.images.first
                                : '',
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
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: ${item.selectedSize} • Color: ${item.selectedColor.name}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item.quantity} × LKR ${item.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC29B38),
                              ),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 3. Delivery Service
            _buildSectionTitle('DELIVERY SERVICE'),
            const SizedBox(height: 8),
            _buildDeliveryOption(
              title: 'Standard Atelier Delivery',
              subtitle: 'Delivered within 3 - 5 business days',
              price: 'Complimentary',
              value: 'Standard Express (Complimentary)',
            ),
            const SizedBox(height: 8),
            _buildDeliveryOption(
              title: 'White Glove Same-Day Courier',
              subtitle: 'Hand-delivered with garment bag today',
              price: 'LKR 25.00',
              value: 'White Glove Courier',
            ),
            const SizedBox(height: 24),

            // 4. Payment Methods
            _buildSectionTitle('PAYMENT METHOD'),
            const SizedBox(height: 8),
            _buildPaymentOption('Apple Pay', Icons.apple_rounded),
            const SizedBox(height: 8),
            _buildPaymentOption('Credit Card / Mastercard', Icons.credit_card_rounded),
            const SizedBox(height: 8),
            _buildPaymentOption('Cash on Delivery', Icons.payments_outlined),
            const SizedBox(height: 24),

            // 5. Order Review
            _buildSectionTitle('ORDER BREAKDOWN'),
            const SizedBox(height: 8),
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
                  _buildSummaryRow('Pieces', '${cartProvider.itemCount} items'),
                  const SizedBox(height: 6),
                  _buildSummaryRow(
                      'Subtotal', 'LKR ${cartProvider.subtotal.toStringAsFixed(2)}'),
                  if (cartProvider.discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'Discount',
                      '-LKR ${cartProvider.discountAmount.toStringAsFixed(2)}',
                      valueColor: const Color(0xFFC29B38),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildSummaryRow(
                    'Delivery',
                    deliveryFee == 0 ? 'Complimentary' : 'LKR 25.00',
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'LKR ${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC29B38),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Confirm & Place Order Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        final phone = _phoneController.text.trim();
                        final address = _addressController.text.trim();

                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your phone number for courier updates.'),
                            ),
                          );
                          return;
                        }

                        if (address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your complete shipping address.'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isProcessing = true;
                        });

                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          // Update user profile in Firestore
                          await authProvider.updateProfile(
                            phone: phone,
                            address: address,
                          );

                          // Create order in Firestore
                          final order = await cartProvider.checkout(
                            userId: user?.id ?? 'member_user',
                            address: address,
                            phoneNumber: phone,
                            paymentMethod: _selectedPaymentMethod,
                            customerName: (user?.displayName.isNotEmpty ?? false)
                                ? user!.displayName
                                : 'Valued Client',
                          );

                          if (mounted) {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => OrderSuccessScreen(order: order),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Failed to place order: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        }
                      },
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'CONFIRM & PAY • LKR ${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Color(0xFFC29B38),
      ),
    );
  }

  Widget _buildDeliveryOption({
    required String title,
    required String subtitle,
    required String price,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _deliveryType == value;

    return GestureDetector(
      onTap: () => setState(() => _deliveryType = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC29B38)
                : (isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFC29B38) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPaymentMethod == name;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC29B38)
                : (isDark ? const Color(0xFF28282D) : const Color(0xFFEEEEEE)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFC29B38) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFC29B38) : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}
