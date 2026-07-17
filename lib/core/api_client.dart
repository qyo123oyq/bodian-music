import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...AppConfig.deviceHeaders,
      };

  /// 通用GET请求
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    int retryCount = 2,
  }) async {
    String requestUrl = url;
    if (params != null && params.isNotEmpty) {
      final queryString = Uri(queryParameters: params.map(
        (key, value) => MapEntry(key, value.toString()),
      )).query;
      requestUrl += '?$queryString';
    }

    int attempts = 0;
    while (attempts <= retryCount) {
      try {
        final response = await _client.get(
          Uri.parse(requestUrl),
          headers: {..._defaultHeaders, ...?headers},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return _parseResponse(response.body);
        } else if (response.statusCode >= 500 && attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        } else {
          throw Exception('请求失败: ${response.statusCode}');
        }
      } on SocketException catch (e) {
        if (attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        throw Exception('网络连接失败: $e');
      } catch (e) {
        if (attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('请求失败');
  }

  /// 通用POST请求
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    int retryCount = 2,
  }) async {
    int attempts = 0;
    while (attempts <= retryCount) {
      try {
        final response = await _client
            .post(
              Uri.parse(url),
              headers: {..._defaultHeaders, ...?headers},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return _parseResponse(response.body);
        } else if (response.statusCode >= 500 && attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        } else {
          throw Exception('请求失败: ${response.statusCode}');
        }
      } on SocketException catch (e) {
        if (attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        throw Exception('网络连接失败: $e');
      } catch (e) {
        if (attempts < retryCount) {
          attempts++;
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('请求失败');
  }

  /// 解析响应
  Map<String, dynamic> _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      }
      return {'raw': body};
    } catch (e) {
      return {'raw': body};
    }
  }

  /// 生成MD5签名
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  void dispose() {
    _client.close();
  }
}
