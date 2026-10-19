import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:clothing_store/main.dart';
import 'package:clothing_store/providers/app_state.dart';
import 'package:clothing_store/providers/auth_provider.dart';
import 'package:clothing_store/providers/products_provider.dart';
import 'package:clothing_store/providers/cart_provider.dart';
import 'package:clothing_store/providers/wishlist_provider.dart';
import 'package:clothing_store/providers/admin_provider.dart';
import 'package:clothing_store/models/order.dart';
import 'package:clothing_store/models/product.dart';
import 'package:clothing_store/models/review.dart';
import 'package:clothing_store/services/auth_service.dart';

void main() {
  testWidgets('App smoke test loads brand header', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(create: (_) => ProductsProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: const NuanceApp(),
      ),
    );

    // Initial frame test
    await tester.pumpAndSettle();
    expect(find.byType(NuanceApp), findsOneWidget);
  });

  test('OrderModel deserializes Firestore document map cleanly', () {
    final Map<String, dynamic> firestoreMap = {
      'id': 'ORD-699600',
      'userId': 'Dspe3J7Mo2UnfHwtD8wa2FIQoL32',
      'phoneNumber': '0728289118',
      'shippingAddress': '613/D Daluwakotuwa Kochchikade',
      'paymentMethod': 'Credit Card / Mastercard',
      'subtotal': 340,
      'discount': 34,
      'shippingFee': 0,
      'totalAmount': 306,
      'status': 'placed',
      'createdAt': '2026-10-18T10:31:39.600',
      'items': [
        {
          'id': 'c39ae0cb-2071-4b76-9ada-5fc63193c501',
          'productId': 'prod_001',
          'selectedSize': 'M',
          'quantity': 1,
          'product': {
            'id': 'prod_001',
            'name': 'Nuance Editorial Double-Breasted Suit',
            'brand': 'NUANCE',
            'category': 'Tailored Suits',
            'description': 'Handcrafted suit',
            'price': 340,
            'images': ['assets/images/hero_banner.jpg'],
            'colors': [
              {'name': 'Slate Charcoal', 'colorValue': 4283061608}
            ],
          },
          'selectedColor': {
            'name': 'Slate Charcoal',
            'colorValue': 4283061608,
          },
        }
      ],
    };

    final order = OrderModel.fromMap(firestoreMap);
    expect(order.id, 'ORD-699600');
    expect(order.userId, 'Dspe3J7Mo2UnfHwtD8wa2FIQoL32');
    expect(order.phoneNumber, '0728289118');
    expect(order.shippingAddress, '613/D Daluwakotuwa Kochchikade');
    expect(order.totalAmount, 306.0);
    expect(order.items.length, 1);
    expect(order.items.first.product.name, 'Nuance Editorial Double-Breasted Suit');
  });

  test('AdminProvider authenticates hidden secret credentials and rejects invalid ones', () async {
    final admin = AdminProvider();
    expect(admin.isAuthenticated, false);

    // Wrong credentials
    final failed = await admin.login('wrong', 'badpass');
    expect(failed, false);
    expect(admin.isAuthenticated, false);
    expect(admin.errorMessage, isNotNull);

    // Correct secret credentials
    final success = await admin.login('admin', 'admin123');
    expect(success, true);
    expect(admin.isAuthenticated, true);
    expect(admin.errorMessage, isNull);

    // Logout
    admin.logout();
    expect(admin.isAuthenticated, false);
  });

  test('OrderModel retains courier service name and hotline contact number', () {
    final order = OrderModel(
      id: 'ORD-999999',
      userId: 'user_test_123',
      items: [],
      subtotal: 280,
      shippingFee: 0,
      discount: 0,
      totalAmount: 280,
      shippingAddress: '42 Regent St, Colombo',
      phoneNumber: '+94 77 123 4567',
      paymentMethod: 'Cash on Delivery',
      createdAt: DateTime.now(),
      courierName: 'DHL Express Worldwide',
      courierPhone: '+1 (800) 225-5345',
      trackingNumber: 'DHL-TRK-88219',
      deliveryNotes: 'White glove signature verified',
    );

    final map = order.toMap();
    expect(map['courierName'], 'DHL Express Worldwide');
    expect(map['courierPhone'], '+1 (800) 225-5345');
    expect(map['trackingNumber'], 'DHL-TRK-88219');
    expect(map['deliveryNotes'], 'White glove signature verified');

    final revived = OrderModel.fromMap(map);
    expect(revived.courierName, 'DHL Express Worldwide');
    expect(revived.courierPhone, '+1 (800) 225-5345');
    expect(revived.trackingNumber, 'DHL-TRK-88219');
    expect(revived.deliveryNotes, 'White glove signature verified');
  });

  test('Product model supports SKU, inventory stock count, and copyWith', () {
    final product = Product(
      id: 'prod_test_01',
      name: 'Fluid Silk Slip Dress',
      category: 'Silk & Satin',
      description: 'Handcrafted mulberry silk dress',
      price: 275.0,
      originalPrice: 350.0,
      images: ['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='],
      sizes: ['XS', 'S', 'M', 'L'],
      colors: const [ProductColor(name: 'Champagne Gold', colorValue: 0xFFC29B38)],
      sku: 'NNC-SILK-2026-01',
      stockCount: 28,
    );

    expect(product.sku, 'NNC-SILK-2026-01');
    expect(product.stockCount, 28);
    expect(product.hasDiscount, true);
    expect(product.discountPercentage, 21);

    final map = product.toMap();
    expect(map['sku'], 'NNC-SILK-2026-01');
    expect(map['stockCount'], 28);

    final updated = product.copyWith(stockCount: 14, sku: 'NNC-SILK-2026-UPDATED');
    expect(updated.stockCount, 14);
    expect(updated.sku, 'NNC-SILK-2026-UPDATED');
    expect(updated.name, 'Fluid Silk Slip Dress');
  });

  test('AuthService immediately authenticates admin credentials without Firebase error', () async {
    final auth = AuthService();
    final user = await auth.signInWithEmailAndPassword(
      email: 'admin@nuance.com',
      password: 'admin123',
    );
    expect(user.email, 'admin@nuance.com');
    expect(auth.isAuthenticated, true);
  });

  test('Product model accurately tracks Color x Size variant quantities, low stock, and sold out states', () {
    final inStockProduct = Product(
      id: 'test_variant_prod',
      name: 'Structured Blazer',
      category: 'Blazers',
      description: 'Luxury wool blazer',
      price: 450.0,
      images: ['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='],
      sizes: ['S', 'M', 'L'],
      colors: const [
        ProductColor(name: 'Onyx Black', colorValue: 0xFF111111),
        ProductColor(name: 'Ivory White', colorValue: 0xFFFFFFFF),
      ],
      stockCount: 15,
      variantStock: {
        'Onyx Black_S': 4,
        'Onyx Black_M': 5,
        'Onyx Black_L': 2,
        'Ivory White_S': 1,
        'Ivory White_M': 2,
        'Ivory White_L': 1,
      },
    );

    expect(inStockProduct.totalStock, 15);
    expect(inStockProduct.isSoldOut, false);
    expect(inStockProduct.isLowStock, false);
    expect(inStockProduct.getStockFor('Onyx Black', 'M'), 5);
    expect(inStockProduct.getStockFor('Ivory White', 'S'), 1);

    // Low stock product (<= 5 units total)
    final lowStockProduct = inStockProduct.copyWith(
      stockCount: 3,
      variantStock: {
        'Onyx Black_S': 2,
        'Ivory White_M': 1,
      },
    );
    expect(lowStockProduct.isLowStock, true);
    expect(lowStockProduct.isSoldOut, false);
    expect(lowStockProduct.totalStock, 3);

    // Sold out product
    final soldOutProduct = inStockProduct.copyWith(
      stockCount: 0,
      inStock: false,
      variantStock: {},
    );
    expect(soldOutProduct.isSoldOut, true);
    expect(soldOutProduct.isLowStock, false);
    expect(soldOutProduct.totalStock, 0);
  });

  test('ProductReview model and OrderModel accurately track customer garment ratings', () {
    final review = ProductReview(
      id: 'rev_test_123',
      orderId: 'ORD-319060',
      productId: 'prod_004',
      productName: 'Fluid Silk Satin Slip Maxi Dress',
      userName: 'Amara Fernando',
      rating: 5.0,
      title: 'Perfection in Mulberry Silk',
      comment: 'The drape and texture exceeded all expectations. True to atelier quality.',
      fitFeedback: 'True to Size',
      qualityTag: '100% Pure Silk, Flattering Silhouette',
      createdAt: DateTime.now(),
      isVerifiedPurchase: true,
    );

    expect(review.rating, 5.0);
    expect(review.isVerifiedPurchase, true);
    expect(review.fitFeedback, 'True to Size');

    final map = review.toMap();
    expect(map['id'], 'rev_test_123');
    expect(map['rating'], 5.0);

    final parsed = ProductReview.fromMap(map);
    expect(parsed.comment, review.comment);

    // OrderModel review tracking
    final order = OrderModel(
      id: 'ORD-319060',
      userId: 'user_123',
      items: [],
      subtotal: 275.0,
      shippingFee: 0.0,
      discount: 0.0,
      totalAmount: 275.0,
      shippingAddress: '613/D Daluwakotuwa Kochchikade',
      paymentMethod: 'Credit Card',
      createdAt: DateTime(2026, 10, 18),
      status: OrderStatus.delivered,
      reviewedProductIds: ['prod_004'],
    );

    expect(order.isProductReviewed('prod_004'), true);
    expect(order.isProductReviewed('prod_001'), false);
  });

  test('ProductsProvider synchronizes added, updated, and deleted products cleanly', () {
    final provider = ProductsProvider();

    final customProduct = const Product(
      id: 'prod_custom_99',
      name: 'Custom Atelier Linen Trench',
      category: 'Linen & Resort',
      description: 'Handcrafted bespoke trench coat',
      price: 320.0,
      images: ['https://example.com/trench.png'],
      sizes: ['S', 'M', 'L'],
      colors: [ProductColor(name: 'Natural Flax', colorValue: 0xFFE2D7C5)],
      stockCount: 18,
    );

    // Add Product
    provider.addProduct(customProduct);
    expect(provider.products.any((p) => p.id == 'prod_custom_99'), true);
    expect(provider.products.first.name, 'Custom Atelier Linen Trench');

    // Update Product
    final updatedProduct = customProduct.copyWith(
      name: 'Custom Atelier Linen Trench - Monogrammed',
      price: 350.0,
      stockCount: 22,
    );
    provider.updateProduct(updatedProduct);
    final found = provider.products.firstWhere((p) => p.id == 'prod_custom_99');
    expect(found.name, 'Custom Atelier Linen Trench - Monogrammed');
    expect(found.price, 350.0);
    expect(found.stockCount, 22);

    // Delete Product
    provider.deleteProduct('prod_custom_99');
    expect(provider.products.any((p) => p.id == 'prod_custom_99'), false);
  });

  test('ProductsProvider department catalog filters Women, Men, and Accessories properly', () {
    final provider = ProductsProvider();

    // Default is All
    expect(provider.selectedDepartment, 'All');
    final allCount = provider.filteredProducts.length;
    expect(allCount > 0, true);

    // Filter to Women
    provider.selectDepartment('Women');
    expect(provider.selectedDepartment, 'Women');
    final womenProducts = provider.filteredProducts;
    expect(womenProducts.isNotEmpty, true);
    for (final p in womenProducts) {
      expect(p.department == 'Women' || p.department == 'Unisex', true);
    }

    // Filter to Men
    provider.selectDepartment('Men');
    expect(provider.selectedDepartment, 'Men');
    final menProducts = provider.filteredProducts;
    expect(menProducts.isNotEmpty, true);
    for (final p in menProducts) {
      expect(p.department == 'Men' || p.department == 'Unisex', true);
    }

    // Filter to Accessories
    provider.selectDepartment('Accessories');
    expect(provider.selectedDepartment, 'Accessories');
    final accProducts = provider.filteredProducts;
    expect(accProducts.isNotEmpty, true);
    for (final p in accProducts) {
      final isAcc = p.department == 'Accessories' ||
          p.category.toLowerCase().contains('acc') ||
          p.category.toLowerCase().contains('bag');
      expect(isAcc, true);
    }

    // Reset filters
    provider.resetFilters();
    expect(provider.selectedDepartment, 'All');
    expect(provider.filteredProducts.length, allCount);
  });
}


