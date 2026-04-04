import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  static const String _tokenKey = 'auth_token';

  // Set this to true once your real backend is ready.
  // While false, all auth calls skip the network and use local storage.
  static const bool backendReady = false;

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

  // ── Token helpers ──────────────────────────────────────────
  // Saves the JWT token returned by the backend after login/signup.
  // Every subsequent request reads this token and attaches it as
  // "Authorization: Bearer <token>" via the _AuthInterceptor below.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Auth ───────────────────────────────────────────────────
  // POST /auth/signin  →  { token, user }
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final res = await _dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /auth/signup  →  { token, user }
  // Now includes ethnicity and denomination collected during signup.
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String ethnicity,
    required String denomination,
  }) async {
    try {
      final res = await _dio.post('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'ethnicity': ethnicity,
        'denomination': denomination,
      });
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /auth/reset-password  →  sends reset email
  Future<void> resetPassword(String email) async {
    try {
      await _dio.post('/auth/reset-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST /auth/verify  →  { success }
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final res = await _dio.post('/auth/verify', data: {
        'email': email,
        'otp': otp,
      });
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Users ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final res = await _dio.get('/users/$userId');
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/users/$userId', data: data);
      return res.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Communities ────────────────────────────────────────────
  Future<List<dynamic>> getCommunities({String? denomination, int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.get('/communities', queryParameters: {
        if (denomination != null) 'denomination': denomination,
        'page': page,
        'limit': limit,
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
        if (code == 401) return 'Incorrect email or password.';
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

// Reads the saved JWT token from SharedPreferences and attaches it to
// every outgoing request as "Authorization: Bearer <token>".
// Requests to /auth/* are skipped since they don't need a token yet.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isAuthRoute = options.path.startsWith('/auth/');
    if (!isAuthRoute) {
      final token = await ApiService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
