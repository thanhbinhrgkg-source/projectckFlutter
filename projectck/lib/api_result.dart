class ApiResult {
  final bool success;
  final String message;
  final int? id;
  ApiResult({required this.success, required this.message, this.id});
  factory ApiResult.fromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ApiResult(
        success: data['success'] == true,
        message: data['message'] ?? '',
        id: data['id'],
      );
    }
    return ApiResult(success: false, message: 'Không kết nối được máy chủ');
  }
}
