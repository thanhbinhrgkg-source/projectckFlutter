import 'package:projectck/order_detail.dart';

class Order {
  final int id;
  final String memberId;
  final String? memberEmail;
  final int statusId;
  final String statusName;
  final String fullName;
  final String phone;
  final String address;
  final String note;
  final String paymentMethod;
  final double total;
  final String createdDate;
  final int itemCount;
  final List<OrderDetail> items;
  Order({
    required this.id,
    required this.memberId,
    required this.memberEmail,
    required this.statusId,
    required this.statusName,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.note,
    required this.paymentMethod,
    required this.total,
    required this.createdDate,
    required this.itemCount,
    required this.items,
  });
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      memberId: map['memberId'],
      memberEmail: map['memberEmail'],
      statusId: map['statusId'],
      statusName: map['statusName'] ?? '',
      fullName: map['fullName'],
      phone: map['phone'],
      address: map['address'],
      note: map['note'] ?? '',
      paymentMethod: map['paymentMethod'],
      total: (map['total'] as num).toDouble(),
      createdDate: map['createdDate'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      items: map.containsKey('items')
          ? (map['items'] as List)
                .cast<Map<String, dynamic>>()
                .map(OrderDetail.fromMap)
                .toList()
          : [],
    );
  }

  String get code => 'DH$id';
}
