import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// ApiService handles calls to your custom backend (communities, events,
// marketplace, orders). Auth is fully handled by Firebase Auth now —
// no token management needed here. Firebase Auth automatically provides
// a fresh ID token which we attach to every request via _AuthInterceptor.
class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api/v1';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_AuthInterceptor());
  }

  // ── Communities ────────────────────────────────────────────
  Future<List<dynamic>> getCommunities({String? denomination, int page = 1}) async {
    try {
      final res = await _dio.get('/communities', queryParameters: {
        if (denomination != null) 'denomination': denomination,
        'page': page,
        'limit': 20,
      });
      return res.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getCommunityPosts(String communityId, {int page = 1}) async {
    try {
      final res = await _dio.get('/communities/$communityId/posts',
          queryParameters: {'page': page, 'limit': 20});
      return res.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createPost(
      String communityId, Map<String, dynamic> postData) async {
    try {
      final res = await _dio.post('/communities/$communityId/posts', data: postData);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Events ─────────────────────────────────────────────────
  Future<List<dynamic>> getEvents({String? denomination, bool? onlineOnly, int page = 1}) async {
    try {
      final res = await _dio.get('/events', queryParameters: {
        if (denomination != null) 'denomination': denomination,
        if (onlineOnly != null) 'online_only': onlineOnly,
        'page': page,
        'limit': 20,
      });
      return res.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rsvpEvent(String eventId) async {
    try {
      await _dio.post('/events/$eventId/rsvp');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Marketplace ────────────────────────────────────────────
  Future<List<dynamic>> getProducts({String? category, int page = 1}) async {
    try {
      final res = await _dio.get('/products', queryParameters: {
        if (category != null) 'category': category,
        'page': page,
        'limit': 20,
      });
      return res.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final res = await _dio.post('/orders', data: orderData);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handler ──────────────────────────────────────────
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final msg = e.response?.data?['message'] ?? 'Unknown error';
        if (code == 401) return 'Unauthorized.';
        if (code == 403) return 'Access forbidden.';
        if (code == 404) return 'Not found.';
        if (code == 500) return 'Server error. Try again later.';
        return msg;
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error. Check your connection.';
    }
  }
}

// ── Interceptors ───────────────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('→ ${options.method} ${options.path}', name: 'API');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log('← ${response.statusCode} ${response.requestOptions.path}', name: 'API');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log('✖ ${err.requestOptions.path} — ${err.message}', name: 'API');
    super.onError(err, handler);
  }
}

// Gets a fresh Firebase ID token and attaches it to every request.
// Firebase ID tokens expire after 1 hour — getIdToken() automatically
// refreshes it so you never have to manage token expiry manually.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    super.onRequest(options, handler);
  }
}
