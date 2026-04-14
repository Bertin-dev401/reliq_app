import 'package:geolocator/geolocator.dart';
import 'dart:math';

/// Service for location-based feature discovery
class LocationService {
  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        return result == LocationPermission.whileInUse ||
            result == LocationPermission.always;
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Open app settings
        await Geolocator.openLocationSettings();
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current user location
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Filter events by distance
  static Future<List<Map<String, dynamic>>> filterEventsByDistance(
    List<Map<String, dynamic>> events,
    double maxDistanceKm,
  ) async {
    try {
      final userLocation = await getCurrentLocation();
      if (userLocation == null) return events;

      final filteredEvents = events.where((event) {
        final eventLat = event['latitude'] as double?;
        final eventLon = event['longitude'] as double?;
        
        if (eventLat == null || eventLon == null) return false;
        
        final distance = calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          eventLat,
          eventLon,
        );
        
        return distance <= maxDistanceKm;
      }).toList();

      return filteredEvents;
    } catch (e) {
      print('Error filtering events by distance: $e');
      return events;
    }
  }

  /// Get events sorted by distance from user
  static Future<List<Map<String, dynamic>>> sortEventsByDistance(
    List<Map<String, dynamic>> events,
  ) async {
    try {
      final userLocation = await getCurrentLocation();
      if (userLocation == null) return events;

      final eventsWithDistance = events.map((event) {
        final eventLat = event['latitude'] as double?;
        final eventLon = event['longitude'] as double?;
        
        double distance = double.maxFinite;
        if (eventLat != null && eventLon != null) {
          distance = calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            eventLat,
            eventLon,
          );
        }
        
        return {
          ...event,
          'distance': distance,
        };
      }).toList();

      eventsWithDistance.sort((a, b) => 
          (a['distance'] as double).compareTo(b['distance'] as double));

      return eventsWithDistance;
    } catch (e) {
      print('Error sorting events by distance: $e');
      return events;
    }
  }

  /// Check if user is within radius of a location
  static Future<bool> isUserWithinRadius(
    double targetLat,
    double targetLon,
    double radiusKm,
  ) async {
    try {
      final userLocation = await getCurrentLocation();
      if (userLocation == null) return false;

      final distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        targetLat,
        targetLon,
      );
      
      return distance <= radiusKm;
    } catch (e) {
      print('Error checking location radius: $e');
      return false;
    }
  }
}
