import 'package:projectck/api_helper.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/category.dart';
import 'package:projectck/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  static Future<List<Category>> getCategories() async {
    Database db = await DbHelper.instance.database;
    var data = await ApiHelper.get('/categories');
    if (data is List) {
      List<Category> list = data
          .cast<Map<String, dynamic>>()
          .map(Category.fromMap)
          .toList();
      await db.delete('category');
      for (Category item in list) {
        await db.insert('category', item.toMap());
      }
      return list;
    }
    List<Map<String, Object?>> cache = await db.query('category');
    return cache.map(Category.fromMap).toList();
  }

  static Future<ApiResult> add(
    String name,
    String description,
    String? imagePath,
  ) async {
    return ApiResult.fromData(
      await ApiHelper.sendForm('POST', '/categories', {
        'name': name,
        'description': description,
      }, imagePath),
    );
  }

  static Future<ApiResult> update(
    int id,
    String name,
    String description,
    String? imagePath,
    bool removeImage,
  ) async {
    return ApiResult.fromData(
      await ApiHelper.sendForm('PUT', '/categories/$id', {
        'name': name,
        'description': description,
        'removeImage': removeImage ? '1' : '0',
      }, imagePath),
    );
  }

  static Future<ApiResult> delete(int id) async {
    return ApiResult.fromData(await ApiHelper.delete('/categories/$id'));
  }
}
