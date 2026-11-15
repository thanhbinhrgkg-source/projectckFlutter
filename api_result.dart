import 'package:projectck/api_helper.dart';

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
    return ApiResult(success: false, message: errorMessage());
  }

  static String errorMessage() {
    switch (ApiHelper.lastStatus) {
      case 401:
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
      case 403:
        return 'Bạn không có quyền thực hiện chức năng này';
      case 0:
        return 'Không kết nối được máy chủ';
      default:
        return 'Có lỗi xảy ra (mã ${ApiHelper.lastStatus})';
    }
  }
}
