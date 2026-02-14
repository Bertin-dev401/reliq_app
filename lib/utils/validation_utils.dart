/// Input validation utility functions
/// 
/// This file contains helper methods for validating user input
/// across forms in the application.

import '../constants/app_constants.dart';

class ValidationUtils {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number (Rwanda format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Rwanda phone format: +250 7XX XXX XXX or 07XX XXX XXX
    final rwandaPhoneRegex = RegExp(r'^(\+?250)?[7][0-9]{8}$');
    
    if (!rwandaPhoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid Rwanda phone number';
    }
    
    return null;
  }

  /// Validate name (no special characters, minimum length)
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    
    // Allow letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate price (positive number)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    return null;
  }

  /// Validate quantity (positive integer)
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }
    
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }

  /// Validate age (for birth date)
  static String? validateAge(DateTime? birthDate, {int minAge = 13}) {
    if (birthDate == null) {
      return 'Birth date is required';
    }
    
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    
    if (age > 150) {
      return 'Please enter a valid birth date';
    }
    
    return null;
  }
}
