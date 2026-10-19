import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../services/firestore_service.dart';
import '../services/mock_data_service.dart';

enum ProductSortOption {
  featured,
  priceLowToHigh,
  priceHighToLow,
  rating,
  newest,
}

class ProductsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _products = MockDataService.getInitialProducts();
  List<CategoryItem> _categories = MockDataService.getCategories();
  bool _isLoading = false;
  String _selectedDepartment = 'All'; // 'All', 'Women', 'Men', 'Accessories', 'Last Chance'
  String _selectedCategory = 'All';
  String _searchQuery = '';
  ProductSortOption _sortOption = ProductSortOption.featured;
  RangeValues _priceRange = const RangeValues(50, 600);

  List<Product> get products => _products;
  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedDepartment => _selectedDepartment;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  ProductSortOption get sortOption => _sortOption;
  RangeValues get priceRange => _priceRange;

  void selectDepartment(String dept) {
    if (_selectedDepartment == dept) return;
    _selectedDepartment = dept;
    _selectedCategory = 'All';
    _normalizeCategories();
    notifyListeners();
  }

  ProductsProvider() {
    _normalizeCategories();
    loadData();
  }

  Future<void> loadData() async {
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fetchedProducts = await _firestoreService.getProducts();
      final fetchedCategories = await _firestoreService.getCategories();
      if (fetchedProducts.isNotEmpty) {
        _products = fetchedProducts;
      }
      if (fetchedCategories.isNotEmpty) {
        _categories = fetchedCategories;
      }
      _normalizeCategories();
    } catch (e) {
      debugPrint('[ProductsProvider] Load data error: $e');
      _normalizeCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _normalizeCategories() {
    IconData getIcon(String name) {
      switch (name.toLowerCase()) {
        case 'all':
          return Icons.grid_view_rounded;
        case 'tailored suits':
        case 'tailored':
          return Icons.business_center_rounded;
        case 'outerwear':
          return Icons.dry_cleaning_rounded;
        case 'linen & resort':
        case 'linen':
          return Icons.wb_sunny_rounded;
        case 'knitwear':
          return Icons.texture_rounded;
        case 'bags & acc':
        case 'accessories':
        case 'luxury accessories':
          return Icons.shopping_bag_outlined;
        case 'silk & satin':
        case 'silk & evening':
        case 'evening wear':
          return Icons.auto_awesome_rounded;
        default:
          return Icons.checkroom_rounded;
      }
    }

    String getImage(String name) {
      switch (name.toLowerCase()) {
        case 'tailored suits':
          return 'assets/images/hero_banner.jpg';
        case 'outerwear':
          return 'assets/images/menswear_jacket.jpg';
        case 'linen & resort':
          return 'assets/images/summer_collection.jpg';
        case 'knitwear':
          return 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=600&q=80';
        case 'bags & acc':
        case 'accessories':
        case 'luxury accessories':
          return 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80';
        case 'silk & satin':
        case 'evening wear':
          return 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1000&q=80';
        default:
          final matched = _products.where((p) => p.category.toLowerCase() == name.toLowerCase() && p.mainImage.isNotEmpty);
          if (matched.isNotEmpty) {
            return matched.first.mainImage;
          }
          return 'assets/images/hero_banner.jpg';
      }
    }

    final deptProducts = _products.where((p) {
      if (_selectedDepartment == 'Women') return p.department == 'Women' || p.department == 'Unisex';
      if (_selectedDepartment == 'Men') return p.department == 'Men' || p.department == 'Unisex';
      if (_selectedDepartment == 'Accessories') {
        return p.department == 'Accessories' ||
            p.category.toLowerCase().contains('acc') ||
            p.category.toLowerCase().contains('bag');
      }
      if (_selectedDepartment == 'Last Chance') return p.hasDiscount || p.isLowStock;
      return true;
    }).toList();

    final List<CategoryItem> normalized = [
      CategoryItem(
        id: 'cat_all',
        name: 'All',
        icon: Icons.grid_view_rounded,
        image: 'assets/images/hero_banner.jpg',
        itemCount: deptProducts.length,
      ),
    ];

    final Set<String> added = {'All'};

    final nonAllCategories = _categories.where((c) => c.name != 'All').toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final cat in nonAllCategories) {
      final count = deptProducts.where((p) => p.category.toLowerCase() == cat.name.toLowerCase()).length;
      if (count > 0 || _selectedDepartment == 'All') {
        if (!added.contains(cat.name)) {
          added.add(cat.name);
          normalized.add(CategoryItem(
            id: cat.id,
            name: cat.name,
            icon: cat.icon != Icons.checkroom_rounded ? cat.icon : getIcon(cat.name),
            image: cat.image.isNotEmpty ? cat.image : getImage(cat.name),
            itemCount: count,
          ));
        }
      }
    }

    for (final prod in deptProducts) {
      final catName = prod.category.trim();
      if (catName.isNotEmpty && !added.contains(catName)) {
        added.add(catName);
        final count = deptProducts.where((p) => p.category.toLowerCase() == catName.toLowerCase()).length;
        normalized.add(CategoryItem(
          id: 'cat_${catName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
          name: catName,
          icon: getIcon(catName),
          image: getImage(catName),
          itemCount: count,
        ));
      }
    }

    _categories = normalized;
  }

  void addCategory(String categoryName) {
    final trimmed = categoryName.trim();
    if (trimmed.isEmpty) return;
    if (!_categories.any((c) => c.name.toLowerCase() == trimmed.toLowerCase())) {
      _categories.add(CategoryItem(
        id: 'cat_${trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
        name: trimmed,
        icon: Icons.checkroom_rounded,
        image: 'assets/images/hero_banner.jpg',
        itemCount: 0,
      ));
      _normalizeCategories();
      notifyListeners();
    }
  }

  void selectCategory(String categoryName) {
    _selectedCategory = categoryName;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _selectedDepartment = 'All';
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortOption = ProductSortOption.featured;
    _priceRange = const RangeValues(50, 600);
    _normalizeCategories();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> get featuredProducts {
    var list = _products.where((p) => p.isFeatured);
    if (_selectedDepartment == 'Women') {
      list = list.where((p) => p.department == 'Women' || p.department == 'Unisex');
    } else if (_selectedDepartment == 'Men') {
      list = list.where((p) => p.department == 'Men' || p.department == 'Unisex');
    } else if (_selectedDepartment == 'Accessories') {
      list = list.where((p) => p.department == 'Accessories' || p.category.toLowerCase().contains('acc') || p.category.toLowerCase().contains('bag'));
    } else if (_selectedDepartment == 'Last Chance') {
      list = list.where((p) => p.hasDiscount || p.isLowStock);
    }
    return list.toList();
  }

  List<Product> get newArrivals {
    var list = _products.where((p) => p.isNew);
    if (_selectedDepartment == 'Women') {
      list = list.where((p) => p.department == 'Women' || p.department == 'Unisex');
    } else if (_selectedDepartment == 'Men') {
      list = list.where((p) => p.department == 'Men' || p.department == 'Unisex');
    } else if (_selectedDepartment == 'Accessories') {
      list = list.where((p) => p.department == 'Accessories' || p.category.toLowerCase().contains('acc') || p.category.toLowerCase().contains('bag'));
    } else if (_selectedDepartment == 'Last Chance') {
      list = list.where((p) => p.hasDiscount || p.isLowStock);
    }
    return list.toList();
  }

  List<Product> get filteredProducts {
    var list = _products.where((p) {
      // Department filter
      if (_selectedDepartment == 'Women') {
        if (p.department != 'Women' && p.department != 'Unisex') return false;
      } else if (_selectedDepartment == 'Men') {
        if (p.department != 'Men' && p.department != 'Unisex') return false;
      } else if (_selectedDepartment == 'Accessories') {
        final isAcc = p.department == 'Accessories' ||
            p.category.toLowerCase().contains('acc') ||
            p.category.toLowerCase().contains('bag');
        if (!isAcc) return false;
      } else if (_selectedDepartment == 'Last Chance') {
        if (!p.hasDiscount && !p.isLowStock) return false;
      }

      // Category filter
      if (_selectedCategory != 'All' && p.category != _selectedCategory) {
        return false;
      }
      // Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesDesc = p.description.toLowerCase().contains(query);
        final matchesCategory = p.category.toLowerCase().contains(query);
        final matchesDept = p.department.toLowerCase().contains(query);
        if (!matchesName && !matchesDesc && !matchesCategory && !matchesDept) {
          return false;
        }
      }
      // Price range
      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }
      return true;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case ProductSortOption.featured:
        list.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
        break;
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.newest:
        list.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
        break;
    }

    return list;
  }

  // --------------------------------------------------
  // REVIEWS & RATINGS
  // --------------------------------------------------

  final Map<String, List<ProductReview>> _productReviews = {};

  List<ProductReview> getReviewsForProduct(String productId) {
    if (_productReviews.containsKey(productId)) {
      return _productReviews[productId]!;
    }
    final initial = MockDataService.getInitialReviews()
        .where((r) => r.productId == productId)
        .toList();
    _productReviews[productId] = initial;
    return initial;
  }

  Future<void> addProductReview(ProductReview review) async {
    final list = _productReviews.putIfAbsent(review.productId, () => []);
    list.removeWhere((r) => r.id == review.id);
    list.insert(0, review);

    // Persist via FirestoreService
    await _firestoreService.saveReview(review);

    // Update rating & reviews count on product
    final index = _products.indexWhere((p) => p.id == review.productId);
    if (index >= 0) {
      final old = _products[index];
      final newCount = old.reviewsCount + 1;
      final newRating = double.parse(
        (((old.rating * old.reviewsCount) + review.rating) / newCount)
            .toStringAsFixed(1),
      );
      final updated = old.copyWith(
        rating: newRating,
        reviewsCount: newCount,
      );
      _products[index] = updated;
      _firestoreService.updateProduct(updated);
    }
    notifyListeners();
  }

  // --------------------------------------------------
  // CATALOG CRUD SYNCHRONIZATION
  // --------------------------------------------------

  void addProduct(Product product) {
    _products.removeWhere((p) => p.id == product.id);
    _products.insert(0, product);
    _normalizeCategories();
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      _products.insert(0, product);
    }
    _normalizeCategories();
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _normalizeCategories();
    notifyListeners();
  }
}

