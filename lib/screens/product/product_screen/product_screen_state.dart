import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';

import '../../../enums/processing/sort_enum.dart';

class ProductScreenState extends Equatable {
  final String? searchText;
  final int selectedTabIndex;
  final SortEnum selectedSortOption;
  final List<Product> initialProducts;
  final SortEnum initialSortOption;

  const ProductScreenState({
    this.searchText,
    this.selectedTabIndex = 0,
    this.selectedSortOption = SortEnum.releaseLatest,
    this.initialProducts = const [],
    this.initialSortOption = SortEnum.releaseLatest,
  });

  @override
  List<Object?> get props => [
    searchText,
    selectedTabIndex,
    selectedSortOption,
    initialProducts,
    initialSortOption
  ];

  ProductScreenState copyWith({
    String? searchText,
    int? selectedTabIndex,
    SortEnum? selectedSortOption,
    List<Product>? initialProducts,
    SortEnum? initialSortOption,
  }) {
    return ProductScreenState(
      searchText: searchText ?? this.searchText,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedSortOption: selectedSortOption ?? this.selectedSortOption,
      initialProducts: initialProducts ?? this.initialProducts,
      initialSortOption: initialSortOption ?? this.initialSortOption,
    );
  }
}