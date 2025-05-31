import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';

late final String status;

getEnvItem(item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    return 'no API endpoint found';
  }
}

final clientRegion = getEnvItem('COGNITO_UP_REGION');
final clientId = getEnvItem('COGNITO_UP_CLIENTID');

Future<bool> signUpUser(
    BuildContext context, String email, String password) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  CognitoUserPoolData data;
  try {
    data = await userPool.signUp(
      email,
      password,
    );

    final appAuthProvider = context.read<AppAuthProvider>();
    final bool loginSuccess =
        await appAuthProvider.signIn(email, password, isRegister: true);

    if (loginSuccess) {
      print('Email confirmed and user logged in successfully.');
      return true;
    } else {
      print('Email confirmed, but automatic login failed.');
      return false; // Return false if login failed after successful confirmation
    }
  } on CognitoClientException catch (e) {
    print('CognitoClientException during signUpUser: ${e.message}');
    // Specific error handling for Cognito, e.g., UsernameExistsException
    return false;
  } catch (e) {
    print('Unexpected error during signUpUser: $e');
    return false;
  }
}

Future<bool> emailConfirmUser(email, password, code) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );

  bool registrationConfirmed = false;
  final cognitoUser = CognitoUser(email, userPool);
  try {
    registrationConfirmed = await cognitoUser.confirmRegistration(code);
  } catch (e) {
    print(e);
  }
  print(registrationConfirmed);
  // final auth = await authenticateUser(email, password, true);
  // if (auth == true && registrationConfirmed == true) {
  //   return auth;
  // }
  return false;
}

Future<void> emailResendConfirmation(email) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  final cognitoUser = CognitoUser(email, userPool);
  try {
    status = await cognitoUser.resendConfirmationCode();
  } catch (e) {
    print(status);
  }
}
