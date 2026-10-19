
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/user_model.dart';
import '../models/review.dart';
import 'firebase_service.dart';
import 'mock_data_service.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth =>
      _customAuth ?? FirebaseAuth.instance;

  static List<Product> _localProducts = MockDataService.getInitialProducts();

  static final List<CategoryItem> _localCategories =
      MockDataService.getCategories();

  static final List<OrderModel> _localOrders = [];
  static final List<ProductReview> _localReviews = MockDataService.getInitialReviews();

  bool get _cloudAvailable => _firebaseService.isInitialized;

  // --------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------

  String _requireCurrentUser(String requestedUserId) {
    final user = _auth.currentUser;
    return user?.uid ?? requestedUserId;
  }

  // --------------------------------------------------
  // PRODUCTS
  // --------------------------------------------------

  Future<List<Product>> getProducts() async {
    if (!_cloudAvailable) return _localProducts;

    try {
      final snapshot = await _firestore
          .collection('products')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) {
        debugPrint(
          '[FirestoreService] No cloud products found. '
          'Attempting to auto-seed to Cloud Firestore...',
        );
        await seedInitialData();
        return _localProducts;
      }

      final cloudProducts = snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();

      final Set<String> cloudIds = cloudProducts.map((p) => p.id).toSet();
      final List<Product> merged = List<Product>.from(cloudProducts);
      for (final lp in _localProducts) {
        if (!cloudIds.contains(lp.id)) {
          merged.add(lp);
        }
      }
      _localProducts = merged;

      return _localProducts;
    } catch (e) {
      debugPrint(
        '[FirestoreService] Product fetch failed: $e',
      );
      return _localProducts;
    }
  }

  Stream<List<Product>> streamProducts() {
    if (!_cloudAvailable) {
      return Stream.value(_localProducts);
    }

    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return _localProducts;

      final products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();

      _localProducts = products;
      return products;
    });
  }

  // --------------------------------------------------
  // CATEGORIES
  // --------------------------------------------------

  Future<List<CategoryItem>> getCategories() async {
    if (!_cloudAvailable) return _localCategories;

    try {
      final snapshot = await _firestore
          .collection('categories')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) {
        return _localCategories;
      }

      return snapshot.docs
          .map((doc) => CategoryItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint(
        '[FirestoreService] Category fetch failed: $e',
      );
      return _localCategories;
    }
  }

  // --------------------------------------------------
  // INITIAL CATALOG SEEDING
  // --------------------------------------------------

  // Kept for compatibility with firebase_setup_guide_screen.dart.
  //
  // Firestore rules intentionally prohibit public catalog writes.
  // Use a trusted Firebase Admin SDK script to seed products and
  // categories. Never embed service-account credentials in Flutter.

  Future<void> seedInitialData() async {
    if (!_cloudAvailable) return;

    try {
      final productSnapshot = await _firestore.collection('products').limit(1).get();
      if (productSnapshot.docs.isNotEmpty) {
        debugPrint('[FirestoreService] Cloud catalog already exists in Firestore.');
        return;
      }

      debugPrint('[FirestoreService] Seeding initial products and categories to Cloud Firestore...');
      final batch = _firestore.batch();
      for (final product in _localProducts) {
        batch.set(_firestore.collection('products').doc(product.id), product.toMap());
      }
      for (final category in _localCategories) {
        batch.set(_firestore.collection('categories').doc(category.id), category.toMap());
      }
      await batch.commit().timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Successfully seeded Cloud Firestore!');
    } catch (e) {
      debugPrint('[FirestoreService] Seeding Firestore failed (check Security Rules): $e');
    }
  }

  // --------------------------------------------------
  // CREATE ORDER
  // --------------------------------------------------

  Future<void> createOrder(OrderModel order) async {
    // Keep local cache up to date immediately
    _localOrders.removeWhere((o) => o.id == order.id);
    _localOrders.insert(0, order);

    if (!_cloudAvailable) return;

    try {
      final uid = _requireCurrentUser(order.userId);

      await _firestore
          .collection('orders')
          .doc(order.id)
          .set({
        ...order.toMap(),
        'userId': uid,
      }).timeout(const Duration(seconds: 10));

      debugPrint(
        '[FirestoreService] Order ${order.id} saved to Cloud Firestore.',
      );
    } catch (e) {
      debugPrint(
        '[FirestoreService] Order save failed: $e',
      );
      // Still proceed because order is kept in local state
    }
  }

  // --------------------------------------------------
  // GET USER ORDERS
  // --------------------------------------------------

  Future<List<OrderModel>> getUserOrders(
    String userId,
  ) async {
    if (!_cloudAvailable) {
      return _localOrders
          .where((order) => order.userId == userId || userId.isEmpty)
          .toList();
    }

    try {
      final uid = _requireCurrentUser(userId);

      // Query by current uid
      var snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .get()
          .timeout(const Duration(seconds: 10));

      // Fallback: if empty and requested userId is different, query by requested userId
      if (snapshot.docs.isEmpty && userId.isNotEmpty && userId != uid) {
        snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get()
            .timeout(const Duration(seconds: 10));
      }

      // If still empty (e.g. dev/single user), query all orders if accessible
      if (snapshot.docs.isEmpty) {
        try {
          final allSnapshot = await _firestore
              .collection('orders')
              .limit(20)
              .get()
              .timeout(const Duration(seconds: 5));
          if (allSnapshot.docs.isNotEmpty) {
            snapshot = allSnapshot;
          }
        } catch (_) {}
      }

      final orders = <OrderModel>[];
      for (final doc in snapshot.docs) {
        try {
          orders.add(OrderModel.fromMap(doc.data(), doc.id));
        } catch (e) {
          debugPrint('[FirestoreService] Error parsing order ${doc.id}: $e');
        }
      }

      // Merge with any in-memory orders not yet reflected
      for (final localOrder in _localOrders) {
        if (!orders.any((o) => o.id == localOrder.id)) {
          orders.add(localOrder);
        }
      }

      orders.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return orders;
    } catch (e) {
      debugPrint(
        '[FirestoreService] Order fetch failed, falling back to cache: $e',
      );
      return _localOrders;
    }
  }

  // --------------------------------------------------
  // SAVE USER CART
  // --------------------------------------------------

  Future<void> saveUserCart(
    String userId,
    List<CartItem> items,
  ) async {
    if (!_cloudAvailable) return;

    try {
      final uid = _requireCurrentUser(userId);

      await _firestore.collection('carts').doc(uid).set({
        'userId': uid,
        'items': items.map((item) => item.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));

      debugPrint(
        '[FirestoreService] Cart saved for user $uid.',
      );
    } catch (e) {
      debugPrint(
        '[FirestoreService] Cart save failed: $e',
      );
      rethrow;
    }
  }

  // --------------------------------------------------
  // GET USER CART
  // --------------------------------------------------

  Future<List<CartItem>> getUserCart(
    String userId,
  ) async {
    if (!_cloudAvailable) return [];

    try {
      final uid = _requireCurrentUser(userId);

      final doc = await _firestore
          .collection('carts')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists || doc.data() == null) {
        return [];
      }

      final data = doc.data()!;
      final rawItems = data['items'] as List<dynamic>? ?? [];

      return rawItems.map((item) {
        return CartItem.fromMap(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '[FirestoreService] Cart fetch failed: $e',
      );
      rethrow;
    }
  }

  // --------------------------------------------------
  // CLEAR USER CART
  // --------------------------------------------------

  Future<void> clearUserCart(String userId) async {
    if (!_cloudAvailable) return;

    try {
      final uid = _requireCurrentUser(userId);

      await _firestore
          .collection('carts')
          .doc(uid)
          .delete()
          .timeout(const Duration(seconds: 10));

      debugPrint(
        '[FirestoreService] Cart cleared for user $uid.',
      );
    } catch (e) {
      debugPrint(
        '[FirestoreService] Cart clearing failed: $e',
      );
      rethrow;
    }
  }

  // --------------------------------------------------
  // ADMIN: GET ALL ORDERS
  // --------------------------------------------------

  Future<List<OrderModel>> getAllOrders() async {
    if (!_cloudAvailable) return _localOrders;

    try {
      final snapshot = await _firestore
          .collection('orders')
          .get()
          .timeout(const Duration(seconds: 10));

      final orders = <OrderModel>[];
      for (final doc in snapshot.docs) {
        try {
          orders.add(OrderModel.fromMap(doc.data(), doc.id));
        } catch (e) {
          debugPrint('[FirestoreService] Admin parsing order ${doc.id} failed: $e');
        }
      }

      // Merge any local cache orders
      for (final localOrder in _localOrders) {
        if (!orders.any((o) => o.id == localOrder.id)) {
          orders.add(localOrder);
        }
      }

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      debugPrint('[FirestoreService] Admin getAllOrders failed, fallback: $e');
      return _localOrders;
    }
  }

  // --------------------------------------------------
  // ADMIN: UPDATE ORDER STATUS
  // --------------------------------------------------

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await updateOrderDetails(orderId: orderId, status: newStatus);
  }

  // --------------------------------------------------
  // ADMIN: UPDATE FULL ORDER & COURIER DETAILS
  // --------------------------------------------------

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
    // Update local cache
    final index = _localOrders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final o = _localOrders[index];
      _localOrders[index] = o.copyWith(
        status: status ?? o.status,
        courierName: courierName ?? o.courierName,
        courierPhone: courierPhone ?? o.courierPhone,
        trackingNumber: trackingNumber ?? o.trackingNumber,
        shippingAddress: shippingAddress ?? o.shippingAddress,
        phoneNumber: customerPhone ?? o.phoneNumber,
        deliveryNotes: deliveryNotes ?? o.deliveryNotes,
      );
    }

    if (!_cloudAvailable) return;

    try {
      final Map<String, dynamic> updateData = {};
      if (status != null) updateData['status'] = status.name;
      if (courierName != null) updateData['courierName'] = courierName;
      if (courierPhone != null) updateData['courierPhone'] = courierPhone;
      if (trackingNumber != null) updateData['trackingNumber'] = trackingNumber;
      if (shippingAddress != null) updateData['shippingAddress'] = shippingAddress;
      if (customerPhone != null) updateData['phoneNumber'] = customerPhone;
      if (deliveryNotes != null) updateData['deliveryNotes'] = deliveryNotes;

      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updateData)
          .timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Order $orderId dispatch details updated.');
    } catch (e) {
      debugPrint('[FirestoreService] Admin updateOrderDetails failed: $e');
    }
  }

  // --------------------------------------------------
  // ADMIN: PRODUCT MANAGEMENT (CRUD)
  // --------------------------------------------------

  Future<void> addProduct(Product product) async {
    _localProducts.removeWhere((p) => p.id == product.id);
    _localProducts.insert(0, product);
    if (!_cloudAvailable) return;

    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toMap())
          .timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Product ${product.id} added.');
    } catch (e) {
      debugPrint('[FirestoreService] Admin addProduct failed: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _localProducts[index] = product;
    }
    if (!_cloudAvailable) return;

    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toMap())
          .timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Product ${product.id} updated.');
    } catch (e) {
      debugPrint('[FirestoreService] Admin updateProduct failed: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    _localProducts.removeWhere((p) => p.id == productId);
    if (!_cloudAvailable) return;

    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .delete()
          .timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Product $productId deleted.');
    } catch (e) {
      debugPrint('[FirestoreService] Admin deleteProduct failed: $e');
    }
  }

  // --------------------------------------------------
  // ADMIN: GET ALL USERS / CUSTOMERS
  // --------------------------------------------------

  Future<List<UserModel>> getAllUsers() async {
    if (!_cloudAvailable) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('[FirestoreService] Admin getAllUsers failed: $e');
      return [];
    }
  }

  // --------------------------------------------------
  // REVIEWS & PARCEL CONFIRMATION
  // --------------------------------------------------

  Future<void> saveReview(ProductReview review) async {
    // Add to local review cache
    _localReviews.removeWhere((r) => r.id == review.id);
    _localReviews.insert(0, review);

    // Mark product as reviewed in order
    await markProductReviewedInOrder(review.orderId, review.productId);

    if (!_cloudAvailable) return;

    try {
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .set(review.toMap())
          .timeout(const Duration(seconds: 10));
      debugPrint('[FirestoreService] Review ${review.id} saved.');
    } catch (e) {
      debugPrint('[FirestoreService] Save review failed: $e');
    }
  }

  Future<List<ProductReview>> getProductReviews(String productId) async {
    final matchingLocal = _localReviews.where((r) => r.productId == productId).toList();
    if (!_cloudAvailable) return matchingLocal;

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get()
          .timeout(const Duration(seconds: 8));

      final cloudReviews = <ProductReview>[];
      for (final doc in snapshot.docs) {
        cloudReviews.add(ProductReview.fromMap(doc.data(), doc.id));
      }

      // Merge local reviews not yet in cloud
      for (final lr in matchingLocal) {
        if (!cloudReviews.any((r) => r.id == lr.id)) {
          cloudReviews.add(lr);
        }
      }

      cloudReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cloudReviews;
    } catch (e) {
      debugPrint('[FirestoreService] getProductReviews fallback: $e');
      return matchingLocal;
    }
  }

  Future<void> markProductReviewedInOrder(String orderId, String productId) async {
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final o = _localOrders[idx];
      if (!o.reviewedProductIds.contains(productId)) {
        final updatedIds = List<String>.from(o.reviewedProductIds)..add(productId);
        _localOrders[idx] = o.copyWith(reviewedProductIds: updatedIds);
      }
    }

    if (!_cloudAvailable) return;
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'reviewedProductIds': FieldValue.arrayUnion([productId]),
      }).timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('[FirestoreService] markProductReviewedInOrder failed: $e');
    }
  }

  Future<void> confirmParcelReceived(String orderId) async {
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _localOrders[idx] = _localOrders[idx].copyWith(status: OrderStatus.delivered);
    }

    if (!_cloudAvailable) return;
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.delivered.name,
      }).timeout(const Duration(seconds: 6));
      debugPrint('[FirestoreService] Order $orderId marked as DELIVERED by customer.');
    } catch (e) {
      debugPrint('[FirestoreService] confirmParcelReceived failed: $e');
    }
  }
}
