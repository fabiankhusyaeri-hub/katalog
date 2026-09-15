import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WaService {
  static const String _apiUrl = 'https://api.fonnte.com/send';
  static const String _authorization = 'vvLu1CSUu6RSFcTRuCUu';
  static const String _target = '081546487201';

  static Future<bool> sendNotification(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': _authorization,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'target': _target, 'message': message},
      );

      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('Fonnte response status: ${response.statusCode}');
      debugPrint('Fonnte response body: $responseBody');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Fonnte returned non-2xx status');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Fonnte sendNotification error: $e');
      return false;
    }
  }
}
