import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/extensions/response_ext.dart';
import 'package:movie_nest/core/services/nest_logger.dart';

class ApiService {
  final _baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> get(String endpoint) async {
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-token-here',
        },
      );
    } catch (e) {
      final error = NestInternetException("Couldn't connect to the server");
      NestLogger.logError(e.toString());
      throw error;
    }
    late final Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      final error = NestSecretException('PRS_SERVER_001');
      NestLogger.logError(e.toString(), code: error.objectCode);
      throw error;
    }
    if (response.ok) {
      return body;
    } else if (response.statusCode == 500) {
      final error = NestInternetException('Internal server error');
      NestLogger.logError('Internal server error');
      throw error;
    }
    final error = NestException(
      body['message'] ?? body['error'] ?? 'Unknown server error',
    );
    NestLogger.logError(error.toString());
    throw error;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
