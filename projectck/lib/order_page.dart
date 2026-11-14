import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/order.dart';
import 'package:projectck/order_repository.dart';
import 'package:projectck/order_status.dart';
import 'package:projectck/session_helper.dart';

class OrderPage extends StatefulWidget {
  final String _title;
  final bool isAdmin;
  const OrderPage({super.key, required this._title, this.isAdmin = false});

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> _orders = [];
  List<OrderStatus> _statuses = [];
  int? _statusId;
  DateTimeRange? _range;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
    _loadOrders();
  }

  void _loadStatuses() async {
    var data = await OrderRepository.getStatuses();
    if (!mounted) return;
    setState(() {
      _statuses = data;
    });
  }

  void _loadOrders() async {
    String? memberId = widget.isAdmin ? null : await SessionHelper.memberId;
    if (!widget.isAdmin && memberId == null) return;
    var data = await OrderRepository.getOrders(
      memberId: memberId,
      keyword: _searchController.text.trim(),
      fromDate: _range?.start,
      toDate: _range?.end,
      statusId: _statusId,
    );
    if (!mounted) return;
    setState(() {
      _orders = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.isAdmin
                        ? 'Tìm mã đơn, khách hàng, email, SĐT, gói...'
                        : 'Tìm mã đơn hoặc tên gói dịch vụ...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => _loadOrders(),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onPickDate,
                        icon: Icon(Icons.date_range),
                        label: Text(
                          _range == null
                              ? 'Lọc theo ngày đặt'
                              : '${Helper.date(_range!.start)} - ${Helper.date(_range!.end)}',
                        ),
                      ),
                    ),
                    if (_range != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _range = null;
                          });
                          _loadOrders();
                        },
                        icon: Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Tất cả'),
                    selected: _statusId == null,
                    onSelected: (val) => _onStatus(null),
                  ),
                ),
                ..._statuses.map((p) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.name),
                      selected: _statusId == p.id,
                      onSelected: (val) => _onStatus(val ? p.id : null),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? buildEmpty(Icons.receipt_long, 'Không có đơn hàng nào')
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) =>
                        _buildOrder(_orders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrder(Order item) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => _onDetail(item.id),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: color.primary),
                  SizedBox(width: 8),
                  Text(
                    item.code,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  buildTag(item.statusName, Helper.statusColor(item.statusId)),
                ],
              ),
              SizedBox(height: 8),
              if (widget.isAdmin && item.memberEmail != null)
                Text(
                  item.memberEmail!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              Text('${item.fullName} • ${item.phone}'),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${item.createdDate} • ${item.itemCount} gói',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    Helper.money(item.total),
                    style: TextStyle(
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
    );
  }

  void _onStatus(int? id) {
    setState(() {
      _statusId = id;
    });
    _loadOrders();
  }

  void _onPickDate() async {
    DateTime now = DateTime.now();
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
      helpText: 'Chọn khoảng ngày đặt hàng',
    );
    if (range == null) return;
    setState(() {
      _range = range;
    });
    _loadOrders();
  }

  void _onDetail(int id) async {
    await Navigator.pushNamed(context, '/order_detail', arguments: id);
    _loadOrders();
  }
}
