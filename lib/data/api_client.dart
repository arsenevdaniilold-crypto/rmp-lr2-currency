import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Бесплатное API без ключа: https://www.exchangerate-api.com/docs/free
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://open.er-api.com/v6/latest';

  final http.Client _client;

  Future<Map<String, dynamic>> getLatest(String baseCurrency) async {
    final uri = Uri.parse('$_baseUrl/$baseCurrency');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw ApiException('Сервер не отвечает. Попробуйте позже');
    } catch (_) {
      throw ApiException('Нет подключения к интернету');
    }

    if (response.statusCode != 200) {
      throw ApiException('Ошибка сервера (код ${response.statusCode})');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Некорректный ответ сервера');
    }
  }
}
