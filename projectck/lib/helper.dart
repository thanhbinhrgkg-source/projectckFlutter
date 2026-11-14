import 'dart:math';

import 'package:flutter/material.dart';
import 'package:projectck/api_helper.dart';

void showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );
}

Widget buildTag(String text, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Widget buildEmpty(IconData icon, String msg) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade400),
          SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}

Widget buildImage(
  String? path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  Widget placeholder = Container(
    width: width,
    height: height,
    color: Colors.grey.shade200,
    child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
  );
  if (path == null || path.isEmpty) return placeholder;
  return Image.network(
    ApiHelper.imageUrl(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stack) => placeholder,
  );
}

Widget buildPager(int page, int totalPages, ValueChanged<int> onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: page > 1 ? () => onChanged(page - 1) : null,
        icon: Icon(Icons.chevron_left),
      ),
      Text(
        'Trang $page / $totalPages',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      IconButton(
        onPressed: page < totalPages ? () => onChanged(page + 1) : null,
        icon: Icon(Icons.chevron_right),
      ),
    ],
  );
}

Widget buildSearchHeader(
  BuildContext context, {
  required String title,
  required String subtitle,
  required TextEditingController controller,
  required String hint,
  required ValueChanged<String> onChanged,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.search),
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

Widget buildFormCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  ColorScheme color = Theme.of(context).colorScheme;
  return Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: color.primaryContainer,
                  child: Icon(icon, size: 36, color: color.primary),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildMessage(String? error, String? info) {
  if (error == null && info == null) return SizedBox.shrink();
  bool isError = error != null;
  return Container(
    margin: EdgeInsets.only(top: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isError ? Colors.red.shade50 : Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? Colors.red : Colors.green,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            error ?? info!,
            style: TextStyle(
              color: isError ? Colors.red.shade800 : Colors.green.shade800,
            ),
          ),
        ),
      ],
    ),
  );
}

class Helper {
  static String randomString(int len) {
    String pattern = "1234567890qwertyuiopasdfghjklzxcvbnm";
    List<String> list = [];
    Random rand = Random();
    for (int i = 0; i < len; i++) {
      list.add(pattern[rand.nextInt(pattern.length)]);
    }
    return list.join();
  }

  static String money(num value) {
    String s = value.round().toString();
    String result = '';
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result += '.';
      result += s[i];
    }
    return '$result đ';
  }

  static String date(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  static String apiDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }

  static IconData topicIcon(int topicId) {
    switch (topicId) {
      case 1:
        return Icons.people_alt;
      case 2:
        return Icons.badge;
      case 3:
        return Icons.inventory_2;
      case 4:
        return Icons.trending_up;
      default:
        return Icons.assignment;
    }
  }

  static Color topicColor(int topicId) {
    switch (topicId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  static Color roleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Colors.teal;
    }
  }

  static Color statusColor(int statusId) {
    switch (statusId) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  static String paymentLabel(String method) {
    return method == 'VIETQR'
        ? 'Chuyển khoản VietQR'
        : 'Thanh toán khi nghiệm thu';
  }

  static String initial(String? text) {
    if (text == null || text.trim().isEmpty) return '?';
    return text.trim()[0].toUpperCase();
  }
}
