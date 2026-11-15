import 'package:projectck/api_helper.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/order.dart';
import 'package:projectck/order_status.dart';

class OrderRepository {
  static Future<ApiResult> add({
    required String memberId,
    required String fullName,
    required String phone,
    required String address,
    required String note,
    required String paymentMethod,
    required List<Cart> carts,
  }) async {
    return ApiResult.fromData(
      await ApiHelper.post('/orders', {
        'memberId': memberId,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'note': note,
        'paymentMethod': paymentMethod,
        'items': carts
            .map((p) => {'productId': p.productId, 'quantity': p.quantity})
            .toList(),
      }),
    );
  }

  static Future<List<Order>> getOrders({
    String? memberId,
    String keyword = '',
    DateTime? fromDate,
    DateTime? toDate,
    int? statusId,
  }) async {
    var data = await ApiHelper.getList(
      '/orders${ApiHelper.query({'memberId': memberId, 'keyword': keyword, 'fromDate': fromDate == null ? null : _date(fromDate), 'toDate': toDate == null ? null : _date(toDate), 'statusId': statusId})}',
    );
    return data.map(Order.fromMap).toList();
  }

  static Future<Order?> getOrderById(int id) async {
    var data = await ApiHelper.getOne('/orders/$id');
    if (data != null) {
      return Order.fromMap(data);
    }
    return null;
  }

  static Future<List<OrderStatus>> getStatuses() async {
    var data = await ApiHelper.getList('/order-status');
    return data.map(OrderStatus.fromMap).toList();
  }

  static Future<ApiResult> updateStatus(int id, int statusId) async {
    return ApiResult.fromData(
      await ApiHelper.put('/orders/$id/status', {'statusId': statusId}),
    );
  }

  static Future<ApiResult> cancel(int id, String memberId) async {
    return ApiResult.fromData(
      await ApiHelper.put('/orders/$id/cancel', {'memberId': memberId}),
    );
  }

  static Future<Map<String, dynamic>?> getVietQr(int id) async {
    return await ApiHelper.getOne('/orders/$id/vietqr');
  }

  static String _date(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }
}
