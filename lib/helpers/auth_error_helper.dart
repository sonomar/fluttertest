String simplifyAuthError(String? rawError) {
  // Default message for unknown or null errors
  if (rawError == null) {
    return 'auth_error_helper_simplify_unknown';
  }

  // Convert the error to lowercase for case-insensitive matching
  final error = rawError.toLowerCase();

  // --- Start with the most specific exception codes ---

  // MODIFICATION: Added a check for the JSON error from the email code challenge.
  if (error.contains('"challengename":"custom_challenge"')) {
    return 'auth_error_helper_simplify_wrongcode';
  }
  if (error.contains('invalid verification code')) {
    return 'auth_error_helper_simplify_wrongcode';
  }
  if (error.contains('codemismatchexception')) {
    return 'auth_error_helper_simplify_wrongcode';
  }
  if (error.contains('notauthorizedexception')) {
    return 'auth_error_helper_simplify_wrongpass';
  }
  if (error.contains('invalidparameterexception')) {
    return 'auth_error_helper_simplify_invalidparam';
  }
  if (error.contains('usernameexistsexception')) {
    return 'auth_error_helper_simplify_emailexists';
  }
  if (error.contains('user not found')) {
    return 'auth_error_helper_simplify_usernotfound';
  }
  if (error.contains('user is not confirmed')) {
    return 'auth_error_helper_simplify_notconfirmed';
  }
  if (error.contains('limit exceeded')) {
    return 'auth_error_helper_simplify_limitexceeded';
  }

  // --- Check for message text as a fallback ---
  if (error.contains('incorrect username or password')) {
    return 'auth_error_helper_simplify_wrongpass';
  }

  // --- Final fallback ---
  print('Unhandled Auth Error: $rawError');
  return 'auth_error_helper_simplify_unexpected';
}
