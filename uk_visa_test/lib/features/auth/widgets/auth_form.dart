// lib/features/auth/widgets/auth_form.dart
import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final bool isLoading;
  final Function(String email, String password, [String? fullName]) onSubmit;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name (Register only)
          if (!widget.isLogin) ...[
            CustomTextField(
              controller: _nameController,
              labelText: l10n.auth_fullName,
              prefixIcon: Icons.person_outlined,
              validator: (value) => Validators.required(value, 'Full name'),
            ),
            const SizedBox(height: 16),
          ],

          // Email
          CustomTextField(
            controller: _emailController,
            labelText: l10n.auth_email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),

          // Password
          CustomTextField(
            controller: _passwordController,
            labelText: l10n.auth_password,
            obscureText: !_isPasswordVisible,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            validator: Validators.password,
          ),

          // Confirm Password (Register only)
          if (!widget.isLogin) ...[
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: l10n.auth_confirmPassword,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Submit Button
          CustomButton(
            text: widget.isLogin ? l10n.auth_signIn : l10n.auth_signUp,
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        widget.isLogin ? null : _nameController.text.trim(),
      );
    }
  }
}
