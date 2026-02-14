/// Marketplace and product-related data models
/// 
/// This file contains all models related to the marketplace,
/// including products, sellers, orders, and reviews

/// Model representing a product in the marketplace
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> images;
  final String category;
  final String sellerId;
  final String sellerName;
  final String? sellerImage;
  final int stockQuantity;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'RWF',
    this.images = const [],
    required this.category,
    required this.sellerId,
    required this.sellerName,
    this.sellerImage,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'RWF',
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      category: json['category'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? '',
      sellerImage: json['seller_image'],
      stockQuantity: json['stock_quantity'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'images': images,
      'category': category,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_image': sellerImage,
      'stock_quantity': stockQuantity,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get formatted price with currency
  String get formattedPrice => '$currency ${price.toStringAsFixed(0)}';

  /// Check if product is in stock
  bool get inStock => stockQuantity > 0;

  /// Get stock status text
  String get stockStatus {
    if (stockQuantity == 0) return 'Out of Stock';
    if (stockQuantity < 5) return 'Low Stock';
    return 'In Stock';
  }
}

/// Model representing a product review
class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Create ProductReview from JSON
  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userImage: json['user_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convert ProductReview to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model representing an order
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String currency;
  final String status; // pending, processing, shipped, delivered, cancelled
  final String shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.currency = 'RWF',
    this.status = 'pending',
    required this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    this.deliveredAt,
  });

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'RWF',
      status: json['status'] ?? 'pending',
      shippingAddress: json['shipping_address'] ?? '',
      trackingNumber: json['tracking_number'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  /// Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  /// Get formatted total with currency
  String get formattedTotal => '$currency ${totalAmount.toStringAsFixed(0)}';

  /// Check if order can be cancelled
  bool get canCancel => status == 'pending' || status == 'processing';
}

/// Model representing an item in an order
class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  /// Create OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  /// Convert OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Calculate subtotal for this item
  double get subtotal => price * quantity;
}
