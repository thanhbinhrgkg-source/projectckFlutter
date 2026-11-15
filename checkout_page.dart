import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member.dart';
import 'package:projectck/member_repository.dart';
import 'package:projectck/notification_repository.dart';
import 'package:projectck/order_repository.dart';
import 'package:projectck/session_helper.dart';

class CheckoutPage extends StatefulWidget {
  final String _title;
  const CheckoutPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _memberId;
  List<Cart> _carts = [];
  String _payment = 'COD';
  bool _saving = false;
  String? _error;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) return;
    var carts = await CartRepository.getCarts(memberId);
    Member? member = await MemberRepository.getMemberById(memberId);
    if (!mounted) return;
    setState(() {
      _memberId = memberId;
      _carts = carts;
      if (member != null) {
        _nameController.text = '${member.surname} ${member.givenName}'.trim();
      }
    });
  }

  double get _total => _carts.fold(0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitle(Icons.contact_mail_outlined, 'Thông tin liên hệ'),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ tên người liên hệ',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ doanh nghiệp',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: Icon(Icons.notes),
                    ),
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
                  _buildTitle(
                    Icons.payments_outlined,
                    'Phương thức thanh toán',
                  ),
                  SizedBox(height: 12),
                  _buildPayment(
                    'COD',
                    Icons.handshake_outlined,
                    'Thanh toán khi nghiệm thu',
                    'Thanh toán sau khi bàn giao báo cáo khảo sát',
                  ),
                  _buildPayment(
                    'VIETQR',
                    Icons.qr_code_2,
                    'Chuyển khoản VietQR',
                    'Quét mã QR bằng ứng dụng ngân hàng',
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
                  _buildTitle(
                    Icons.shopping_bag_outlined,
                    'Đơn hàng (${_carts.length} gói)',
                  ),
                  SizedBox(height: 8),
                  ..._carts.map((p) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('${p.name}  x${p.quantity}')),
                          Text(Helper.money(p.amount)),
                        ],
                      ),
                    );
                  }),
                  Divider(height: 24),
                  Row(
                    children: [
                      Text(
                        'Tổng cộng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            Helper.money(_total),
                            style: TextStyle(
                              fontSize: 20,
                              color: color.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildMessage(_error, null),
          SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: Size(0, 52)),
            onPressed: _saving || _carts.isEmpty ? null : _onOrder,
            label: Text('Xác nhận đặt hàng'),
            icon: Icon(Icons.check_circle_outline),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPayment(
    String value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    ColorScheme color = Theme.of(context).colorScheme;
    bool selected = _payment == value;
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _payment = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? color.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? color.primary : Colors.grey,
              ),
              SizedBox(width: 12),
              Icon(icon),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOrder() async {
    setState(() {
      _saving = true;
    });
    ApiResult result = await OrderRepository.add(
      memberId: _memberId!,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      note: _noteController.text.trim(),
      paymentMethod: _payment,
      carts: _carts,
    );
    if (!mounted) return;
    if (result.success) {
      await CartRepository.clear(_memberId!);
      await NotificationRepository.refresh();
      if (!mounted) return;
      showMessage(context, result.message);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/order_detail',
        ModalRoute.withName('/'),
        arguments: result.id,
      );
    } else {
      setState(() {
        _saving = false;
        _error = result.message;
      });
    }
  }
}
