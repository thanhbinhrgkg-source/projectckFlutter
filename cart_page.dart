import 'package:flutter/material.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/session_helper.dart';

class CartPage extends StatefulWidget {
  final String _title;
  const CartPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Cart> _carts = [];

  @override
  void initState() {
    super.initState();
    _loadCarts();
  }

  void _loadCarts() async {
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) return;
    var data = await CartRepository.getCarts(memberId);
    if (!mounted) return;
    setState(() {
      _carts = data;
    });
  }

  double get _total => _carts.fold(0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: _carts.isEmpty
          ? buildEmpty(Icons.remove_shopping_cart, 'Giỏ hàng đang trống')
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _carts.length,
              itemBuilder: (context, index) => _buildItem(_carts[index]),
            ),
      bottomNavigationBar: _carts.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE6E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            Helper.money(_total),
                            style: TextStyle(
                              fontSize: 20,
                              color: color.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _onCheckout,
                      label: Text('Đặt hàng'),
                      icon: Icon(Icons.shopping_cart_checkout),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildItem(Cart item) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildImage(item.imageUrl, width: 80, height: 80),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    Helper.money(item.price),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: item.quantity > 1
                            ? () => _onQuantity(item, item.quantity - 1)
                            : null,
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _onQuantity(item, item.quantity + 1),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            Helper.money(item.amount),
                            style: TextStyle(
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
            IconButton(
              onPressed: () => _onDelete(item),
              tooltip: 'Xóa',
              icon: Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _onQuantity(Cart item, int quantity) async {
    await CartRepository.updateQuantity(item.id!, quantity);
    _loadCarts();
  }

  void _onDelete(Cart item) async {
    int ret = await CartRepository.delete(item.id!);
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Đã xóa "${item.name}" khỏi giỏ hàng');
      _loadCarts();
    } else {
      showMessage(context, 'Xóa thất bại');
    }
  }

  void _onCheckout() async {
    await Navigator.pushNamed(context, '/checkout');
    _loadCarts();
  }
}
