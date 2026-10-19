import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/custom_image.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  late String _selectedSize;
  late ProductColor _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 'M';
    _selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : const ProductColor(name: 'Default', colorValue: 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final productsProv = context.watch<ProductsProvider>();
    final product = productsProv.products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
    final reviews = productsProv.getReviewsForProduct(product.id);
    final isFav = wishlistProvider.isFavorite(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 460,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark ? Colors.black54 : Colors.white70,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: isDark ? Colors.black54 : Colors.white70,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 20,
                      color: isFav ? const Color(0xFFE53935) : (isDark ? Colors.white : Colors.black),
                    ),
                    onPressed: () {
                      context.read<WishlistProvider>().toggleFavorite(widget.product);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: widget.product.images.isNotEmpty
                        ? widget.product.images.length
                        : 1,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final image = widget.product.images.isNotEmpty
                          ? widget.product.images[index]
                          : '';
                      return Hero(
                        tag: index == 0
                            ? 'product_image_${widget.product.id}'
                            : 'product_image_${widget.product.id}_$index',
                        child: CustomImage(
                          imagePath: image,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  // Carousel Dots Indicator
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _selectedImageIndex == index ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _selectedImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Info Body
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFFC29B38),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFA000)),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${reviews.length} reviews)',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'LKR ${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (widget.product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          'LKR ${widget.product.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SAVE ${widget.product.discountPercentage}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (widget.product.isSoldOut) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8)),
                          ),
                          child: const Text(
                            'SOLD OUT',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ] else if (widget.product.isLowStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC29B38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ALMOST SOLD OUT (${widget.product.totalStock} LEFT)',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: isDark ? const Color(0xFF242428) : const Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // Color Selection
                  Text(
                    'Color: ${_selectedColor.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: widget.product.colors.map((color) {
                      final isSelected = _selectedColor.colorValue == color.colorValue;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.colorValue == 0xFFFFFFFF
                                    ? Colors.grey.shade400
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: color.colorValue == 0xFFFFFFFF
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Size',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showSizeGuideModal(context);
                        },
                        child: const Text(
                          'Size Guide',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC29B38),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: widget.product.sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 50,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white : const Color(0xFF141416))
                                : (isDark ? const Color(0xFF202024) : const Color(0xFFF3F3F5)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : const Color(0xFF141416))
                                  : (isDark ? const Color(0xFF323238) : const Color(0xFFE2E2E6)),
                            ),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Variant Inventory Stock Status Card
                  Builder(
                    builder: (context) {
                      final variantStock = widget.product.getStockFor(_selectedColor.name, _selectedSize);
                      final isVariantSoldOut = widget.product.isSoldOut || variantStock <= 0;
                      final isVariantLow = !widget.product.isSoldOut && variantStock > 0 && variantStock <= 3;

                      Color badgeBg;
                      Color borderColor;
                      Color textColor;
                      IconData icon;
                      String message;

                      if (widget.product.isSoldOut) {
                        badgeBg = Colors.red.withValues(alpha: 0.12);
                        borderColor = Colors.redAccent.withValues(alpha: 0.4);
                        textColor = Colors.redAccent;
                        icon = Icons.cancel_outlined;
                        message = 'This garment is completely Sold Out in all sizes and shades.';
                      } else if (isVariantSoldOut) {
                        badgeBg = Colors.red.withValues(alpha: 0.12);
                        borderColor = Colors.redAccent.withValues(alpha: 0.4);
                        textColor = Colors.redAccent;
                        icon = Icons.error_outline_rounded;
                        message = 'Size $_selectedSize in ${_selectedColor.name} is Sold Out. Select an alternate size.';
                      } else if (isVariantLow) {
                        badgeBg = const Color(0xFFC29B38).withValues(alpha: 0.15);
                        borderColor = const Color(0xFFC29B38).withValues(alpha: 0.5);
                        textColor = const Color(0xFFC29B38);
                        icon = Icons.bolt_rounded;
                        message = 'Almost Sold Out — Only $variantStock remaining in Size $_selectedSize (${_selectedColor.name})!';
                      } else {
                        badgeBg = isDark ? const Color(0xFF1E261E) : const Color(0xFFEAF5EA);
                        borderColor = Colors.green.withValues(alpha: 0.35);
                        textColor = Colors.green.shade400;
                        icon = Icons.check_circle_outline_rounded;
                        message = 'In Stock: $variantStock available in Size $_selectedSize (${_selectedColor.name})';
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, size: 16, color: textColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description & Fit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quality & Delivery Assurances
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          Icons.local_shipping_outlined,
                          'Complimentary Shipping',
                          'Free express shipping on orders over LKR 250',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.published_with_changes_rounded,
                          '30-Day Effortless Returns',
                          'Pre-paid returns label included in every box',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureRow(
                          Icons.verified_outlined,
                          'Certified Craftsmanship',
                          'Responsibly sourced luxury textiles',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Client Reviews Section
                  _buildReviewsSection(context, isDark, product, reviews),
                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar with Quantity & Add to Cart
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF242428) : const Color(0xFFEEEEEE),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Quantity Selector
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF202024) : const Color(0xFFF1F1F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Add to Cart Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: Builder(
                    builder: (context) {
                      final variantStock = widget.product.getStockFor(_selectedColor.name, _selectedSize);
                      final isVariantSoldOut = widget.product.isSoldOut || variantStock <= 0;

                      return ElevatedButton(
                        onPressed: isVariantSoldOut
                            ? null
                            : () {
                                context.read<CartProvider>().addToCart(
                                      product: widget.product,
                                      selectedSize: _selectedSize,
                                      selectedColor: _selectedColor,
                                      quantity: _quantity,
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${widget.product.name} (Size: $_selectedSize) to Bag',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'VIEW BAG',
                                      textColor: const Color(0xFFC29B38),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CartScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isVariantSoldOut
                              ? (isDark ? const Color(0xFF282830) : const Color(0xFFE0E0E0))
                              : (isDark ? Colors.white : const Color(0xFF141416)),
                          foregroundColor: isVariantSoldOut
                              ? Colors.grey
                              : (isDark ? Colors.black : Colors.white),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isVariantSoldOut ? Icons.block_rounded : Icons.shopping_bag_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isVariantSoldOut
                                  ? 'SOLD OUT • OUT OF STOCK'
                                  : 'Add to Bag • LKR ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFC29B38)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSizeGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Size & Measurement Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'NUANCE tailoring runs true to European standard sizing. For relaxed silhouettes, choose your usual size. For a more fitted look, take one size down.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                children: const [
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Chest', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Waist', style: TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('S')),
                    Padding(padding: EdgeInsets.all(8), child: Text('36 - 38"')),
                    Padding(padding: EdgeInsets.all(8), child: Text('30 - 32"')),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('M')),
                    Padding(padding: EdgeInsets.all(8), child: Text('39 - 41"')),
                    Padding(padding: EdgeInsets.all(8), child: Text('32 - 34"')),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('L')),
                    Padding(padding: EdgeInsets.all(8), child: Text('42 - 44"')),
                    Padding(padding: EdgeInsets.all(8), child: Text('35 - 37"')),
                  ]),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection(BuildContext context, bool isDark, Product product, List<ProductReview> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CLIENT EXPERIENCES & REVIEWS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Color(0xFFC29B38),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFC29B38)),
                const SizedBox(width: 4),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${reviews.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rating summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF7F7F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF282830) : const Color(0xFFE8E8EE),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFC29B38),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < product.rating.floor()
                            ? Icons.star_rounded
                            : (i < product.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        size: 16,
                        color: const Color(0xFFC29B38),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${reviews.length} reviews',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, size: 14, color: Color(0xFFC29B38)),
                        SizedBox(width: 6),
                        Text(
                          '100% Verified Purchases',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '98% of clients commend fit and pure textile craftsmanship.',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Reviews List
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161B) : const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No reviews published yet for this piece. Verified buyers can submit reviews after parcel delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        else
          for (final rev in reviews) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16161B) : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF26262F) : const Color(0xFFEEEEF2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFC29B38).withValues(alpha: 0.2),
                            child: Text(
                              rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'C',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC29B38),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rev.userName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.verified, size: 11, color: Color(0xFFC29B38)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified Atelier Client',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < rev.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 14,
                            color: const Color(0xFFC29B38),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Fit: ${rev.fitFeedback}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC29B38)),
                        ),
                      ),
                      if (rev.qualityTag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF24242C) : const Color(0xFFEDEDF2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rev.qualityTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (rev.title.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      rev.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    rev.comment,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? Colors.white70 : const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ],
    );
  }
}
