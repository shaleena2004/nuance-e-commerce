import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import 'custom_image.dart';

class DepartmentExploreBanner extends StatelessWidget {
  const DepartmentExploreBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsProvider = context.watch<ProductsProvider>();
    final currentDept = productsProvider.selectedDepartment;

    // Visual cards per department
    final String card1Title = currentDept == 'Men'
        ? 'MEN\'S TAILORING'
        : (currentDept == 'Accessories' ? 'ATELIER LEATHER' : 'RECOMMENDED FOR YOU');
    final String card1Image = currentDept == 'Men'
        ? 'assets/images/menswear_jacket.jpg'
        : (currentDept == 'Accessories'
            ? 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80'
            : 'assets/images/hero_banner.jpg');

    final String card2Title = currentDept == 'Men'
        ? 'OUTERWEAR & COATS'
        : (currentDept == 'Accessories' ? 'SLIM CARDHOLDERS' : 'WOMEN\'S SILK & SATIN');
    final String card2Image = currentDept == 'Men'
        ? 'assets/images/wool_coat.jpg'
        : (currentDept == 'Accessories'
            ? 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=1000&q=80'
            : 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=1000&q=80');

    final String card3Title = currentDept == 'Men'
        ? 'SUMMER RESORT LINEN'
        : (currentDept == 'Accessories' ? 'LUXURY TOTES' : 'ACCESSORIES & BAGS');
    final String card3Image = currentDept == 'Men'
        ? 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=1000&q=80'
        : (currentDept == 'Accessories'
            ? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80'
            : 'assets/images/summer_collection.jpg');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF15151B) : const Color(0xFFF6F5F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF262632) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC29B38),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentDept == 'All'
                        ? 'EXPLORE DEPARTMENTS'
                        : '${currentDept.toUpperCase()} CATALOGUE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  productsProvider.resetFilters();
                },
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFFC29B38),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Carnage-Style Visual Tiles
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDepartmentCard(
                  title: card1Title,
                  imagePath: card1Image,
                  onTap: () {
                    if (currentDept == 'Men') {
                      productsProvider.selectCategory('Tailored Suits');
                    } else if (currentDept == 'Accessories') {
                      productsProvider.selectCategory('Bags & Acc');
                    } else {
                      productsProvider.selectDepartment('Women');
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildDepartmentCard(
                  title: card2Title,
                  imagePath: card2Image,
                  onTap: () {
                    if (currentDept == 'Men') {
                      productsProvider.selectCategory('Outerwear');
                    } else if (currentDept == 'Accessories') {
                      productsProvider.selectCategory('Bags & Acc');
                    } else {
                      productsProvider.selectCategory('Silk & Satin');
                    }
                  },
                ),
                const SizedBox(width: 10),
                _buildDepartmentCard(
                  title: card3Title,
                  imagePath: card3Image,
                  onTap: () {
                    if (currentDept == 'Men') {
                      productsProvider.selectCategory('Linen & Resort');
                    } else {
                      productsProvider.selectDepartment('Accessories');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 220,
          height: 130,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomImage(imagePath: imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SHOP NOW',
                        style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
