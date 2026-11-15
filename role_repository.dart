import 'package:projectck/api_helper.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/role.dart';

class RoleRepository {
  static Future<List<Role>> getRoles() async {
    var data = await ApiHelper.getList('/roles');
    return data.map(Role.fromMap).toList();
  }

  static Future<ApiResult> add(String name) async {
    return ApiResult.fromData(await ApiHelper.post('/roles', {'name': name}));
  }

  static Future<ApiResult> update(int id, String name) async {
    return ApiResult.fromData(
      await ApiHelper.put('/roles/$id', {'name': name}),
    );
  }

  static Future<ApiResult> delete(int id) async {
    return ApiResult.fromData(await ApiHelper.delete('/roles/$id'));
  }
}
