import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import '../api/user.dart';

getEnvItem(item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    return 'no API endpoint found';
  }
}

String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

final clientRegion = getEnvItem('COGNITO_UP_REGION');
final clientId = getEnvItem('COGNITO_UP_CLIENTID');

Future<bool> authenticateUser(email, password, register) async {
  final isFirstRegister = register;
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  //username: lawsonmarlowe@gmail.com
  //password: password001
  final cognitoUser = CognitoUser(email, userPool);
  final authDetails = AuthenticationDetails(
    username: email,
    password: password,
  );
  CognitoUserSession? session;
  try {
    session = await cognitoUser.authenticateUser(authDetails);
  } on CognitoUserNewPasswordRequiredException catch (e) {
    return false;
  } on CognitoUserMfaRequiredException catch (e) {
    return false;
  } on CognitoUserSelectMfaTypeException catch (e) {
    return false;
  } on CognitoUserMfaSetupException catch (e) {
    return false;
  } on CognitoUserTotpRequiredException catch (e) {
    return false;
  } on CognitoUserCustomChallengeException catch (e) {
    return false;
  } on CognitoUserConfirmationNecessaryException catch (e) {
    return false;
  } on CognitoClientException catch (e) {
    return false;
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return false;
  }
  final prefs = await SharedPreferences.getInstance();
  final token = session?.getAccessToken().getJwtToken();
  final idToken = session?.getIdToken().getJwtToken();
  session != null;
  if (email != null) {
    prefs.setString('email', email);
  }
  if (token != null) {
    prefs.setString('jwtCode', token);
    // ignore: avoid_print
    print(token);
  }
  if (idToken != null) {
    prefs.setString('jwtIdCode', idToken);
  }
  if (token != null && email != null && isFirstRegister == true) {
    final encryptedPassword = encryptPassword(password);
    final getUser = await getUserByEmail(email);
    final userId = getUser['userId'];
    final userUpdateBody = {
      "userId": userId,
      "passwordHashed": encryptedPassword,
      "authToken": token
    };
    await updateUserByUserId(userUpdateBody);
  }
  return true;
}

Future<bool> getUserAttr(email) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  //username: lawsonmarlowe@gmail.com
  //password: password001
  final cognitoUser = CognitoUser(email, userPool);
  List<CognitoUserAttribute>? attributes;
  try {
    attributes = await cognitoUser.getUserAttributes();
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return false;
  }
  attributes?.forEach((attribute) {
    // ignore: avoid_print
    print('USER ATTRIBUTES:');
    // ignore: avoid_print
    print('attribute ${attribute.getName()} has value ${attribute.getValue()}');
  });
  return true;
}
