import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/event.dart';

class QuickActionChips extends StatelessWidget {
  const QuickActionChips({required this.onCategorySelected, super.key});

  final Function(EventCategory) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(
                context,
                'Music',
                Icons.music_note,
                EventCategory.music,
                AppColors.musicCategory,
              ),
              _buildCategoryChip(
                context,
                'Sports',
                Icons.sports_soccer,
                EventCategory.sports,
                AppColors.sportsCategory,
              ),
              _buildCategoryChip(
                context,
                'Social',
                Icons.people,
                EventCategory.social,
                AppColors.socialCategory,
              ),
              _buildCategoryChip(
                context,
                'Problems',
                Icons.warning,
                EventCategory.problem,
                AppColors.problemCategory,
              ),
              _buildCategoryChip(
                context,
                'Other',
                Icons.category,
                EventCategory.other,
                AppColors.otherCategory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    IconData icon,
    EventCategory category,
    Color color,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: () => onCategorySelected(category),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
