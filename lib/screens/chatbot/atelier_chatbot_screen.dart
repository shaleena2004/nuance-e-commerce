import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../providers/app_state.dart';
import '../../widgets/custom_image.dart';
import '../product_details/product_details_screen.dart';
import '../cart/cart_screen.dart';

class ChatStylistMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Product> recommendedProducts;
  final String? occasionTag;

  ChatStylistMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedProducts = const [],
    this.occasionTag,
  });
}

class AtelierChatbotScreen extends StatefulWidget {
  const AtelierChatbotScreen({super.key});

  @override
  State<AtelierChatbotScreen> createState() => _AtelierChatbotScreenState();
}

class _AtelierChatbotScreenState extends State<AtelierChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatStylistMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _inspirationChips = [
    'Black Tie & Evening Gala',
    'Sharp Executive Power Tailoring',
    'Resort Linen & Beach Holiday',
    'Minimalist Cashmere Warmth',
    'Rare & Almost Sold Out Pieces',
    'Sleek Monochrome Black Look',
    'Complete Outfit under LKR 350',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatStylistMessage(
        text:
            "Bonjour. I am your Nuance Private Atelier AI Stylist.\n\nTell me about your upcoming occasion, preferred fabrics (like virgin wool, silk, or linen), color tastes, or budget, and I will compose a personalized outfit pairing for you.",
        isUser: false,
        timestamp: DateTime.now(),
        occasionTag: 'PRIVATE CONCIERGE',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(
        ChatStylistMessage(
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    // Generate intelligent outfit suggestions
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final productsProvider = context.read<ProductsProvider>();
      final allProducts = productsProvider.products;

      final response = _generateStylingAdvice(query, allProducts);

      setState(() {
        _isTyping = false;
        _messages.add(response);
      });
      _scrollToBottom();
    });
  }

  ChatStylistMessage _generateStylingAdvice(String query, List<Product> catalog) {
    final lower = query.toLowerCase();
    List<Product> matches = [];
    String stylistComment = '';
    String tag = 'ATELIER CURATION';

    // 1. Almost Sold Out / Rare pieces
    if (lower.contains('sold out') || lower.contains('almost') || lower.contains('rare') || lower.contains('limited')) {
      tag = 'EXCLUSIVE ARCHIVE';
      matches = catalog.where((p) => p.isLowStock || p.stockCount <= 5).toList();
      if (matches.isEmpty) {
        matches = catalog.where((p) => p.inStock).take(2).toList();
      }
      stylistComment =
          "Here are our most coveted limited-run pieces currently almost sold out in the atelier. If you appreciate exclusivity, these silhouettes represent our most scarce inventory:";
    }
    // 2. Evening / Black Tie / Gala / Wedding / Party / Silk
    else if (lower.contains('gala') ||
        lower.contains('wedding') ||
        lower.contains('evening') ||
        lower.contains('dinner') ||
        lower.contains('party') ||
        lower.contains('silk')) {
      tag = 'EVENING COUTURE';
      matches = catalog.where((p) {
        final cat = p.category.toLowerCase();
        final name = p.name.toLowerCase();
        final desc = p.description.toLowerCase();
        return cat.contains('silk') ||
            cat.contains('tailored') ||
            name.contains('suit') ||
            name.contains('slip') ||
            name.contains('silk') ||
            desc.contains('silk');
      }).toList();
      stylistComment =
          "For an exquisite evening silhouette, I recommend contrasting fluid silk satin against structured architectural tailoring. The subtle sheen of the fabric catches low ambient lighting effortlessly:";
    }
    // 3. Business / Executive / Meeting / Office / Tailoring / Suit
    else if (lower.contains('business') ||
        lower.contains('meeting') ||
        lower.contains('work') ||
        lower.contains('suit') ||
        lower.contains('office') ||
        lower.contains('tailoring')) {
      tag = 'EXECUTIVE TAILORING';
      matches = catalog.where((p) {
        return p.category.toLowerCase().contains('tailored') ||
            p.name.toLowerCase().contains('suit') ||
            p.name.toLowerCase().contains('trouser') ||
            p.category.toLowerCase().contains('outerwear');
      }).toList();
      stylistComment =
          "For high-stakes presentations and executive presence, sharp shoulders with relaxed pleated trousers create confident authority without feeling rigid. Here is our signature tailoring ensemble:";
    }
    // 4. Summer / Resort / Vacation / Beach / Linen
    else if (lower.contains('summer') ||
        lower.contains('resort') ||
        lower.contains('beach') ||
        lower.contains('vacation') ||
        lower.contains('linen') ||
        lower.contains('holiday')) {
      tag = 'RESORT LIVING';
      matches = catalog.where((p) {
        return p.category.toLowerCase().contains('linen') ||
            p.description.toLowerCase().contains('linen') ||
            p.name.toLowerCase().contains('linen');
      }).toList();
      stylistComment =
          "For warm climates and coastal retreats, our washed French linen collection offers breathable nonchalance. Keep the silhouette relaxed and breezy with earth tones:";
    }
    // 5. Winter / Cold / Warm / Coat / Trench / Cashmere / Knitwear
    else if (lower.contains('winter') ||
        lower.contains('coat') ||
        lower.contains('trench') ||
        lower.contains('cashmere') ||
        lower.contains('knit') ||
        lower.contains('warm') ||
        lower.contains('cold')) {
      tag = 'WINTER DRAPING';
      matches = catalog.where((p) {
        final cat = p.category.toLowerCase();
        return cat.contains('outerwear') || cat.contains('knitwear');
      }).toList();
      stylistComment =
          "For refined temperature transitions, tactile texture is everything. Layer a fine cashmere mockneck beneath a heavyweight wool trench for understated depth:";
    }
    // 6. Color-driven styling: Black / Monochrome
    else if (lower.contains('black') || lower.contains('monochrome') || lower.contains('dark')) {
      tag = 'OBSIDIAN NOIR';
      matches = catalog.where((p) {
        return p.colors.any((c) =>
            c.name.toLowerCase().contains('black') ||
            c.name.toLowerCase().contains('noir') ||
            c.name.toLowerCase().contains('charcoal'));
      }).toList();
      stylistComment =
          "Monochrome dressing relies on rich textural contrast. When wearing head-to-toe black, mix matte virgin wool with smooth silk and polished hardware:";
    }
    // 7. Budget filter: under X LKR
    else if (lower.contains('under') || lower.contains('budget') || lower.contains('price') || lower.contains('cheap')) {
      tag = 'ACCESSIBLE LUXURY';
      double maxPrice = 300.0;
      final numbers = RegExp(r'\d+').allMatches(query);
      if (numbers.isNotEmpty) {
        maxPrice = double.tryParse(numbers.first.group(0)!) ?? 300.0;
      }
      matches = catalog.where((p) => p.price <= maxPrice).toList();
      stylistComment =
          "Here are timeless investment pieces crafted to atelier standards within your preferred price ceiling:";
    }
    // 8. General search / keyword fallback
    else {
      matches = catalog.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            p.category.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower);
      }).toList();
      if (matches.isEmpty) {
        matches = catalog.where((p) => p.isFeatured || p.isNew).take(3).toList();
        stylistComment =
            "Based on your aesthetic viewpoint, I curated our quintessential wardrobe foundations. These versatile garments harmonize across seasonal transitions:";
      } else {
        stylistComment =
            "I found pieces aligning with your aesthetic vision. Here is how I suggest styling them together:";
      }
    }

    if (matches.isEmpty) {
      matches = catalog.take(2).toList();
    }

    return ChatStylistMessage(
      text: stylistComment,
      isUser: false,
      timestamp: DateTime.now(),
      recommendedProducts: matches.take(3).toList(),
      occasionTag: tag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isDark = appState.isDarkTheme(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF9F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141418) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC29B38), Color(0xFFE8DCC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC29B38).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NUANCE AI STYLIST',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Atelier Concierge • Online',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Inspiration Chips Horizontal List
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF222228) : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _inspirationChips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = _inspirationChips[index];
                return ActionChip(
                  label: Text(chip),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  backgroundColor: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF2F2F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF2A2A34) : const Color(0xFFE5E5EB),
                    ),
                  ),
                  onPressed: () => _handleSendMessage(chip),
                );
              },
            ),
          ),

          // Chat Messages View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(context, msg, isDark);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC29B38)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Nuance Stylist is curating silhouettes...',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF222228) : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C22) : const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE2E2E8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _inputController,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onSubmitted: _handleSendMessage,
                      decoration: const InputDecoration(
                        hintText: 'Ask stylist: "Wedding in Capri", "Suits in silk"...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _handleSendMessage(_inputController.text),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC29B38),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatStylistMessage message, bool isDark) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC29B38),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occasion Tag & Stylist Avatar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC29B38).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFFC29B38)),
                ),
                const SizedBox(width: 8),
                Text(
                  message.occasionTag ?? 'ATELIER STYLIST',
                  style: const TextStyle(
                    color: Color(0xFFC29B38),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Message Body
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16161B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: isDark ? const Color(0xFF262630) : const Color(0xFFEBEBEF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),

                  // Recommended Outfit Pieces
                  if (message.recommendedProducts.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    const Text(
                      'RECOMMENDED OUTFIT ENSEMBLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC29B38),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: message.recommendedProducts.map((prod) {
                        return _buildSuggestedProductTile(context, prod, isDark);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedProductTile(BuildContext context, Product product, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F26) : const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C36) : const Color(0xFFE5E5EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Garment Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 64,
              child: CustomImage(
                imagePath: product.mainImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFC29B38),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    if (product.isSoldOut)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (product.isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC29B38).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ONLY ${product.totalStock} LEFT',
                          style: const TextStyle(color: Color(0xFFC29B38), fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'LKR ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // View Details Action
          IconButton(
            tooltip: 'View Piece Details',
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFFC29B38)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
