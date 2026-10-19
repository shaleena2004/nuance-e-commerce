import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/review.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state.dart';
import 'custom_image.dart';

class AtelierReviewDialog extends StatefulWidget {
  final OrderModel order;
  final CartItem item;
  final VoidCallback? onReviewSubmitted;

  const AtelierReviewDialog({
    super.key,
    required this.order,
    required this.item,
    this.onReviewSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderModel order,
    required CartItem item,
    VoidCallback? onReviewSubmitted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AtelierReviewDialog(
        order: order,
        item: item,
        onReviewSubmitted: onReviewSubmitted,
      ),
    );
  }

  @override
  State<AtelierReviewDialog> createState() => _AtelierReviewDialogState();
}

class _AtelierReviewDialogState extends State<AtelierReviewDialog> {
  double _rating = 5.0;
  String _selectedFit = 'True to Size';
  final Set<String> _selectedTags = {'Impeccable Stitching', 'Luxurious Feel'};
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _fitOptions = [
    'Runs Small',
    'True to Size',
    'Runs Large',
    'Relaxed Fit',
  ];

  final List<String> _qualityTags = [
    '100% Pure Silk',
    'Virgin Wool',
    'Impeccable Stitching',
    'Luxurious Feel',
    'Flattering Silhouette',
    'Comfortable Drape',
    'True to Photos',
    'Atelier Packaging',
  ];

  String _getRatingDescriptor(double rating) {
    if (rating >= 5.0) return 'Exceptional Atelier Perfection ★★★★★';
    if (rating >= 4.0) return 'Highly Commended Luxury ★★★★☆';
    if (rating >= 3.0) return 'Satisfactory Garment ★★★☆☆';
    if (rating >= 2.0) return 'Below Expectations ★★☆☆☆';
    return 'Needs Atelier Improvement ★☆☆☆☆';
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please share a few words about your parcel experience.'),
          backgroundColor: Color(0xFFC29B38),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthProvider>().user;
      final userName = user?.displayName.isNotEmpty == true
          ? user!.displayName
          : (widget.order.customerName.isNotEmpty
              ? widget.order.customerName
              : 'Atelier Client');

      final review = ProductReview(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        orderId: widget.order.id,
        productId: widget.item.product.id,
        productName: widget.item.product.name,
        productImage: widget.item.product.mainImage,
        userId: user?.id ?? widget.order.userId,
        userName: userName,
        rating: _rating,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'Atelier Verified Review',
        comment: comment,
        fitFeedback: _selectedFit,
        qualityTag: _selectedTags.isNotEmpty
            ? _selectedTags.join(', ')
            : 'Exceptional Craftsmanship',
        createdAt: DateTime.now(),
        isVerifiedPurchase: true,
      );

      await context.read<ProductsProvider>().addProductReview(review);

      if (mounted) {
        Navigator.pop(context);
        widget.onReviewSubmitted?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E24),
            content: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFFC29B38), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Thank you! Your verified review for "${widget.item.product.name}" was published.',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isDark = appState.isDarkTheme(context);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF16161B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF282832) : const Color(0xFFEEEEF2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rate_review_rounded, color: Color(0xFFC29B38), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RATE & REVIEW GARMENT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Color(0xFFC29B38),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Delivered Order: ${widget.order.id}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garment Preview Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF7F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2B2B36) : const Color(0xFFE8E8EE),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 52,
                              height: 64,
                              child: CustomImage(
                                imagePath: widget.item.product.mainImage,
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
                                  widget.item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC29B38).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Size ${widget.item.selectedSize}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFC29B38),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.item.selectedColor.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Star Rating
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'HOW WOULD YOU RATE THIS PIECE?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starVal = (index + 1).toDouble();
                              final isSelected = starVal <= _rating;
                              return InkWell(
                                onTap: () => setState(() => _rating = starVal),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 38,
                                    color: isSelected ? const Color(0xFFC29B38) : Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getRatingDescriptor(_rating),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC29B38),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Fit Feedback Section
                    const Text(
                      'FIT & SILHOUETTE FEEDBACK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fitOptions.map((fit) {
                        final isSelected = _selectedFit == fit;
                        return ChoiceChip(
                          label: Text(fit),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedFit = fit);
                          },
                          selectedColor: const Color(0xFFC29B38),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFEEEEF2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Quality & Craftsmanship Tags
                    const Text(
                      'ATELIER QUALITY ATTRIBUTES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _qualityTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                          selectedColor: const Color(0xFFC29B38).withValues(alpha: 0.25),
                          checkmarkColor: const Color(0xFFC29B38),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFFC29B38) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFEEEEF2),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFC29B38) : Colors.transparent,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Review Title
                    const Text(
                      'REVIEW HEADLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Gorgeous silk drape, perfect for gala dinners',
                        hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white30 : Colors.black38),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Detailed Opinion
                    const Text(
                      'WRITTEN OPINION & PARCEL EXPERIENCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Describe the fabric feel, how the garment hangs, unboxing packaging, or your styling recommendations...',
                        hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white30 : Colors.black38),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E5EB)),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button Footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF282832) : const Color(0xFFEEEEF2),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC29B38),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSubmitting ? null : _submitReview,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.verified_outlined, size: 18),
                  label: Text(
                    _isSubmitting ? 'PUBLISHING REVIEW...' : 'PUBLISH ATELIER REVIEW',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
