import '../../domain/entities/event.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/search_filters.dart';

class SearchFiltersModel extends SearchFilters {
  const SearchFiltersModel({
    super.category,
    super.subCategory,
    super.location,
    super.radiusKm,
    super.startDate,
    super.endDate,
    super.isActive,
    super.minVerificationCount,
  });

  factory SearchFiltersModel.fromJson(Map<String, dynamic> json) {
    return SearchFiltersModel(
      category: json['category'] != null
          ? EventCategory.values.firstWhere(
              (value) => value.name == json['category'],
            )
          : null,
      subCategory: json['subCategory'] != null
          ? EventSubCategory.values.firstWhere(
              (value) => value.name == json['subCategory'],
            )
          : null,
      location: json['location'] != null
          ? LocationPoint(
              latitude: (json['location']['lat'] as num).toDouble(),
              longitude: (json['location']['lng'] as num).toDouble(),
            )
          : null,
      radiusKm: json['radiusKm'] != null
          ? (json['radiusKm'] as num).toDouble()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool?,
      minVerificationCount: json['minVerificationCount'] as int?,
    );
  }

  factory SearchFiltersModel.fromEntity(SearchFilters filters) {
    return SearchFiltersModel(
      category: filters.category,
      subCategory: filters.subCategory,
      location: filters.location,
      radiusKm: filters.radiusKm,
      startDate: filters.startDate,
      endDate: filters.endDate,
      isActive: filters.isActive,
      minVerificationCount: filters.minVerificationCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (category != null) 'category': category!.name,
      if (subCategory != null) 'subCategory': subCategory!.name,
      if (location != null)
        'location': {'lat': location!.latitude, 'lng': location!.longitude},
      if (radiusKm != null) 'radiusKm': radiusKm,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (isActive != null) 'isActive': isActive,
      if (minVerificationCount != null)
        'minVerificationCount': minVerificationCount,
    };
  }

  @override
  SearchFiltersModel copyWith({
    EventCategory? category,
    EventSubCategory? subCategory,
    LocationPoint? location,
    double? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? minVerificationCount,
  }) {
    return SearchFiltersModel(
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
}
