import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionHelper {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<void> save(
    String memberId,
    String email,
    String role,
    String token,
  ) async {
    await _storage.write(key: 'memberId', value: memberId);
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'role', value: role);
  }

  static Future<String?> get memberId async {
    return await _storage.read(key: 'memberId');
  }

  static Future<String?> get email async {
    return await _storage.read(key: 'email');
  }

  static Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  static Future<String?> get role async {
    return await _storage.read(key: 'role');
  }

  static Future<void> delete() async {
    await _storage.delete(key: 'memberId');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'token');
  }
}
