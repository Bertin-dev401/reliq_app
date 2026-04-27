import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  bool _isLoading = false;

  static const List<String> _denominations = [
    'Catholic', 'Protestant', 'Anglican', 'Mormon',
    'Muslim', 'Orthodox', 'Adventist', 'Other',
  ];

  String? _selectedDenomination;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameCtrl     = TextEditingController(text: user?.name ?? '');
    _bioCtrl      = TextEditingController(text: user?.bio ?? '');
    _locationCtrl = TextEditingController(text: user?.location ?? '');
    _selectedDenomination = user?.denomination;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final current = auth.currentUser!;

    // Build updated user with new values
    final updated = User(
      id: current.id,
      email: current.email,
      name: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      denomination: _selectedDenomination ?? current.denomination,
      joinedDate: current.joinedDate,
      streakCount: current.streakCount,
      isPremium: current.isPremium,
    );

    await auth.updateProfile(updated);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          backgroundColor: ReliqTheme.ink(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text2 = ReliqTheme.text2(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save', style: TextStyle(color: ReliqTheme.ink(context), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: ReliqTheme.surface2(context),
                      child: Text(
                        _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'R',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ReliqTheme.ink(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: ReliqTheme.surface(context), width: 2),
                        ),
                        child: Icon(Icons.camera_alt_outlined, size: 14, color: ReliqTheme.inkInverse(context)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _Label('Full name', context),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Your full name',
                  prefixIcon: Icon(Icons.person_outline, size: 20, color: text2),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Name cannot be empty' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              _Label('Bio', context),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell others about yourself',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.edit_outlined, size: 20, color: text2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _Label('Location', context),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: 'City, Country',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: text2),
                ),
              ),
              const SizedBox(height: 20),

              _Label('Denomination', context),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDenomination,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.church_outlined, size: 20, color: text2),
                  hintText: 'Select denomination',
                ),
                items: _denominations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDenomination = v),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _Label(String text, BuildContext context) {
  return Text(
    text,
    style: Theme.of(context).textTheme.titleSmall,
  );
}
