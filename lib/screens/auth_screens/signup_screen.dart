import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/reliq_themes.dart';
import '../../main.dart';
import '../../services/theme_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _selectedEthnicity;
  String? _selectedDenomination;
  String _selectedTheme = 'gold';

  static const List<String> _ethnicities = [
    'African', 'East African', 'West African', 'Central African',
    'North African', 'Asian', 'East Asian', 'South Asian',
    'Middle Eastern', 'European', 'Latin American',
    'North American', 'Caribbean', 'Pacific Islander', 'Other',
  ];

  static const List<String> _denominations = [
    'Catholic', 'Protestant', 'Anglican', 'Mormon',
    'Muslim', 'Orthodox', 'Adventist', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEthnicity == null) {
      _showError('Please select your ethnic group');
      return;
    }
    if (_selectedDenomination == null) {
      _showError('Please select your faith denomination');
      return;
    }
    setState(() => _isLoading = true);

    // Save theme and mark as chosen — theme applies AFTER signup
    await ThemeService.saveTheme(_selectedTheme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_chosen', true);
    if (mounted) ReliqApp.of(context)?.changeTheme(_selectedTheme);

    // Call the real signup API via AuthProvider
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      ethnicity: _selectedEthnicity!,
      denomination: _selectedDenomination!,
    );

    setState(() => _isLoading = false);
    if (success && mounted) {
      Get.offNamed('/main');
    } else if (mounted && auth.error != null) {
      _showError(auth.error!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C63FF);
    const darkText = Color(0xFF2D3748);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Name
              _buildField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Email
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    !v!.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),

              // Password
              _buildField(
                controller: _passCtrl,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                validator: (v) =>
                    v!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildField(
                controller: _confirmCtrl,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) =>
                    v != _passCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),

              // Ethnic Group
              _buildSectionLabel('Your Ethnic Group', primary),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedEthnicity,
                decoration: _dropdownDecoration('Select ethnic group', Icons.people_outline),
                items: _ethnicities
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedEthnicity = v),
              ),
              const SizedBox(height: 24),

              // Denomination
              _buildSectionLabel('Your Faith', primary),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedDenomination,
                decoration: _dropdownDecoration('Select denomination', Icons.church_outlined),
                items: _denominations
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDenomination = v),
              ),
              const SizedBox(height: 24),

              // Theme Picker
              _buildSectionLabel('Choose Your Theme', primary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ReliqThemes.themeNames.entries.map((entry) {
                  final isSelected = _selectedTheme == entry.key;
                  final color = ReliqThemes.themePrimaryColors[entry.key]!;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isSelected ? 0.2 : 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(radius: 8, backgroundColor: color),
                          const SizedBox(width: 6),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? color : null,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Get.offNamed('/signin'),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}
