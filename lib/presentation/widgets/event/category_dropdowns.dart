import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EventCategory>(
      initialValue: selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Catégorie *',
        border: OutlineInputBorder(),
      ),
      items: EventCategory.values.map((category) {
        return DropdownMenuItem<EventCategory>(
          value: category,
          child: Text(_getDisplayName(category)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;
      },
    );
  }

  String _getDisplayName(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return 'Musique';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.social:
        return 'Social';
      case EventCategory.problem:
        return 'Problème';
      case EventCategory.other:
        return 'Autre';
    }
  }
}

class SubCategoryDropdown extends StatelessWidget {
  const SubCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onChanged,
  });

  final EventCategory? selectedCategory;
  final EventSubCategory? selectedSubCategory;
  final ValueChanged<EventSubCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final subCategories = _getSubCategoriesForCategory(selectedCategory);

    return DropdownButtonFormField<EventSubCategory>(
      initialValue: selectedSubCategory,
      decoration: const InputDecoration(
        labelText: 'Sous-catégorie *',
        border: OutlineInputBorder(),
      ),
      items: subCategories.map((subCategory) {
        return DropdownMenuItem<EventSubCategory>(
          value: subCategory,
          child: Text(_getDisplayName(subCategory)),
        );
      }).toList(),
      onChanged: selectedCategory != null ? onChanged : null,
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une sous-catégorie';
        }
        return null;
      },
    );
  }

  List<EventSubCategory> _getSubCategoriesForCategory(EventCategory? category) {
    switch (category) {
      case EventCategory.music:
        return [
          EventSubCategory.rock,
          EventSubCategory.rap,
          EventSubCategory.jazz,
        ];
      case EventCategory.sports:
        return [EventSubCategory.football, EventSubCategory.basketball];
      case EventCategory.problem:
        return [EventSubCategory.waterLeak];
      case EventCategory.social:
        return [EventSubCategory.meetup];
      case EventCategory.other:
      case null:
        return [EventSubCategory.general];
    }
  }

  String _getDisplayName(EventSubCategory subCategory) {
    switch (subCategory) {
      case EventSubCategory.rock:
        return 'Rock';
      case EventSubCategory.rap:
        return 'Rap';
      case EventSubCategory.jazz:
        return 'Jazz';
      case EventSubCategory.football:
        return 'Football';
      case EventSubCategory.basketball:
        return 'Basketball';
      case EventSubCategory.waterLeak:
        return 'Fuite d\'eau';
      case EventSubCategory.meetup:
        return 'Rencontre';
      case EventSubCategory.general:
        return 'Général';
    }
  }
}
