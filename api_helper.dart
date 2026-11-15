import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:projectck/session_helper.dart';

class ApiHelper {
  static String get host =>
      Platform.isAndroid ? 'http://10.0.2.2:5100' : 'http://localhost:5100';
  static String get baseUrl => '$host/api';
  static Future<Map<String, String>> _headers({bool json = true}) async {
    String? token = await SessionHelper.token;
    return {
      if (json) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static int lastStatus = 0;

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '$host$path';
  }

  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      lastStatus = 0;
      http.Response res = await request().timeout(Duration(seconds: 15));
      lastStatus = res.statusCode;
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          res.body.isNotEmpty) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (e) {
      debugPrint('API error: $e');
    }
    return null;
  }

  static Future<dynamic> get(String path) {
    return _send(() async => http.get(_uri(path), headers: await _headers()));
  }

  static Future<dynamic> post(String path, Object body) {
    return _send(
      () async => http.post(
        _uri(path),
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<dynamic> put(String path, Object body) {
    return _send(
      () async => http.put(
        _uri(path),
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  static Future<dynamic> delete(String path) {
    return _send(
      () async => http.delete(_uri(path), headers: await _headers()),
    );
  }

  static Future<dynamic> sendForm(
    String method,
    String path,
    Map<String, String> fields,
    String? filePath,
  ) {
    return _send(() async {
      var request = http.MultipartRequest(method, _uri(path));
      request.headers.addAll(await _headers(json: false));
      request.fields.addAll(fields);
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      }
      return http.Response.fromStream(await request.send());
    });
  }

  static Future<List<Map<String, dynamic>>> getList(String path) async {
    var data = await get(path);
    return data is List ? data.cast<Map<String, dynamic>>() : [];
  }

  static Future<Map<String, dynamic>?> getOne(String path) async {
    var data = await get(path);
    return data is Map<String, dynamic> ? data : null;
  }

  static int toInt(dynamic data) {
    return data is int ? data : 0;
  }

  static String query(Map<String, Object?> params) {
    var list = params.entries
        .where((p) => p.value != null && p.value.toString().isNotEmpty)
        .map((p) => '${p.key}=${Uri.encodeQueryComponent(p.value.toString())}')
        .toList();
    return list.isEmpty ? '' : '?${list.join('&')}';
  }
}
