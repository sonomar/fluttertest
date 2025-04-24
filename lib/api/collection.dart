import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'api_init.dart';

void getAllCollectibles() async {
  apiGetRequest('/getAllCollectibles');
}
