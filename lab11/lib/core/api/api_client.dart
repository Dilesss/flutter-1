import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Everything about the wire lives here: the host, the headers, the
/// timeout, and turning statuses and broken JSON into ApiException.
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  /// The real client, for the app. Tests can pass their own http.Client.
  factory ApiClient.live() => ApiClient(http.Client());

  final http.Client _client;
  final String host;

  /// Headers in one place.
  Map<String, String> get headers => const {'Accept': 'application/json'};
  Map<String, String> get jsonHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Addresses are built with Uri.https — never by gluing strings.
  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  /// Runs one request: send (with a timeout), check the status, decode.
  /// [expect] is the status a success must have (200, or 201 for POST).
  Future<dynamic> run(
    Future<http.Response> Function(http.Client client) call, {
    int expect = 200,
  }) async {
    final response = await _send(() => call(_client));
    _check(response);
    if (response.statusCode != expect) {
      throw BadResponseException('expected $expect, got ${response.statusCode}');
    }
    return _decode(response);
  }

  /// No answer at all → NoConnectionException.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url} '
          '→ ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // In the browser (Chrome) a dead network arrives as a ClientException.
      throw const NoConnectionException();
    }
  }

  /// The status is checked BEFORE the body, every time.
  void _check(http.Response r) {
    final code = r.statusCode;
    if (code == 401) throw const UnauthorizedException();
    if (code == 404) throw const NotFoundException();
    if (code >= 500) throw ServerException(code);
    if (code >= 400) throw BadResponseException('status $code');
  }

  /// Text that is not JSON → BadResponseException.
  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }
}
