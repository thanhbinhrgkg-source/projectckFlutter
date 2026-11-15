import 'package:flutter/foundation.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/db_helper.dart';
import 'package:projectck/session_helper.dart';
import 'package:sqflite/sqflite.dart';

class CartRepository {
  static final ValueNotifier<int> count = ValueNotifier(0);

  static Future<void> refreshCount() async {
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) {
      count.value = 0;
      return;
    }
    Database db = await DbHelper.instance.database;
    var data = await db.rawQuery(
      "SELECT SUM(quantity) AS total FROM cart WHERE memberId = ?",
      [memberId],
    );
    count.value = (data.first['total'] as int?) ?? 0;
  }

  static Future<int> add(Cart obj) async {
    Database db = await DbHelper.instance.database;
    var data = await db.query(
      'cart',
      where: 'memberId = ? AND productId = ?',
      whereArgs: [obj.memberId, obj.productId],
    );
    int ret;
    if (data.isEmpty) {
      ret = await db.insert('cart', obj.toMap());
    } else {
      Cart cart = Cart.fromMap(data.first);
      ret = await db.update(
        'cart',
        {'quantity': cart.quantity + obj.quantity, 'price': obj.price},
        where: 'id = ?',
        whereArgs: [cart.id],
      );
    }
    await refreshCount();
    return ret;
  }

  static Future<int> updateQuantity(int id, int quantity) async {
    Database db = await DbHelper.instance.database;
    int ret = await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
    await refreshCount();
    return ret;
  }

  static Future<int> delete(int id) async {
    Database db = await DbHelper.instance.database;
    int ret = await db.delete('cart', where: 'id = ?', whereArgs: [id]);
    await refreshCount();
    return ret;
  }

  static Future<int> clear(String memberId) async {
    Database db = await DbHelper.instance.database;
    int ret = await db.delete(
      'cart',
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
    await refreshCount();
    return ret;
  }

  static Future<List<Cart>> getCarts(String memberId) async {
    Database db = await DbHelper.instance.database;
    List<Map<String, Object?>> data = await db.query(
      'cart',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'id',
    );
    return data.map(Cart.fromMap).toList();
  }
}
