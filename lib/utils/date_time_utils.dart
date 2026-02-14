/// Utility functions for date and time formatting
/// 
/// This file contains helper methods for formatting dates and times
/// in user-friendly ways throughout the app.

class DateTimeUtils {
  /// Format date to "January 15, 2026" format
  static String formatDate(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  /// Format date to "Jan 15" format
  static String formatShortDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}';
  }

  /// Format time to "2:30 PM" format
  static String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format date and time to "Jan 15, 2:30 PM" format
  static String formatDateTime(DateTime date) {
    return '${formatShortDate(date)}, ${formatTime(date)}';
  }

  /// Get relative time string (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  /// Get day of week name
  static String getDayName(DateTime date) {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday];
  }

  /// Format event date string
  static String formatEventDate(DateTime start, DateTime end) {
    if (isToday(start)) {
      return 'Today, ${formatTime(start)} - ${formatTime(end)}';
    } else if (isTomorrow(start)) {
      return 'Tomorrow, ${formatTime(start)} - ${formatTime(end)}';
    } else {
      return '${formatDateTime(start)} - ${formatTime(end)}';
    }
  }
}
