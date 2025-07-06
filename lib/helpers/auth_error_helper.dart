/// A helper function to convert verbose AWS Cognito error messages
/// into simple, user-friendly strings.
String simplifyAuthError(String? rawError) {
  // Default message for unknown or null errors
  if (rawError == null) {
    return 'auth_error_helper_simplify_unknown';
  }

  // Convert the error to lowercase for case-insensitive matching
  final error = rawError.toLowerCase();

  // --- Common Sign-In and Sign-Up Errors ---
  if (error.contains('user not found') ||
      error.contains('user does not exist')) {
    return 'auth_error_helper_simplify_usernotfound';
  }
  if (error.contains('incorrect username or password')) {
    return 'auth_error_helper_simplify_wrongpass';
  }
  if (error.contains('user already exists') ||
      error.contains('usernameexistsexception')) {
    return 'auth_error_helper_simplify_emailexists';
  }
  if (error.contains('user is not confirmed')) {
    return 'auth_error_helper_simplify_notconfirmed';
  }

  // --- Password Errors ---
  if (error.contains('password did not conform')) {
    return 'auth_error_helper_simplify_invalidpass';
  }
  // This can happen during passwordless sign-in if the session is invalid
  if (error.contains('not authorized')) {
    return 'auth_error_helper_simplify_codeexpired';
  }

  // --- Verification Code Errors (for Sign-up, Passwordless, and Forgot Password) ---
  if (error.contains('code mismatch') ||
      error.contains('invalid verification code')) {
    return 'auth_error_helper_simplify_wrongcode';
  }
  if (error.contains('expired code')) {
    return 'auth_error_helper_simplify_codeexpired2';
  }
  // A more generic code error for passwordless sign-in
  if (error.contains('failed to verify code')) {
    return 'auth_error_helper_simplify_codeexpired3';
  }

  // --- General & Throttling Errors ---
  if (error.contains('limit exceeded') ||
      error.contains('attempt limit exceeded')) {
    return 'auth_error_helper_simplify_limitexceeded';
  }
  if (error.contains('invalid parameter')) {
    return 'auth_error_helper_simplify_invalidparam';
  }

  // Fallback for any other errors not specifically handled
  print('Unhandled Auth Error: $rawError');
  return 'auth_error_helper_simplify_unexpected';
}
