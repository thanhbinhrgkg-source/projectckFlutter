import 'package:flutter/material.dart';
import 'package:projectck/api_helper.dart';
import 'package:projectck/helper.dart';

class StatsPage extends StatefulWidget {
  final String _title;
  const StatsPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _stats;
  int _days = 7;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await ApiHelper.getOne('/stats?days=$_days');
    if (!mounted) return;
    setState(() {
      _stats = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _stats == null
          ? buildEmpty(Icons.cloud_off, 'Không tải được thống kê')
          : ListView(
              padding: EdgeInsets.all(12),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildKpi(
                      Icons.payments,
                      'Doanh thu',
                      Helper.money(_stats!['revenue']),
                      Colors.green,
                    ),
                    _buildKpi(
                      Icons.receipt_long,
                      'Đơn hàng',
                      '${_stats!['orderCount']}',
                      Colors.blue,
                    ),
                    _buildKpi(
                      Icons.group,
                      'Thành viên',
                      '${_stats!['memberCount']}',
                      Colors.purple,
                    ),
                    _buildKpi(
                      Icons.inventory_2,
                      'Gói dịch vụ',
                      '${_stats!['productCount']}',
                      Colors.orange,
                    ),
                    _buildKpi(
                      Icons.assignment,
                      'Khảo sát',
                      '${_stats!['surveyCount']}',
                      Colors.teal,
                    ),
                    _buildKpi(
                      Icons.how_to_vote,
                      'Lượt trả lời',
                      '${_stats!['responseCount']}',
                      Colors.indigo,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildChart(),
                _buildStatus(),
                _buildTop(),
              ],
            ),
    );
  }

  Widget _buildKpi(IconData icon, String label, String value, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChart() {
    List days = _stats!['byDay'];
    num maxValue = 1;
    for (var p in days) {
      if ((p['total'] as num) > maxValue) maxValue = p['total'];
    }
    Color primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildTitle('Doanh thu theo ngày')),
                ChoiceChip(
                  label: Text('7 ngày'),
                  selected: _days == 7,
                  onSelected: (val) => _onDays(7),
                ),
                SizedBox(width: 6),
                ChoiceChip(
                  label: Text('30 ngày'),
                  selected: _days == 30,
                  onSelected: (val) => _onDays(30),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((p) {
                  num total = p['total'];
                  String date = p['date'];
                  return Expanded(
                    child: Tooltip(
                      message:
                          '$date: ${Helper.money(total)} (${p['orders']} đơn)',
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 4 + 120 * total / maxValue,
                              decoration: BoxDecoration(
                                color: total > 0
                                    ? primary
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            if (_days == 7)
                              Text(
                                date.substring(8),
                                style: TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    List items = _stats!['byStatus'];
    int total = 0;
    for (var p in items) {
      total += p['total'] as int;
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('Đơn hàng theo trạng thái'),
            SizedBox(height: 12),
            ...items.map((p) {
              int count = p['total'];
              Color color = Helper.statusColor(p['id']);
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(p['name'])),
                        Text(
                          '$count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : count / total,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    List items = _stats!['topProducts'];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('Gói dịch vụ bán chạy'),
            SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            for (int i = 0; i < items.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: buildImage(
                    items[i]['imageUrl'],
                    width: 56,
                    height: 40,
                  ),
                ),
                title: Text('${i + 1}. ${items[i]['name']}'),
                subtitle: Text('Đã bán ${items[i]['quantity']} gói'),
                trailing: Text(
                  Helper.money(items[i]['revenue']),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onDays(int days) {
    setState(() {
      _days = days;
    });
    _loadData();
  }
}
