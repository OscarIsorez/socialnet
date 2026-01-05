import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/search_filters.dart';
import '../../bloc/search/search_bloc.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  EventCategory? _selectedCategory;
  EventSubCategory? _selectedSubCategory;
  bool? _isActive;
  int? _minVerificationCount;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Initialize with current filters from BLoC
    final currentFilters = context.read<SearchBloc>().state.filters;
    if (currentFilters != null) {
      _selectedCategory = currentFilters.category;
      _selectedSubCategory = currentFilters.subCategory;
      _isActive = currentFilters.isActive;
      _minVerificationCount = currentFilters.minVerificationCount;
      _startDate = currentFilters.startDate;
      _endDate = currentFilters.endDate;
    }
  }

  void _applyFilters() {
    final filters = SearchFilters(
      category: _selectedCategory,
      subCategory: _selectedSubCategory,
      isActive: _isActive,
      minVerificationCount: _minVerificationCount,
      startDate: _startDate,
      endDate: _endDate,
    );

    context.read<SearchBloc>().add(UpdateFiltersRequested(filters));
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSubCategory = null;
      _isActive = null;
      _minVerificationCount = null;
      _startDate = null;
      _endDate = null;
    });

    context.read<SearchBloc>().add(
      const UpdateFiltersRequested(SearchFilters()),
    );

    // Close the bottom sheet after clearing
    Navigator.pop(context);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filters Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EventCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                            if (!selected) _selectedSubCategory = null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // SubCategory Filter (shown only if category is selected)
                  if (_selectedCategory != null) ...[
                    const Text(
                      'Sub-Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EventSubCategory.values.map((subCategory) {
                        final isSelected = _selectedSubCategory == subCategory;
                        return ChoiceChip(
                          label: Text(subCategory.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSubCategory = selected
                                  ? subCategory
                                  : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Active Status Filter
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Active Only'),
                          selected: _isActive == true,
                          onSelected: (selected) {
                            setState(() {
                              _isActive = selected ? true : null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('All Events'),
                          selected: _isActive == null,
                          onSelected: (selected) {
                            setState(() => _isActive = null);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Verification Count Filter
                  const Text(
                    'Minimum Verifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: (_minVerificationCount ?? 0).toDouble(),
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: _minVerificationCount?.toString() ?? '0',
                          onChanged: (value) {
                            setState(() {
                              _minVerificationCount = value.toInt();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${_minVerificationCount ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Date Range Filter
                  const Text(
                    'Date Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectStartDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate != null
                                ? DateFormat('MMM d, y').format(_startDate!)
                                : 'Start Date',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEndDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _endDate != null
                                ? DateFormat('MMM d, y').format(_endDate!)
                                : 'End Date',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
