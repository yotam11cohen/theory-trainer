String friendlyAuthError(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('invalid login credentials')) {
    return 'Incorrect email or password.';
  }
  if (lower.contains('user already registered')) {
    return 'An account with this email already exists.';
  }
  if (lower.contains('email not confirmed')) {
    return 'Check your email to confirm your account.';
  }
  if (lower.contains('password should be at least')) {
    return 'Password must be at least 6 characters.';
  }
  if (lower.contains('invalid format') || lower.contains('unable to validate email')) {
    return 'Please enter a valid email address.';
  }
  return raw;
}
