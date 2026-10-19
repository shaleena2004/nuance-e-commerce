import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  final List<CartItem> _items = [];
  String? _currentUserId = 'demo_user_01';
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  String? get appliedPromoCode => _appliedPromoCode;
  bool get isLoading => _isLoading;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => _promoDiscount;

  // Free shipping above $250
  double get shippingFee {
    if (_items.isEmpty) return 0.0;
    return subtotal >= 250.0 ? 0.0 : 15.0;
  }

  double get grandTotal {
    final total = subtotal - discountAmount + shippingFee;
    return total > 0 ? total : 0.0;
  }

  void setUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null && userId.isNotEmpty) {
        loadUserCart(userId);
      }
    }
  }

  Future<void> loadUserCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firestoreItems = await _firestoreService.getUserCart(userId);
      if (firestoreItems.isNotEmpty) {
        _items.clear();
        _items.addAll(firestoreItems);
        _recalculateDiscounts();
      }
    } catch (e) {
      debugPrint('[CartProvider] Load user cart error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncWithFirestore() {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      _firestoreService.saveUserCart(_currentUserId!, _items);
    }
  }

  void addToCart({
    required Product product,
    required String selectedSize,
    required ProductColor selectedColor,
    int quantity = 1,
  }) {
    // Check if duplicate item exists
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor.colorValue == selectedColor.colorValue,
    );

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: _uuid.v4(),
          product: product,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          quantity: quantity,
        ),
      );
    }

    _recalculateDiscounts();
    _syncWithFirestore();
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      _recalculateDiscounts();
      _syncWithFirestore();
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _recalculateDiscounts();
    _syncWithFirestore();
    notifyListeners();
  }

  bool applyPromo(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'NUANCE10') {
      _appliedPromoCode = cleanCode;
      _promoDiscount = subtotal * 0.10; // 10% off
      notifyListeners();
      return true;
    } else if (cleanCode == 'VOGUE25') {
      _appliedPromoCode = cleanCode;
      _promoDiscount = 25.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromo() {
    _appliedPromoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  void _recalculateDiscounts() {
    if (_appliedPromoCode == 'NUANCE10') {
      _promoDiscount = subtotal * 0.10;
    } else if (_appliedPromoCode == 'VOGUE25') {
      _promoDiscount = subtotal > 25.0 ? 25.0 : subtotal;
    } else {
      _promoDiscount = 0.0;
    }
  }

  Future<OrderModel> checkout({
    required String userId,
    required String address,
    String phoneNumber = '',
    required String paymentMethod,
    String customerName = '',
  }) async {
    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: userId,
      items: List.from(_items),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discountAmount,
      totalAmount: grandTotal,
      shippingAddress: address,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      customerName: customerName,
      createdAt: DateTime.now(),
    );

    // Save order to Firestore
    await _firestoreService.createOrder(order);

    // Clear cart in Firestore
    await _firestoreService.clearUserCart(userId);

    // Clear cart locally
    _items.clear();
    _appliedPromoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();

    return order;
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _promoDiscount = 0.0;
    _syncWithFirestore();
    notifyListeners();
  }
}
