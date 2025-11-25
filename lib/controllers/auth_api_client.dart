import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiClient extends http.BaseClient {
  final http.Client _inner;
  AuthApiClient(this._inner);

  static bool ignore401 = true; // 🟢 <— prevents unwanted logout

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('token');

    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    http.StreamedResponse response;

    try {
      response = await _inner.send(request);
    } catch (e) {
      print("🌐 Network error during HTTP request: $e");
      throw Exception("Network error: $e");
    }

    // 🛑 Previously this would trigger Splash logout indirectly!
    if (response.statusCode == 401) {
      print("🛑 401 Unauthorized for ${request.method} ${request.url}");

      final bodyString = await _readResponseAsString(response);
      print("🔍 401 body: $bodyString");

      // 🟢 FIX: Ignore 401 unless REAL logout is required
      if (!ignore401) {
        // Here you may force logout or refresh token
      }

      // Pass response normally (no forced logout)
    }

    return response;
  }

  Future<String> _readResponseAsString(http.StreamedResponse response) async {
    final completer = Completer<String>();
    final contents = StringBuffer();
    response.stream.transform(utf8.decoder).listen(
          contents.write,
          onDone: () => completer.complete(contents.toString()),
          onError: completer.completeError,
          cancelOnError: true,
        );
    return completer.future;
  }

  // === Helper methods ===

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final request = http.Request('GET', url);
    if (headers != null) request.headers.addAll(headers);
    return http.Response.fromStream(await send(request));
  }

  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final request = http.Request('POST', url)
      ..headers.addAll(headers ?? {})
      ..encoding = encoding ?? utf8;
    if (body != null) request.body = _serializeBody(body);
    return http.Response.fromStream(await send(request));
  }

  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final request = http.Request('PUT', url)
      ..headers.addAll(headers ?? {})
      ..encoding = encoding ?? utf8;
    if (body != null) request.body = _serializeBody(body);
    return http.Response.fromStream(await send(request));
  }

  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final request = http.Request('PATCH', url)
      ..headers.addAll(headers ?? {})
      ..encoding = encoding ?? utf8;
    if (body != null) request.body = _serializeBody(body);
    return http.Response.fromStream(await send(request));
  }

  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final request = http.Request('DELETE', url)
      ..headers.addAll(headers ?? {})
      ..encoding = encoding ?? utf8;
    if (body != null) request.body = _serializeBody(body);
    return http.Response.fromStream(await send(request));
  }

  String _serializeBody(Object body) {
    if (body is String) return body;
    if (body is List<int>) return utf8.decode(body);
    return jsonEncode(body);
  }
}
