import 'package:flutter/material.dart';

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
              color: Colors.grey[600],
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
                Colors.purple,
              ),
              _buildCategoryChip(
                context,
                'Sports',
                Icons.sports_soccer,
                EventCategory.sports,
                Colors.blue,
              ),
              _buildCategoryChip(
                context,
                'Social',
                Icons.people,
                EventCategory.social,
                Colors.green,
              ),
              _buildCategoryChip(
                context,
                'Problems',
                Icons.warning,
                EventCategory.problem,
                Colors.orange,
              ),
              _buildCategoryChip(
                context,
                'Other',
                Icons.category,
                EventCategory.other,
                Colors.grey,
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
