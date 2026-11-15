import 'package:flutter/material.dart';
import 'package:projectck/app_notification.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/notification_repository.dart';

class NotificationPage extends StatefulWidget {
  final String _title;
  const NotificationPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    var data = await NotificationRepository.getNotifications();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        actions: [
          IconButton(
            onPressed: _items.isEmpty ? null : _onReadAll,
            tooltip: 'Đánh dấu đã đọc tất cả',
            icon: Icon(Icons.done_all),
          ),
          IconButton(
            onPressed: _items.isEmpty ? null : _onClear,
            tooltip: 'Xóa tất cả',
            icon: Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmpty(Icons.notifications_off_outlined, 'Chưa có thông báo')
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) => _buildItem(_items[index]),
            ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long;
      case 'admin_order':
        return Icons.local_shipping;
      case 'survey':
        return Icons.assignment;
      default:
        return Icons.person;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'admin_order':
        return Colors.orange;
      case 'survey':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Widget _buildItem(AppNotification item) {
    Color color = _color(item.type);
    return Card(
      color: item.isRead ? Colors.white : Color(0xFFEEF0FF),
      child: InkWell(
        onTap: () => _onOpen(item),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(_icon(item.type), color: color),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: item.isRead
                            ? FontWeight.w500
                            : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.content,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.createdDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOpen(AppNotification item) async {
    if (!item.isRead) {
      await NotificationRepository.markRead(item.id);
      _loadData();
    }
    if (!mounted || item.refId == null) return;
    if (item.type == 'order' || item.type == 'admin_order') {
      await Navigator.pushNamed(
        context,
        '/order_detail',
        arguments: item.refId,
      );
    } else if (item.type == 'survey') {
      await Navigator.pushNamed(context, '/take', arguments: item.refId);
    }
  }

  void _onReadAll() async {
    await NotificationRepository.markAllRead();
    if (!mounted) return;
    showMessage(context, 'Đã đánh dấu đọc tất cả');
    _loadData();
  }

  void _onClear() async {
    var confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa thông báo'),
          content: Text('Xóa tất cả thông báo của bạn?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await NotificationRepository.clear();
    if (!mounted) return;
    showMessage(context, 'Đã xóa tất cả thông báo');
    _loadData();
  }
}
