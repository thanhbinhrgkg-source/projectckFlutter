import 'package:projectck/api_helper.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/authen_result.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/member.dart';
import 'package:projectck/session_helper.dart';

class MemberRepository {
  static Future<ApiResult> register(
    String email,
    String password,
    String givenName,
    String surname,
  ) async {
    return ApiResult.fromData(
      await ApiHelper.post('/register', {
        'email': email,
        'password': password,
        'givenName': givenName,
        'surname': surname,
      }),
    );
  }

  static Future<ApiResult> sendCode(String email) async {
    return ApiResult.fromData(
      await ApiHelper.post('/send-code', {'email': email}),
    );
  }

  static Future<ApiResult> verify(String email, String code) async {
    return ApiResult.fromData(
      await ApiHelper.post('/verify', {'email': email, 'code': code}),
    );
  }

  static Future<ApiResult> forgotPassword(String email) async {
    return ApiResult.fromData(
      await ApiHelper.post('/forgot-password', {'email': email}),
    );
  }

  static Future<ApiResult> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    return ApiResult.fromData(
      await ApiHelper.post('/reset-password', {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
  }

  static Future<ApiResult> changePassword(
    String id,
    String oldPassword,
    String newPassword,
  ) async {
    return ApiResult.fromData(
      await ApiHelper.put('/members/$id/password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
  }

  static Future<Member?> getMemberById(String id) async {
    var data = await ApiHelper.getOne('/members/$id');
    if (data != null) {
      return Member.fromMap(data);
    }
    return null;
  }

  static Future<AuthenResult> login(String email, String password) async {
    var data = await ApiHelper.post('/login', {
      'email': email,
      'password': password,
    });
    if (data == null) {
      return AuthenResult(
        success: false,
        message: "Không kết nối được máy chủ",
      );
    }
    if (data['success'] == true) {
      Member obj = Member.fromMap(data['member']);
      await SessionHelper.save(obj.id, obj.email, obj.roleName!);
      await CartRepository.refreshCount();
    }
    return AuthenResult(
      success: data['success'],
      message: data['message'],
      needVerify: data['needVerify'] == true,
    );
  }

  static Future<void> logout() async {
    await SessionHelper.delete();
    await CartRepository.refreshCount();
  }

  static Future<int> delete(String id) async {
    return ApiHelper.toInt(await ApiHelper.delete('/members/$id'));
  }

  static Future<int> updateRole(String id, int roleId) async {
    return ApiHelper.toInt(
      await ApiHelper.put('/members/$id/role', {'roleId': roleId}),
    );
  }

  static Future<List<Member>> getMembersWithRole() async {
    var data = await ApiHelper.getList('/members');
    return data.map(Member.fromMap).toList();
  }
}
