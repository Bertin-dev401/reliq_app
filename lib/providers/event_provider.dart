import 'package:flutter/material.dart';
import '../models/event.dart';

/// Provider for managing event-related state and operations
/// 
/// Responsibilities:
/// - Load and filter events
/// - Manage event RSVPs
/// - Handle user's attended events
/// - Event creation and management
class EventProvider with ChangeNotifier {
  List<FaithEvent> _events = [];
  List<FaithEvent> _myEvents = [];
  List<String> _rsvpedEventIds = [];
  bool _isLoading = false;
  String? _error;

  // Filter options
  String _selectedDenomination = 'All';
  bool _showOnlineOnly = false;
  bool _showUpcomingOnly = true;

  // Getters
  List<FaithEvent> get events => _filteredEvents();
  List<FaithEvent> get myEvents => _myEvents;
  List<String> get rsvpedEventIds => _rsvpedEventIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDenomination => _selectedDenomination;
  bool get showOnlineOnly => _showOnlineOnly;
  bool get showUpcomingOnly => _showUpcomingOnly;

  /// Load all available events
  /// TODO: Implement pagination and filtering on backend
  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      // Example: final response = await ApiService.getEvents();
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API response
      _events = [
        FaithEvent(
          id: '1',
          title: 'Sunday Worship Service',
          description: 'Join us for our weekly worship service',
          location: 'Kigali Community Church',
          startDate: DateTime.now().add(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
          denomination: 'Catholic',
          organizerId: 'org1',
          organizerName: 'Father John',
          attendeesCount: 150,
        ),
        FaithEvent(
          id: '2',
          title: 'Youth Bible Study',
          description: 'Bible study session for young believers',
          location: 'Online',
          startDate: DateTime.now().add(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 5, hours: 1)),
          denomination: 'Protestant',
          organizerId: 'org2',
          organizerName: 'Pastor Mark',
          attendeesCount: 45,
          isOnline: true,
          meetingLink: 'https://zoom.us/meeting',
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

  /// Load user's created and attended events
  Future<void> loadMyEvents() async {
    try {
      // TODO: Implement actual API call
      // Example: final response = await ApiService.getMyEvents();
      
      _myEvents = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// RSVP to an event
  Future<void> rsvpEvent(String eventId) async {
    try {
      // TODO: Implement actual API call
      // Example: await ApiService.rsvpEvent(eventId);
      
      if (!_rsvpedEventIds.contains(eventId)) {
        _rsvpedEventIds.add(eventId);
        
        // Update attendee count locally
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          // Increment attendees count
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Cancel RSVP for an event
  Future<void> cancelRsvp(String eventId) async {
    try {
      // TODO: Implement actual API call
      // Example: await ApiService.cancelRsvp(eventId);
      
      _rsvpedEventIds.remove(eventId);
      
      // Update attendee count locally
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        // Decrement attendees count
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check if user has RSVP'd to an event
  bool hasRsvped(String eventId) {
    return _rsvpedEventIds.contains(eventId);
  }

  /// Create a new event
  Future<void> createEvent(FaithEvent event) async {
    try {
      // TODO: Implement actual API call
      // Example: final newEvent = await ApiService.createEvent(event);
      
      _events.insert(0, event);
      _myEvents.insert(0, event);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update an existing event
  Future<void> updateEvent(FaithEvent event) async {
    try {
      // TODO: Implement actual API call
      // Example: await ApiService.updateEvent(event);
      
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
      }
      
      final myIndex = _myEvents.indexWhere((e) => e.id == event.id);
      if (myIndex != -1) {
        _myEvents[myIndex] = event;
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      // TODO: Implement actual API call
      // Example: await ApiService.deleteEvent(eventId);
      
      _events.removeWhere((e) => e.id == eventId);
      _myEvents.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter methods
  void setDenominationFilter(String denomination) {
    _selectedDenomination = denomination;
    notifyListeners();
  }

  void toggleOnlineFilter() {
    _showOnlineOnly = !_showOnlineOnly;
    notifyListeners();
  }

  void toggleUpcomingFilter() {
    _showUpcomingOnly = !_showUpcomingOnly;
    notifyListeners();
  }

  /// Apply filters to events list
  List<FaithEvent> _filteredEvents() {
    var filtered = List<FaithEvent>.from(_events);

    // Filter by denomination
    if (_selectedDenomination != 'All') {
      filtered = filtered.where((e) => e.denomination == _selectedDenomination).toList();
    }

    // Filter by online events
    if (_showOnlineOnly) {
      filtered = filtered.where((e) => e.isOnline).toList();
    }

    // Filter by upcoming events
    if (_showUpcomingOnly) {
      final now = DateTime.now();
      filtered = filtered.where((e) => e.startDate.isAfter(now)).toList();
    }

    // Sort by start date
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));

    return filtered;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedDenomination = 'All';
    _showOnlineOnly = false;
    _showUpcomingOnly = true;
    notifyListeners();
  }
}
