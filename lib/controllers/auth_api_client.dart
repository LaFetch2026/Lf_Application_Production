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
      final trimmed = accessToken.trim();
      // Quick sanity check: JWTs usually have three dot-separated parts.
      final parts = trimmed.split('.');
      if (parts.length != 3) {
        print(
            '⚠️ Stored auth token does not look like a JWT (parts=${parts.length}).');
      }
      // If this is the test-review token we inject during local testing, do not
      // attach it to requests — it's not a real JWT and will cause server 401s.
      if (trimmed.startsWith('test_review_token_')) {
        print('ℹ️ Test review token detected; skipping Authorization header.');
      } else {
        // Use the trimmed token when sending header
        request.headers['Authorization'] = 'Bearer $trimmed';
      }
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
      // Read the raw response bytes and recreate a StreamedResponse so the
      // caller can still consume the response body normally. This avoids
      // "Bad state: Stream has already been listened to" errors when the
      // higher-level helpers (e.g. Response.fromStream) also read the stream.
      try {
        final List<int> bytes = <int>[];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
        }
        final bodyString = utf8.decode(bytes);
        print("🔍 401 body: $bodyString");

        // 🟢 FIX: Ignore 401 unless REAL logout is required
        if (!ignore401) {
          // Here you may force logout or refresh token
        }

        // Recreate a fresh StreamedResponse with the same bytes so callers
        // can read the body as usual.
        final newStream = Stream.fromIterable([bytes]);
        return http.StreamedResponse(
          newStream,
          response.statusCode,
          headers: response.headers,
          request: response.request,
          reasonPhrase: response.reasonPhrase,
          contentLength: bytes.length,
        );
      } catch (e) {
        print("⚠️ Failed to read 401 body: $e");
        // Fallthrough: return an empty stream response to avoid breaking callers
        return http.StreamedResponse(
          Stream.fromIterable([utf8.encode('')]),
          response.statusCode,
          headers: response.headers,
          request: response.request,
          reasonPhrase: response.reasonPhrase,
          contentLength: 0,
        );
      }
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
