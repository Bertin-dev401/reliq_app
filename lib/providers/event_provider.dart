import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart' as reliq;
import '../repositories/event_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repo;

  EventProvider({EventRepository? repository})
      : _repo = repository ?? EventRepository();

  List<FaithEvent> _events = [];
  List<FaithEvent> _myEvents = [];
  List<String> _rsvpedEventIds = [];
  bool _isLoading = false;
  String? _error;

  String _selectedDenomination = 'All';
  bool _showOnlineOnly = false;
  bool _showUpcomingOnly = true;

  StreamSubscription<List<FaithEvent>>? _eventsSub;
  StreamSubscription<List<String>>? _rsvpsSub;

  List<FaithEvent> get events => _filteredEvents();
  List<FaithEvent> get myEvents => _myEvents;
  List<String> get rsvpedEventIds => _rsvpedEventIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDenomination => _selectedDenomination;
  bool get showOnlineOnly => _showOnlineOnly;
  bool get showUpcomingOnly => _showUpcomingOnly;

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _eventsSub?.cancel();
    _eventsSub = _repo.watchEvents().listen(
      (events) {
        _events = events;
        _myEvents = events
            .where((event) => _rsvpedEventIds.contains(event.id))
            .toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Could not load events.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadRsvps(String userId) async {
    await _rsvpsSub?.cancel();
    _rsvpsSub = _repo.watchMyRsvps(userId).listen(
      (ids) {
        _rsvpedEventIds = ids;
        _myEvents = _events.where((event) => ids.contains(event.id)).toList();
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  Future<bool> createEvent({
    required FaithEvent event,
    required reliq.User organizer,
  }) async {
    try {
      await _repo.createEvent(event: event, organizer: organizer);
      return true;
    } catch (_) {
      _error = 'Could not create event. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> rsvpEvent(String eventId, String userId) async {
    if (_rsvpedEventIds.contains(eventId)) return;
    try {
      await _repo.rsvpEvent(eventId, userId);
      _rsvpedEventIds.add(eventId);
      notifyListeners();
    } catch (_) {
      _error = 'Could not RSVP to event.';
      notifyListeners();
    }
  }

  Future<void> cancelRsvp(String eventId, String userId) async {
    try {
      await _repo.cancelRsvp(eventId, userId);
      _rsvpedEventIds.remove(eventId);
      notifyListeners();
    } catch (_) {
      _error = 'Could not cancel RSVP.';
      notifyListeners();
    }
  }

  bool hasRsvped(String eventId) => _rsvpedEventIds.contains(eventId);

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

  List<FaithEvent> _filteredEvents() {
    var filtered = List<FaithEvent>.from(_events);

    if (_selectedDenomination != 'All') {
      filtered = filtered
          .where((event) => event.denomination == _selectedDenomination)
          .toList();
    }
    if (_showOnlineOnly) {
      filtered = filtered.where((event) => event.isOnline).toList();
    }
    if (_showUpcomingOnly) {
      final now = DateTime.now();
      filtered = filtered.where((event) => event.startDate.isAfter(now)).toList();
    }

    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    return filtered;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFilters() {
    _selectedDenomination = 'All';
    _showOnlineOnly = false;
    _showUpcomingOnly = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _rsvpsSub?.cancel();
    super.dispose();
  }
}
