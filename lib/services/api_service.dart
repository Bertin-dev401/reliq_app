import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Main API service for communicating with backend
/// 
/// This service handles all HTTP requests to the backend API.
/// Replace the baseUrl with your actual backend URL.
/// 
/// Usage:
/// ```dart
/// final apiService = ApiService();
/// final response = await apiService.get('/communities');
/// ```
class ApiService {
  /// Backend API base URL - CHANGE THIS TO YOUR ACTUAL API
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  
  /// Dio instance for making HTTP requests
  late final Dio _dio;

  /// Initialize API service with configuration
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

    // Add interceptors for logging and auth
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_AuthInterceptor());
  }

  // ==================== Authentication APIs ====================

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request password reset
  Future<void> resetPassword(String email) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== User APIs ====================

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Community APIs ====================

  /// Get all communities
  Future<List<dynamic>> getCommunities({
    String? denomination,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/communities',
        queryParameters: {
          if (denomination != null) 'denomination': denomination,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get community posts
  Future<List<dynamic>> getCommunityPosts(
    String communityId, {
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/communities/$communityId/posts',
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new post
  Future<Map<String, dynamic>> createPost(
    String communityId,
    Map<String, dynamic> postData,
  ) async {
    try {
      final response = await _dio.post(
        '/communities/$communityId/posts',
        data: postData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Events APIs ====================

  /// Get all events
  Future<List<dynamic>> getEvents({
    String? denomination,
    bool? onlineOnly,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/events',
        queryParameters: {
          if (denomination != null) 'denomination': denomination,
          if (onlineOnly != null) 'online_only': onlineOnly,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// RSVP to an event
  Future<void> rsvpEvent(String eventId) async {
    try {
      await _dio.post('/events/$eventId/rsvp');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Bible APIs ====================

  /// Get daily verse
  Future<Map<String, dynamic>> getDailyVerse() async {
    try {
      final response = await _dio.get('/bible/daily-verse');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search verses
  Future<List<dynamic>> searchVerses(String query) async {
    try {
      final response = await _dio.get(
        '/bible/search',
        queryParameters: {'q': query},
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Marketplace APIs ====================

  /// Get all products
  Future<List<dynamic>> getProducts({
    String? category,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create order
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Generic Methods ====================

  /// Generic GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Error Handling ====================

  /// Handle Dio errors and convert to readable messages
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error occurred';
        
        if (statusCode == 400) return 'Bad request: $message';
        if (statusCode == 401) return 'Unauthorized. Please login again.';
        if (statusCode == 403) return 'Access forbidden.';
        if (statusCode == 404) return 'Resource not found.';
        if (statusCode == 500) return 'Server error. Please try again later.';
        
        return message;

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.unknown:
      default:
        return 'Network error. Please check your connection.';
    }
  }
}

// ==================== Interceptors ====================

/// Logging interceptor for debugging API requests
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '→ ${options.method} ${options.path}',
      name: 'API Request',
    );
    developer.log(
      'Headers: ${options.headers}',
      name: 'API Request',
    );
    if (options.data != null) {
      developer.log(
        'Data: ${options.data}',
        name: 'API Request',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.path}',
      name: 'API Response',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✖ ${err.requestOptions.method} ${err.requestOptions.path}',
      name: 'API Error',
      error: err.message,
    );
    super.onError(err, handler);
  }
}

/// Authentication interceptor to add auth tokens to requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Get auth token from secure storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('auth_token');
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    
    super.onRequest(options, handler);
  }
}
