import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/influencer.dart';

class FilterChipRow extends StatelessWidget {
  final InfluencerCategory selectedCategory;
  final ValueChanged<InfluencerCategory> onSelected;

  const FilterChipRow({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (category: InfluencerCategory.highFit, label: 'High Fit'),
      (category: InfluencerCategory.tech, label: 'Tech'),
      (category: InfluencerCategory.lifestyle, label: 'Lifestyle'),
      (category: InfluencerCategory.design, label: 'Design'),
      (category: InfluencerCategory.finance, label: 'Finance'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedCategory == f.category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(f.category),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
