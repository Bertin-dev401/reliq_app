import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

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
    final ink = ReliqTheme.ink(context);
    final text2 = ReliqTheme.text2(context);
    final surface2 = ReliqTheme.surface2(context);
    final border = ReliqTheme.border(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // Name
              _buildField(context, controller: _nameCtrl, label: 'Full Name',        icon: Icons.person_outline,  validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null),
              const SizedBox(height: 14),
              // Email
              _buildField(context, controller: _emailCtrl, label: 'Email',           icon: Icons.email_outlined,  keyboardType: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null),
              const SizedBox(height: 14),
              // Password
              _buildField(context, controller: _passCtrl,  label: 'Password',        icon: Icons.lock_outline,    obscure: _obscurePass,
                suffixIcon: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscurePass = !_obscurePass)),
                validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 14),
              // Confirm password
              _buildField(context, controller: _confirmCtrl, label: 'Confirm Password', icon: Icons.lock_outline, obscure: _obscureConfirm,
                suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),

              // Ethnic group
              _SectionLabel('Your ethnic group', context),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedEthnicity,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.people_outline, size: 20, color: text2),
                  hintText: 'Select ethnic group',
                ),
                items: _ethnicities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedEthnicity = v),
              ),
              const SizedBox(height: 20),

              // Denomination
              _SectionLabel('Your faith', context),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDenomination,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.church_outlined, size: 20, color: text2),
                  hintText: 'Select denomination',
                ),
                items: _denominations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedDenomination = v),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodySmall),
                  GestureDetector(
                    onTap: () => Get.offNamed('/signin'),
                    child: Text('Sign In', style: TextStyle(color: ink, fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _buildField(
    BuildContext context, {
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
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}

Widget _SectionLabel(String label, BuildContext context) {
  return Text(
    label,
    style: Theme.of(context).textTheme.titleSmall,
  );
}
