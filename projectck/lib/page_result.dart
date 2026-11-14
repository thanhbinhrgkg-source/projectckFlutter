class PageResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  PageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  factory PageResult.empty() {
    return PageResult(items: [], total: 0, page: 1, pageSize: 1);
  }
  factory PageResult.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return PageResult(
      items: (map['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(fromMap)
          .toList(),
      total: map['total'],
      page: map['page'],
      pageSize: map['pageSize'],
    );
  }
  int get totalPages => total == 0 ? 1 : (total + pageSize - 1) ~/ pageSize;
}
