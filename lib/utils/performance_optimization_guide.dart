/// Performance Optimization Guide for Reliq App
/// 
/// This file contains best practices and tips for optimizing
/// the Reliq app's performance across Android, iOS, and web platforms.

/// STORAGE OPTIMIZATION
/// - Use Hive for local caching (already implemented)
/// - Implement pagination for fetching large lists
/// - Clear old cache periodically (>7 days)
/// - Store images as thumbnails, load full size on demand
/// 
/// NETWORK OPTIMIZATION
/// - Implement request caching
/// - Use appropriate timeouts (already: 10 seconds)
/// - Batch API requests where possible
/// - Use WebSocket for real-time community chat
/// - Compress images before upload
/// 
/// BUILD OPTIMIZATION
/// - Remove unused dependencies
/// - Enable code obfuscation for release builds
/// - Use --split-per-abi for smaller APKs
/// - Minimize asset sizes (compress images)
/// 
/// UI OPTIMIZATION
/// - Use const constructors wherever possible
/// - Implement RepaintBoundary for expensive widgets
/// - Use ListView.builder instead of ListView
/// - Lazy-load images with cached_network_image
/// - Profile with DevTools Frame Rate tracker
/// 
/// MEMORY OPTIMIZATION
/// - Dispose controllers and subscriptions properly
/// - Avoid creating objects in build methods
/// - Use weak references for callbacks
/// - Monitor memory with DevTools Memory view

// Example: Optimize image loading
class OptimizedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const OptimizedImageWidget({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Using cached_network_image (already in pubspec)
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300], // Placeholder
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }
}

// Example: Efficient list building
class OptimizedListView extends StatelessWidget {
  final List<String> items;

  const OptimizedListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder( // Not ListView
      itemCount: items.length,
      itemBuilder: (context, index) {
        return const ListTile(
          // Using const for better performance
          title: Text('Item'),
        );
      },
    );
  }
}

// KEY FLUTTER OPTIMIZATION COMMANDS
// 
// 1. Profile app performance:
//    flutter run --profile
// 
// 2. Build optimized release APK:
//    flutter build apk --split-per-abi --release
// 
// 3. Build optimized iOS app:
//    flutter build ios --release
// 
// 4. Analyze package size:
//    flutter build appbundle --release --analyze-size
// 
// 5. Profile memory usage:
//    flutter run -v --profile 2>&1 | grep "Memory"
// 
// 6. Check unused code:
//    dart analyze lib/
