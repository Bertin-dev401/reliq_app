import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _startDate;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _startDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final events = Provider.of<EventProvider>(context, listen: false);
    final user = auth.currentUser;
    final start = _startDate;

    if (user == null ||
        start == null ||
        _titleCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() => _saving = true);
    final event = FaithEvent(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      startDate: start,
      endDate: start.add(const Duration(hours: 2)),
      denomination: user.denomination ?? 'Other',
      organizerId: user.id,
      organizerName: user.name,
    );

    final success = await events.createEvent(event: event, organizer: user);
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(events.error ?? 'Could not create event.')),
      );
    }
  }

  String _dateLabel() {
    final start = _startDate;
    if (start == null) return 'Select Date & Time';
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '${start.day}/${start.month}/${start.year} at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_saving &&
        _startDate != null &&
        _titleCtrl.text.trim().isNotEmpty &&
        _descriptionCtrl.text.trim().isNotEmpty &&
        _locationCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Event Title'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_dateLabel()),
              onTap: _pickDateTime,
            ),
          ],
        ),
      ),
    );
  }
}
