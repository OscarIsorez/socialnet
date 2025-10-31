import 'package:equatable/equatable.dart';

import 'event.dart';
import 'location_point.dart';

/// Represents filters that can be applied to event searches
class SearchFilters extends Equatable {
  const SearchFilters({
    this.category,
    this.subCategory,
    this.location,
    this.radiusKm,
    this.startDate,
    this.endDate,
    this.isActive,
    this.minVerificationCount,
  });

  final EventCategory? category;
  final EventSubCategory? subCategory;
  final LocationPoint? location;
  final double? radiusKm;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  final int? minVerificationCount;

  /// Creates an empty filter with no restrictions
  factory SearchFilters.empty() => const SearchFilters();

  /// Returns true if any filter is applied
  bool get hasFilters =>
      category != null ||
      subCategory != null ||
      location != null ||
      startDate != null ||
      endDate != null ||
      isActive != null ||
      minVerificationCount != null;

  SearchFilters copyWith({
    EventCategory? category,
    EventSubCategory? subCategory,
    LocationPoint? location,
    double? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? minVerificationCount,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      minVerificationCount: minVerificationCount ?? this.minVerificationCount,
    );
  }

  /// Clears a specific filter parameter
  SearchFilters clearCategory() => copyWith(category: null);
  SearchFilters clearSubCategory() => copyWith(subCategory: null);
  SearchFilters clearLocation() => copyWith(location: null);
  SearchFilters clearDateRange() => copyWith(startDate: null, endDate: null);

  @override
  List<Object?> get props => [
    category,
    subCategory,
    location,
    radiusKm,
    startDate,
    endDate,
    isActive,
    minVerificationCount,
  ];
}
