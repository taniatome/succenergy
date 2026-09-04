import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'api_exception.dart';

/// The only file in the app that builds an HTTP request.
///
/// Every call carries a fresh Firebase ID token. The token is asked for
/// immediately before the request and dropped immediately after: the SDK
/// keeps it in the platform keystore and refreshes it on its own, so a copy
/// held here would be a second place for it to leak from and no faster.
///
/// A 401 is retried exactly once behind a forced refresh, which covers a
/// token that expired mid-flight. A second 401 means the session was revoked
/// server-side — the account was disabled or deleted — so the client signs
/// out and lets the router take the app back to Welcome. It never navigates
/// itself.
class ApiClient {
  ApiClient({FirebaseAuth? auth, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _http = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _http;

  /// Decoded `data` envelope from `GET <path>`.
  Future<Map<String, Object?>> get(String path) => _send('GET', path);

  /// The `data` array from a list endpoint.
  ///
  /// Reads that answer with a JSON array need their own accessor: [get]
  /// unwraps the envelope to the object inside it, and a list is not one, so
  /// it hands back the envelope instead. This takes the array out of it.
  Future<List<Object?>> getAll(String path) async {
    final Map<String, Object?> envelope = await _send('GET', path);
    final Object? data = envelope['data'];
    return data is List ? data : const <Object?>[];
  }

  /// Decoded `data` envelope from `POST <path>`.
  Future<Map<String, Object?>> post(
    String path, {
    Map<String, Object?>? body,
  }) => _send('POST', path, body: body);

  /// Decoded `data` envelope from `PATCH <path>`.
  Future<Map<String, Object?>> patch(
    String path, {
    Map<String, Object?>? body,
  }) => _send('PATCH', path, body: body);

  /// Decoded `data` envelope from `DELETE <path>`.
  Future<Map<String, Object?>> delete(String path) => _send('DELETE', path);

  void close() => _http.close();

  Uri _uri(String path) =>
      Uri.parse('${AppConstants.apiBaseUrl}/${AppConstants.apiVersion}$path');

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    http.Response response = await _dispatch(
      method,
      path,
      body,
      refresh: false,
    );

    if (response.statusCode == 401) {
      response = await _dispatch(method, path, body, refresh: true);
      if (response.statusCode == 401) {
        await _auth.signOut();
        throw const ApiException(ApiFailureKind.unauthorized, status: 401);
      }
    }

    return _decode(response);
  }

  Future<http.Response> _dispatch(
    String method,
    String path,
    Map<String, Object?>? body, {
    required bool refresh,
  }) async {
    final String? token = await _token(refresh: refresh);
    if (token == null) {
      throw const ApiException(ApiFailureKind.unauthorized);
    }

    final Uri uri = _uri(path);
    final Map<String, String> headers = <String, String>{
      'authorization': 'Bearer $token',
      'accept': 'application/json',
      if (body != null) 'content-type': 'application/json',
    };
    final String? encoded = body == null ? null : jsonEncode(body);

    try {
      return await _request(
        method,
        uri,
        headers,
        encoded,
      ).timeout(AppConstants.apiTimeout);
    } on TimeoutException {
      throw const ApiException(ApiFailureKind.offline);
    } on http.ClientException {
      throw const ApiException(ApiFailureKind.offline);
    }
  }

  Future<http.Response> _request(
    String method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) {
    switch (method) {
      case 'POST':
        return _http.post(uri, headers: headers, body: body);
      case 'PATCH':
        return _http.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return _http.delete(uri, headers: headers);
      default:
        return _http.get(uri, headers: headers);
    }
  }

  /// A live ID token, or null when nobody is signed in.
  ///
  /// A failure to mint one is treated as offline rather than as a rejection:
  /// the SDK reaches the network to refresh, and a flat has nothing to do
  /// with whether the account is still valid.
  Future<String?> _token({required bool refresh}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      return await user.getIdToken(refresh);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-token-expired' ||
          error.code == 'user-disabled' ||
          error.code == 'user-not-found') {
        return null;
      }
      throw const ApiException(ApiFailureKind.offline);
    }
  }

  /// The `data` envelope, or the mapped failure the status and body describe.
  Map<String, Object?> _decode(http.Response response) {
    final Map<String, Object?> payload = _json(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Object? data = payload['data'];
      return data is Map<String, Object?> ? data : payload;
    }

    final Object? error = payload['error'];
    final String? code =
        error is Map<String, Object?> ? error['code'] as String? : null;

    throw ApiException(
      response.statusCode == 404
          ? ApiFailureKind.notFound
          : response.statusCode == 401 || response.statusCode == 403
          ? ApiFailureKind.unauthorized
          : ApiFailureKind.server,
      code: code,
      status: response.statusCode,
    );
  }

  Map<String, Object?> _json(String body) {
    if (body.isEmpty) {
      return const <String, Object?>{};
    }
    try {
      final Object? decoded = jsonDecode(body);
      return decoded is Map<String, Object?>
          ? decoded
          : const <String, Object?>{};
    } on FormatException {
      // A body that is not JSON is a proxy or a captive portal answering, not
      // the API. Nothing here can act on it.
      return const <String, Object?>{};
    }
  }
}
