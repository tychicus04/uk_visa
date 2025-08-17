// lib/features/auth/providers/password_reset_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/password_reset_service.dart';

// Password Reset State
class PasswordResetState {
  final bool isLoading;
  final String? error;
  final bool emailSent;
  final bool isResendCooldown;
  final int resendCooldownSeconds;
  final String? sentEmail;

  const PasswordResetState({
    this.isLoading = false,
    this.error,
    this.emailSent = false,
    this.isResendCooldown = false,
    this.resendCooldownSeconds = 0,
    this.sentEmail,
  });

  PasswordResetState copyWith({
    bool? isLoading,
    String? error,
    bool? emailSent,
    bool? isResendCooldown,
    int? resendCooldownSeconds,
    String? sentEmail,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      emailSent: emailSent ?? this.emailSent,
      isResendCooldown: isResendCooldown ?? this.isResendCooldown,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
      sentEmail: sentEmail ?? this.sentEmail,
    );
  }
}

// Reset Password State
class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final bool isVerifyingToken;
  final bool isTokenValid;
  final bool passwordReset;
  final String? tokenEmail;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.isVerifyingToken = false,
    this.isTokenValid = false,
    this.passwordReset = false,
    this.tokenEmail,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isVerifyingToken,
    bool? isTokenValid,
    bool? passwordReset,
    String? tokenEmail,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isVerifyingToken: isVerifyingToken ?? this.isVerifyingToken,
      isTokenValid: isTokenValid ?? this.isTokenValid,
      passwordReset: passwordReset ?? this.passwordReset,
      tokenEmail: tokenEmail ?? this.tokenEmail,
    );
  }
}

// Password Reset Provider
final passwordResetProvider = StateNotifierProvider<PasswordResetNotifier, PasswordResetState>(
      (ref) => PasswordResetNotifier(ref),
);

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  final Ref ref;

  PasswordResetNotifier(this.ref) : super(const PasswordResetState());

  Future<void> sendForgotPasswordEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final passwordResetService = ref.read(passwordResetServiceProvider);
      final response = await passwordResetService.forgotPassword(email: email);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          emailSent: true,
          sentEmail: email,
        );

        // Start resend cooldown
        _startResendCooldown();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> resendForgotPasswordEmail() async {
    if (state.isResendCooldown || state.sentEmail == null) return;

    await sendForgotPasswordEmail(state.sentEmail!);
  }

  void _startResendCooldown() {
    state = state.copyWith(
      isResendCooldown: true,
      resendCooldownSeconds: 60,
    );

    // Countdown timer
    _countdownTimer();
  }

  void _countdownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (state.resendCooldownSeconds > 0) {
        state = state.copyWith(
          resendCooldownSeconds: state.resendCooldownSeconds - 1,
        );
        _countdownTimer();
      } else {
        state = state.copyWith(
          isResendCooldown: false,
          resendCooldownSeconds: 0,
        );
      }
    });
  }

  void resetState() {
    state = const PasswordResetState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Reset Password Provider
final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
      (ref) => ResetPasswordNotifier(ref),
);

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final Ref ref;

  ResetPasswordNotifier(this.ref) : super(const ResetPasswordState());

  Future<void> verifyResetToken(String token) async {
    state = state.copyWith(isVerifyingToken: true, error: null);

    try {
      final passwordResetService = ref.read(passwordResetServiceProvider);
      final response = await passwordResetService.verifyResetToken(token: token);

      if (response.success && response.data != null) {
        final isValid = response.data!['valid'] as bool? ?? false;
        final email = response.data!['email'] as String?;

        state = state.copyWith(
          isVerifyingToken: false,
          isTokenValid: isValid,
          tokenEmail: email,
          error: isValid ? null : 'Invalid or expired reset token',
        );
      } else {
        state = state.copyWith(
          isVerifyingToken: false,
          isTokenValid: false,
          error: response.message ?? 'Failed to verify token',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isVerifyingToken: false,
        isTokenValid: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final passwordResetService = ref.read(passwordResetServiceProvider);
      final response = await passwordResetService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          passwordReset: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    state = const ResetPasswordState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}