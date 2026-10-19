import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class DepartmentNavBar extends StatelessWidget {
  const DepartmentNavBar({super.key});

  static const List<Map<String, String>> _departments = [
    {'id': 'All', 'label': 'ALL'},
    {'id': 'Women', 'label': 'WOMEN'},
    {'id': 'Men', 'label': 'MEN'},
    {'id': 'Accessories', 'label': 'ACCESSORIES'},
    {'id': 'Last Chance', 'label': 'LAST CHANCE'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsProvider = context.watch<ProductsProvider>();
    final currentDept = productsProvider.selectedDepartment;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111115) : const Color(0xFFFAF9F6),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF23232C) : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _departments.map((dept) {
              final isSelected = currentDept == dept['id'];
              final isLastChance = dept['id'] == 'Last Chance';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    productsProvider.selectDepartment(dept['id']!);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? (isLastChance ? Colors.redAccent : const Color(0xFFC29B38))
                              : Colors.transparent,
                          width: 2.2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLastChance) ...[
                          const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          dept['label']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: 1.8,
                            color: isSelected
                                ? (isLastChance
                                    ? Colors.redAccent
                                    : (isDark ? Colors.white : Colors.black))
                                : (isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
