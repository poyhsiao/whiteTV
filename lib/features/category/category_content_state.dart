import 'package:white_tv/core/api/models.dart';
import 'category_constants.dart';

/// 分類內容頁狀態
class CategoryContentState {
  final String categoryId;
  final String? subCategory;
  final String? region;
  final String? year;
  final SortOption sortOption;
  final List<Video> videos;
  final bool isLoading;
  final String? error;

  const CategoryContentState({
    required this.categoryId,
    this.subCategory,
    this.region,
    this.year,
    this.sortOption = SortOption.recentUpdate,
    this.videos = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryContentState copyWith({
    String? categoryId,
    String? subCategory,
    String? region,
    String? year,
    SortOption? sortOption,
    List<Video>? videos,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSubCategory = false,
    bool clearRegion = false,
    bool clearYear = false,
  }) {
    return CategoryContentState(
      categoryId: categoryId ?? this.categoryId,
      subCategory: clearSubCategory ? null : (subCategory ?? this.subCategory),
      region: clearRegion ? null : (region ?? this.region),
      year: clearYear ? null : (year ?? this.year),
      sortOption: sortOption ?? this.sortOption,
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryContentState &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          subCategory == other.subCategory &&
          region == other.region &&
          year == other.year &&
          sortOption == other.sortOption &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      subCategory.hashCode ^
      region.hashCode ^
      year.hashCode ^
      sortOption.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}
