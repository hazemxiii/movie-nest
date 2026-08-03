import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/extensions/response_ext.dart';
import 'package:movie_nest/core/services/nest_logger.dart';

enum ApiMethod { get, post, patch, delete }

const fakeToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhNjA1Y2FmYTczZjQ0N2JjNDAwNmE0YiIsImVtYWlsIjoidXNlcjFAZW1haWwuY29tIiwiaWF0IjoxNzg0NzAwNDY4LCJleHAiOjE3ODk4ODQ0Njh9.tCErkXQWZ_q4sNZhrMCbfCyrhFyrz8C2EuKG15BA3f4';

class ApiService {
  // final _baseUrl = 'https://movie-nest-api.vercel.app';
  final _baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> fetch(
    String endpoint,
    ApiMethod method, {
    Map<String, String>? headers,
    dynamic requestBody,
    bool logResponse = false,
    bool encodeBody = true,
  }) async {
    late final http.Response response;
    final baseHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $fakeToken',
      ...?headers,
    };
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      NestLogger.log(
        'Calling ${method.name.toUpperCase()} $url with body: $requestBody',
      );
      switch (method) {
        case ApiMethod.get:
          response = await http.get(url, headers: baseHeaders);
          break;
        case ApiMethod.post:
          response = await http.post(
            url,
            headers: baseHeaders,
            body: encodeBody ? jsonEncode(requestBody) : requestBody,
          );
          break;
        case ApiMethod.patch:
          response = await http.patch(
            url,
            headers: baseHeaders,
            body: encodeBody ? jsonEncode(requestBody) : requestBody,
          );
          break;
        case ApiMethod.delete:
          response = await http.delete(url, headers: baseHeaders);
          break;
      }
    } catch (e) {
      final error = NestInternetException("Couldn't connect to the server");
      NestLogger.logError(e.toString());
      throw error;
    }
    late final Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body));
      if (logResponse) {
        NestLogger.log('Response: $body');
      }
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
      body['message']?.toString() ??
          body['error']?.toString() ??
          'Unknown server error',
    );
    NestLogger.logError(error.toString());
    throw error;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
