import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tous'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
            ),
          ),
          ...EventCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_displayLabel(category)),
                selected: selectedCategory == category,
                onSelected: (selected) => selected
                    ? onCategorySelected(category)
                    : onCategorySelected(null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayLabel(EventCategory category) {
    final name = category.name;
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
