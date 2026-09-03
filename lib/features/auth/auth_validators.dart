import '../../core/constants/app_constants.dart';

/// Form rules for the auth screens.
///
/// Each check returns a localisation key or null, never display text: the
/// screen resolves the key, so the rules stay free of BuildContext and one
/// message is worded once for every form that can raise it.
///
/// Validation runs on submit rather than on keystroke. Checking as someone
/// types interrupts them before they have finished, and an email address is
/// invalid for most of the time it takes to write one. The single exception is
/// the confirmation password, which checks itself once the field above it has
/// been left — there, immediate feedback saves retyping both.
class AuthValidators {
  const AuthValidators._();

  /// Deliberately loose: something, an @, something, a dot, something. The
  /// only authority on whether an address exists is whether mail to it
  /// arrives, so a stricter pattern here would reject real addresses to no end.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static final RegExp _hasLetter = RegExp('[A-Za-z]');
  static final RegExp _hasDigit = RegExp('[0-9]');

  static String? email(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'auth.error.emailRequired';
    }
    return _email.hasMatch(trimmed) ? null : 'auth.error.emailInvalid';
  }

  /// Sign-in only asks that something was typed. Whether it is the right
  /// password is Firebase's answer to give, and guessing at the rules here
  /// would lock out an account whose password predates them.
  static String? existingPassword(String value) =>
      value.isEmpty ? 'auth.error.passwordRequired' : null;

  /// Registration: at least eight characters, with a letter and a number.
  static String? newPassword(String value) {
    if (value.isEmpty) {
      return 'auth.error.passwordRequired';
    }
    if (value.length < AppConstants.minPasswordLength ||
        !_hasLetter.hasMatch(value) ||
        !_hasDigit.hasMatch(value)) {
      return 'auth.error.passwordWeak';
    }
    return null;
  }

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) {
      return 'auth.error.confirmRequired';
    }
    return confirm == password ? null : 'auth.error.passwordMatch';
  }

  static String? name(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'auth.error.nameRequired';
    }
    return trimmed.length < 2 ? 'auth.error.nameShort' : null;
  }

  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'auth.error.dobRequired';
    }
    return completedYears(value) < AppConstants.minimumAgeYears
        ? 'auth.error.dobTooYoung'
        : null;
  }

  static String? country(String? code) =>
      code == null ? 'auth.error.countryRequired' : null;

  /// Completed years between [dateOfBirth] and today.
  static int completedYears(DateTime dateOfBirth) {
    final DateTime now = DateTime.now();
    final bool beforeBirthday =
        now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day);
    return now.year - dateOfBirth.year - (beforeBirthday ? 1 : 0);
  }
}
