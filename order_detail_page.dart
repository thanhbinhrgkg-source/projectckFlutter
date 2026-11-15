import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/invoice_pdf.dart';
import 'package:projectck/notification_repository.dart';
import 'package:projectck/order.dart';
import 'package:projectck/order_detail.dart';
import 'package:projectck/order_repository.dart';
import 'package:projectck/order_status.dart';
import 'package:projectck/session_helper.dart';

class OrderDetailPage extends StatefulWidget {
  final String _title;
  const OrderDetailPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _id;
  Order? _order;
  String? _memberId;
  String? _role;
  List<OrderStatus> _statuses = [];
  Map<String, dynamic>? _qr;
  bool _loaded = false;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _id = ModalRoute.of(context)!.settings.arguments as int;
      _loadData();
    }
  }

  bool get _isAdmin => _role == 'admin';

  void _loadData() async {
    Order? order = await OrderRepository.getOrderById(_id!);
    String? memberId = await SessionHelper.memberId;
    String? role = await SessionHelper.role;
    var statuses = role == 'admin'
        ? await OrderRepository.getStatuses()
        : <OrderStatus>[];
    Map<String, dynamic>? qr;
    if (order != null &&
        order.paymentMethod == 'VIETQR' &&
        order.statusId == 1) {
      qr = await OrderRepository.getVietQr(order.id);
    }
    if (!mounted) return;
    setState(() {
      _order = order;
      _memberId = memberId;
      _role = role;
      _statuses = statuses;
      _qr = qr;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        actions: [
          if (_order != null)
            IconButton(
              onPressed: _onPdf,
              tooltip: 'Xuất hóa đơn PDF',
              icon: Icon(Icons.picture_as_pdf_outlined),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _order == null
          ? buildEmpty(Icons.search_off, 'Không tìm thấy đơn hàng')
          : _buildBody(_order!),
    );
  }

  Widget _buildBody(Order order) {
    ColorScheme color = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.code,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    buildTag(
                      order.statusName,
                      Helper.statusColor(order.statusId),
                    ),
                  ],
                ),
                Text(
                  'Ngày đặt: ${order.createdDate}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Divider(height: 24),
                _buildInfo(Icons.person_outline, order.fullName),
                _buildInfo(Icons.phone_outlined, order.phone),
                _buildInfo(Icons.location_on_outlined, order.address),
                if (order.memberEmail != null)
                  _buildInfo(Icons.email_outlined, order.memberEmail!),
                if (order.note.isNotEmpty) _buildInfo(Icons.notes, order.note),
                _buildInfo(
                  Icons.payments_outlined,
                  Helper.paymentLabel(order.paymentMethod),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...order.items.map(_buildItem),
                Divider(height: 24),
                Row(
                  children: [
                    Text(
                      'Tổng cộng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      Helper.money(order.total),
                      style: TextStyle(
                        fontSize: 20,
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_qr != null) _buildQr(_qr!),
        if (_isAdmin)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cập nhật trạng thái',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses.map((p) {
                      return ChoiceChip(
                        label: Text(p.name),
                        selected: order.statusId == p.id,
                        onSelected: (val) => _onStatus(p),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        if (!_isAdmin && order.memberId == _memberId && order.statusId == 1)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _onCancel,
              icon: Icon(Icons.cancel_outlined),
              label: Text('Hủy đơn hàng'),
            ),
          ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildItem(OrderDetail item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildImage(item.imageUrl, width: 56, height: 56),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${Helper.money(item.price)} x ${item.quantity}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            Helper.money(item.amount),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQr(Map<String, dynamic> qr) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Quét mã VietQR để thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Image.network(
              qr['url'],
              height: 300,
              errorBuilder: (context, error, stack) => Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Không tải được mã QR, vui lòng kiểm tra kết nối Internet',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text('Ngân hàng: ${qr['bank']} - STK: ${qr['account']}'),
            Text('Chủ tài khoản: ${qr['accountName']}'),
            Text(
              'Nội dung: ${qr['content']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _onStatus(OrderStatus status) async {
    ApiResult result = await OrderRepository.updateStatus(_id!, status.id);
    if (!mounted) return;
    showMessage(context, result.message);
    if (result.success) {
      _loadData();
      NotificationRepository.refresh();
    }
  }

  void _onCancel() async {
    var confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hủy đơn hàng'),
          content: Text('Bạn có chắc muốn hủy đơn ${_order!.code}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Không'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Hủy đơn'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    ApiResult result = await OrderRepository.cancel(_id!, _memberId!);
    if (!mounted) return;
    showMessage(context, result.message);
    if (result.success) {
      _loadData();
      NotificationRepository.refresh();
    }
  }

  void _onPdf() async {
    Order order = _order!;
    await Printing.layoutPdf(
      name: 'HoaDon_${order.code}.pdf',
      onLayout: (format) => InvoicePdf.build(order),
    );
  }
}
