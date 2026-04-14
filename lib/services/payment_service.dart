/// MTN Mobile Money Payment Integration Service
/// Integrates with MTN Mobile Money API for payment processing in Africa
/// 
/// Supported regions:
/// - Uganda (MTN UG)
/// - Rwanda (MTN RW)
/// - Cameroon (MTN CM)
/// - Zambia (MTN ZM)
/// - Ghana (MTN GH)
/// - Tanzania (Vodafone TZ)

class MtnMobileMoneyService {
  // TODO: Get these from environment variables
  static const String apiUrl = 'https://api.mtnmobileonsay.com';
  static const String apiKey = 'your_mtn_api_key_here';
  static const String primaryKey = 'your_mtn_primary_key_here';
  static const String serviceLanguage = 'en';
  static const String contextLanguage = 'en';
  
  /// Initialize MTN Mobile Money service
  static Future<bool> initialize() async {
    try {
      print('MTN Mobile Money service initialized');
      // TODO: Verify API credentials
      return true;
    } catch (e) {
      print('Error initializing MTN Mobile Money: $e');
      return false;
    }
  }

  /// Initiate payment request via MTN Mobile Money
  /// 
  /// Parameters:
  /// - amount: Transaction amount (e.g., 25000 for RWF 25,000)
  /// - phoneNumber: Customer's MTN phone number (with country code)
  /// - productName: Name of product/service being purchased
  /// - productDescription: Detailed description
  /// - externalId: Your unique transaction reference
  /// 
  /// Returns: PaymentRequest with reference ID for polling
  static Future<MtnPaymentResult> requestPayment({
    required int amount,
    required String phoneNumber,
    required String productName,
    required String productDescription,
    required String externalId,
    required String currency, // RWF, UGX, XAF, ZMW, GHS, TZS
  }) async {
    try {
      // Normalize phone number (remove +, add if missing)
      String normalizedPhone = phoneNumber.replaceAll('+', '');
      if (!normalizedPhone.startsWith('256') && 
          !normalizedPhone.startsWith('250') &&
          !normalizedPhone.startsWith('237') &&
          !normalizedPhone.startsWith('260') &&
          !normalizedPhone.startsWith('233') &&
          !normalizedPhone.startsWith('255')) {
        // Add default country code if missing (Rwanda)
        normalizedPhone = '250' + (normalizedPhone.startsWith('0') 
            ? normalizedPhone.substring(1) 
            : normalizedPhone);
      }

      print('Initiating MTN payment: $amount $currency from $normalizedPhone');
      
      // TODO: Make HTTP POST to MTN API
      // POST $apiUrl/collection/v1_0/requesttopay
      // Headers:
      //   - X-Reference-Id: UUID (unique per request)
      //   - X-Target-Environment: mtncameroon (or mtnuserland, etc)
      //   - Authorization: Bearer <token>
      //   - Ocp-Apim-Subscription-Key: $primaryKey
      // Body:
      // {
      //   "amount": $amount,
      //   "currency": $currency,
      //   "externalId": $externalId,
      //   "payer": {
      //     "partyIdType": "MSISDN",
      //     "partyId": $normalizedPhone
      //   },
      //   "payerMessage": $productName,
      //   "payeeNote": $productDescription
      // }

      return MtnPaymentResult(
        success: true,
        referenceId: 'ref_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Payment request sent to $phoneNumber',
        amount: amount,
        currency: currency,
        status: 'PENDING',
      );
    } catch (e) {
      return MtnPaymentResult(
        success: false,
        message: 'Payment request failed: $e',
        amount: amount,
        currency: currency,
      );
    }
  }

  /// Check payment status using reference ID
  /// Poll this endpoint to check if user completed payment
  /// 
  /// Typical flow:
  /// 1. Call requestPayment() → get referenceId
  /// 2. Poll checkPaymentStatus() every 2 seconds
  /// 3. When status = SUCCESSFUL, payment is complete
  static Future<MtnPaymentResult> checkPaymentStatus({
    required String referenceId,
  }) async {
    try {
      print('Checking MTN payment status: $referenceId');
      
      // TODO: Make HTTP GET to MTN API
      // GET $apiUrl/collection/v1_0/requesttopay/$referenceId
      // Headers:
      //   - X-Target-Environment: mtncameroon (or appropriate)
      //   - Authorization: Bearer <token>
      //   - Ocp-Apim-Subscription-Key: $primaryKey
      //
      // Response:
      // {
      //   "financialTransactionId": "...",
      //   "status": "SUCCESSFUL" | "PENDING" | "FAILED",
      //   "amount": 25000,
      //   "currency": "RWF"
      // }

      return MtnPaymentResult(
        success: true,
        referenceId: referenceId,
        message: 'Payment status checked',
        status: 'SUCCESSFUL', // Will be PENDING or FAILED in real impl
      );
    } catch (e) {
      print('Error checking payment status: $e');
      return MtnPaymentResult(
        success: false,
        referenceId: referenceId,
        message: 'Failed to check status: $e',
      );
    }
  }

