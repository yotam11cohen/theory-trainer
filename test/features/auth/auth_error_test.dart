import 'package:flutter_test/flutter_test.dart';
import 'package:cleared_driving/features/auth/auth_error.dart';

void main() {
  group('friendlyAuthError', () {
    test('maps invalid login credentials', () {
      expect(
        friendlyAuthError('Invalid login credentials'),
        'Incorrect email or password.',
      );
    });

    test('maps user already registered', () {
      expect(
        friendlyAuthError('User already registered'),
        'An account with this email already exists.',
      );
    });

    test('maps email not confirmed', () {
      expect(
        friendlyAuthError('Email not confirmed'),
        'Check your email to confirm your account.',
      );
    });

    test('maps password too short', () {
      expect(
        friendlyAuthError('Password should be at least 6 characters'),
        'Password must be at least 6 characters.',
      );
    });

    test('maps invalid email format', () {
      expect(
        friendlyAuthError('Unable to validate email address: invalid format'),
        'Please enter a valid email address.',
      );
    });

    test('returns raw message for unknown errors', () {
      expect(
        friendlyAuthError('Some unknown error'),
        'Some unknown error',
      );
    });

    test('matching is case-insensitive', () {
      expect(
        friendlyAuthError('INVALID LOGIN CREDENTIALS'),
        'Incorrect email or password.',
      );
    });
  });
}
