import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> _orders = [];
  List<Product> _products = [];
  List<UserModel> _customers = [];

  // Hidden credentials
  static const String secretAdminEmail = 'admin@nuance.com';
  static const String secretAdminUsername = 'admin';
  static const String secretAdminPassword = 'admin123';
  static const String secondaryPassword = 'nuance2026';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<OrderModel> get orders => _orders;
  List<Product> get products => _products;
  List<UserModel> get customers => _customers;

  // KPIs
  double get totalRevenue => _orders.fold(0.0, (sum, o) => sum + o.totalAmount);
  int get totalOrdersCount => _orders.length;
  int get pendingOrdersCount => _orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
  int get deliveredOrdersCount => _orders.where((o) => o.status == OrderStatus.delivered).length;
  int get totalProductsCount => _products.length;
  int get totalCustomersCount => _customers.length;

  Future<bool> login(String username, String password) async {
    final cleanUser = username.trim().toLowerCase();
    final cleanPass = password.trim();

    if ((cleanUser == secretAdminUsername || cleanUser == secretAdminEmail) &&
        (cleanPass == secretAdminPassword || cleanPass == secondaryPassword)) {
      _isAuthenticated = true;
      _errorMessage = null;
      notifyListeners();
      await fetchAllData();
      return true;
    } else {
      _errorMessage = 'Invalid secret credentials. Access denied.';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _orders = [];
    _products = [];
    _customers = [];
    notifyListeners();
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await _firestoreService.getAllOrders();
      final fetchedProducts = await _firestoreService.getProducts();
      final fetchedUsers = await _firestoreService.getAllUsers();

      _orders = fetchedOrders;
      _products = fetchedProducts;
      _customers = fetchedUsers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading admin data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await updateOrderDetails(orderId: orderId, status: newStatus);
  }

  Future<void> updateOrderDetails({
    required String orderId,
    OrderStatus? status,
    String? courierName,
    String? courierPhone,
    String? trackingNumber,
    String? shippingAddress,
    String? customerPhone,
    String? deliveryNotes,
  }) async {
    try {
      await _firestoreService.updateOrderDetails(
        orderId: orderId,
        status: status,
        courierName: courierName,
        courierPhone: courierPhone,
        trackingNumber: trackingNumber,
        shippingAddress: shippingAddress,
        customerPhone: customerPhone,
        deliveryNotes: deliveryNotes,
      );
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        final o = _orders[index];
        _orders[index] = o.copyWith(
          status: status ?? o.status,
          courierName: courierName ?? o.courierName,
          courierPhone: courierPhone ?? o.courierPhone,
          trackingNumber: trackingNumber ?? o.trackingNumber,
          shippingAddress: shippingAddress ?? o.shippingAddress,
          phoneNumber: customerPhone ?? o.phoneNumber,
          deliveryNotes: deliveryNotes ?? o.deliveryNotes,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AdminProvider] Update order details failed: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestoreService.addProduct(product);
      _products.insert(0, product);
      notifyListeners();
    } catch (e) {
      debugPrint('[AdminProvider] Add product failed: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestoreService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AdminProvider] Update product failed: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('[AdminProvider] Delete product failed: $e');
    }
  }
}
