import 'package:flutter/material.dart';
import '../models/product.dart';

/// Provider for managing marketplace-related state and operations
/// 
/// Responsibilities:
/// - Load and filter products
/// - Manage shopping cart
/// - Handle product search
/// - Manage seller information
/// - Process orders
class MarketplaceProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // Filter options
  String _selectedCategory = 'All';
  String _sortBy = 'newest'; // newest, price_low, price_high, popular

  // Getters
  List<Product> get products => _filteredProducts();
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  /// Calculate total cart amount
  double get cartTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  /// Get cart items count
  int get cartItemsCount => _cartItems.length;

  /// Load all available products
  /// TODO: Implement pagination for better performance
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      // Example: final response = await ApiService.getProducts();
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API response
      _products = [
        Product(
          id: '1',
          name: 'Silver Cross Necklace',
          description: 'Beautiful handcrafted silver cross necklace',
          price: 25000,
          images: [],
          category: 'Jewelry',
          sellerId: 'seller1',
          sellerName: 'Faith Crafts',
          stockQuantity: 15,
          rating: 4.8,
          reviewsCount: 45,
          isFeatured: true,
        ),
        Product(
          id: '2',
          name: 'Wooden Rosary Beads',
          description: 'Traditional rosary beads made from olive wood',
          price: 15000,
          images: [],
          category: 'Jewelry',
          sellerId: 'seller1',
          sellerName: 'Faith Crafts',
          stockQuantity: 30,
          rating: 4.9,
          reviewsCount: 67,
        ),
        Product(
          id: '3',
          name: 'Inspirational Wall Art',
          description: 'Canvas print with inspirational Bible verse',
          price: 35000,
          images: [],
          category: 'Home Decor',
          sellerId: 'seller2',
          sellerName: 'Sacred Arts',
          stockQuantity: 8,
          rating: 4.7,
          reviewsCount: 23,
          isFeatured: true,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load featured products for homepage
  Future<void> loadFeaturedProducts() async {
    try {
      // TODO: Implement actual API call
      // Example: final response = await ApiService.getFeaturedProducts();
      
      _featuredProducts = _products.where((p) => p.isFeatured).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      // TODO: Implement actual API call with backend search
      // Example: return await ApiService.searchProducts(query);
      
      if (query.isEmpty) return _products;
      
      final lowercaseQuery = query.toLowerCase();
      return _products.where((product) {
        return product.name.toLowerCase().contains(lowercaseQuery) ||
               product.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get products by specific seller
  Future<List<Product>> getSellerProducts(String sellerId) async {
    try {
      // TODO: Implement actual API call
      // Example: return await ApiService.getSellerProducts(sellerId);
      
      return _products.where((p) => p.sellerId == sellerId).toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Add product to cart
  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == product.id);
    
    if (existingIndex == -1) {
      _cartItems.add(product);
    } else {
      // Product already in cart - could increase quantity here
      // For now, just notify user
    }
    
    notifyListeners();
  }

  /// Remove product from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  /// Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.id == productId);
  }

  /// Process checkout
  /// TODO: Integrate with payment gateway (Mobile Money, PayPal)
  Future<bool> checkout() async {
    try {
      // TODO: Implement actual payment processing
      // Example: 
      // final orderId = await ApiService.createOrder(_cartItems);
      // final paymentResult = await PaymentService.processPayment(orderId, cartTotal);
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear cart after successful payment
      _cartItems.clear();
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Filter methods
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    notifyListeners();
  }

  /// Apply filters and sorting to products list
  List<Product> _filteredProducts() {
    var filtered = List<Product>.from(_products);

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Sort products
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
      default:
        // Assuming products are already sorted by newest
        break;
    }

    return filtered;
  }

  /// Get available categories
  List<String> getCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = 'All';
    _sortBy = 'newest';
    notifyListeners();
  }
}