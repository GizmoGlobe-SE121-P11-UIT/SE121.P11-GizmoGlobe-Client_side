class DrawerState {
  final bool isOpen;
  final List<String> categories;

  DrawerState({
    this.isOpen = false,
    this.categories = const [],
  });

  DrawerState copyWith({bool? isOpen, List<String>? categories, String? username}) {
    return DrawerState(
      isOpen: isOpen ?? this.isOpen,
      categories: categories ?? this.categories,
    );
  }
}