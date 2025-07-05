/// A helper function to convert verbose AWS Cognito error messages
/// into simple, user-friendly strings.
String simplifyAuthError(String? rawError) {
  // Default message for unknown or null errors
  if (rawError == null) {
    return 'An unknown error occurred.';
  }

  // Convert the error to lowercase for case-insensitive matching
  final error = rawError.toLowerCase();

  // --- Common Sign-In and Sign-Up Errors ---
  if (error.contains('user not found') ||
      error.contains('user does not exist')) {
    return 'User with this email not found.';
  }
  if (error.contains('incorrect username or password')) {
    return 'Incorrect email or password.';
  }
  if (error.contains('user already exists') ||
      error.contains('usernameexistsexception')) {
    return 'This email is already registered.';
  }
  if (error.contains('user is not confirmed')) {
    return 'Account has not been confirmed.';
  }

  // --- Password Errors ---
  if (error.contains('password did not conform')) {
    return 'Password format is invalid.';
  }
  // This can happen during passwordless sign-in if the session is invalid
  if (error.contains('not authorized')) {
    return 'Incorrect code or session expired.';
  }

  // --- Verification Code Errors (for Sign-up, Passwordless, and Forgot Password) ---
  if (error.contains('code mismatch') ||
      error.contains('invalid verification code')) {
    return 'Incorrect verification code.';
  }
  if (error.contains('expired code')) {
    return 'Verification code has expired.';
  }
  // A more generic code error for passwordless sign-in
  if (error.contains('failed to verify code')) {
    return 'Incorrect code or it has expired.';
  }

  // --- General & Throttling Errors ---
  if (error.contains('limit exceeded') ||
      error.contains('attempt limit exceeded')) {
    return 'Too many attempts. Try again later.';
  }
  if (error.contains('invalid parameter')) {
    return 'Invalid email or password format.';
  }

  // Fallback for any other errors not specifically handled
  print('Unhandled Auth Error: $rawError');
  return 'An unexpected error occurred.';
}
