import 'package:projectck/api_helper.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/page_result.dart';
import 'package:projectck/product.dart';

class ProductRepository {
  static Future<PageResult<Product>> getProducts({
    int? categoryId,
    String keyword = '',
    int page = 1,
    int pageSize = 6,
  }) async {
    var data = await ApiHelper.getOne(
      '/products${ApiHelper.query({'categoryId': categoryId, 'keyword': keyword, 'page': page, 'pageSize': pageSize})}',
    );
    if (data == null) return PageResult.empty();
    return PageResult.fromMap(data, Product.fromMap);
  }

  static Future<PageResult<Product>> getRelated(
    int id, {
    int page = 1,
    int pageSize = 4,
  }) async {
    var data = await ApiHelper.getOne(
      '/products/$id/related${ApiHelper.query({'page': page, 'pageSize': pageSize})}',
    );
    if (data == null) return PageResult.empty();
    return PageResult.fromMap(data, Product.fromMap);
  }

  static Future<Product?> getProductById(int id) async {
    var data = await ApiHelper.getOne('/products/$id');
    if (data != null) {
      return Product.fromMap(data);
    }
    return null;
  }

  static Future<ApiResult> add(Product obj, String? imagePath) async {
    return ApiResult.fromData(
      await ApiHelper.sendForm('POST', '/products', obj.toForm(), imagePath),
    );
  }

  static Future<ApiResult> update(Product obj, String? imagePath) async {
    return ApiResult.fromData(
      await ApiHelper.sendForm(
        'PUT',
        '/products/${obj.id}',
        obj.toForm(),
        imagePath,
      ),
    );
  }

  static Future<ApiResult> delete(int id) async {
    return ApiResult.fromData(await ApiHelper.delete('/products/$id'));
  }
}