  /// Get account balance
  static Future<int?> getAccountBalance() async {
    try {
      // TODO: Make HTTP GET to MTN API
      // GET $apiUrl/collection/v1_0/account/balance
      // Headers: (same as above)
      //
      // Response:
      // {
      //   "availableBalance": 50000
      // }
      
      print('Fetching MTN account balance');
      return 50000; // Placeholder
    } catch (e) {
      print('Error fetching balance: $e');
      return null;
    }
  }

  /// Process payment for marketplace products
  static Future<MtnPaymentResult> processMarketplacePayment({
    required String productId,
    required String productName,
    required int amount,
    required String currency,
    required String buyerPhone,
    required String sellerId,
  }) async {
    try {
      final externalId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      // Initiate payment request
      final result = await requestPayment(
        amount: amount,
        phoneNumber: buyerPhone,
        productName: productName,
        productDescription: 'Purchase from Reliq Marketplace',
        externalId: externalId,
        currency: currency,
      );

      if (!result.success) {
        return result;
      }

      // Poll for payment completion (max 30 seconds)
      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(seconds: 2));
        
        final statusResult = await checkPaymentStatus(
          referenceId: result.referenceId!,
        );

        if (statusResult.status == 'SUCCESSFUL') {
          return statusResult;
        } else if (statusResult.status == 'FAILED') {
          return MtnPaymentResult(
            success: false,
            message: 'Payment was declined',
            amount: amount,
            currency: currency,
          );
        }
        // PENDING - continue polling
      }

      return MtnPaymentResult(
        success: false,
        message: 'Payment timeout - please try again',
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      return MtnPaymentResult(
        success: false,
        message: 'Payment processing failed: $e',
        amount: amount,
        currency: currency,
      );
    }
  }
}

/// Payment result model for MTN Mobile Money
class MtnPaymentResult {
  final bool success;
  final String? referenceId;
  final String message;
  final int? amount;
  final String? currency;
  final String? status; // PENDING, SUCCESSFUL, FAILED
  final Map<String, dynamic>? metadata;

  MtnPaymentResult({
    required this.success,
    this.referenceId,
    required this.message,
    this.amount,
    this.currency,
    this.status,
    this.metadata,
  });

  /// Check if payment is still pending
  bool get isPending => status == 'PENDING';
  
  /// Check if payment succeeded
  bool get isSuccessful => status == 'SUCCESSFUL';
  
  /// Check if payment failed
  bool get isFailed => status == 'FAILED';
}

/// Old Payment Service (kept for reference, use MtnMobileMoneyService instead)
@Deprecated('Use MtnMobileMoneyService instead')
class PaymentService {
  // TODO: Add your Stripe/PayPal publishable key (NOT USED - use MTN instead)
  static const String stripePublishableKey = 'DEPRECATED - Use MTN Mobile Money';

  /// Initialize payment processing
  static Future<bool> initialize() async {
    print('Use MtnMobileMoneyService.initialize() instead');
    return await MtnMobileMoneyService.initialize();
  }

  /// Process payment for a single product/order (DEPRECATED)
  @Deprecated('Use MtnMobileMoneyService.processMarketplacePayment instead')
  static Future<PaymentResult> processPayment({
    required String productId,
    required String productName,
    required double amount,
    required String currency,
    required String userEmail,
  }) async {
    print('DEPRECATED: Use MtnMobileMoneyService instead');
    
    return PaymentResult(
      success: false,
      message: 'Stripe support has been removed. Use MTN Mobile Money instead.',
      amount: amount,
    );
  }

  /// Create payment intent (DEPRECATED)
  @Deprecated('Use MTN Mobile Money API instead')
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    print('DEPRECATED: Use MTN Mobile Money API instead');
    return null;
  }

  /// Refund a transaction (DEPRECATED)
  @Deprecated('Use MTN Mobile Money API instead')
  static Future<bool> refundTransaction(String transactionId) async {
    print('DEPRECATED: Use MTN Mobile Money API instead');
    return false;
  }

  /// Get user's payment methods (DEPRECATED)
  @Deprecated('Use MTN Mobile Money instead')
  static Future<List<PaymentMethod>> getUserPaymentMethods() async {
    print('DEPRECATED: MTN Mobile Money uses phone numbers');
    return [];
  }

  /// Save a payment method (DEPRECATED)
  @Deprecated('Use MTN Mobile Money instead')
  static Future<bool> savePaymentMethod({
    required String cardToken,
    required String cardholderName,
  }) async {
    print('DEPRECATED: Use MTN Mobile Money phone verification instead');
    return false;
  }
}

/// Old Payment result model (deprecated)
@Deprecated('Use MtnPaymentResult instead')
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final double amount;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    required this.amount,
    this.metadata,
  });
}

/// Old Payment method model (deprecated)
@Deprecated('Use phone number instead')
class PaymentMethod {
  final String id;
  final String type;
  final String? last4;
  final String? brand;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    this.last4,
    this.brand,
    this.isDefault = false,
    required this.createdAt,
  });
}

