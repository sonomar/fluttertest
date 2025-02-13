import 'api_init.dart';

Future getAllCollectibles() async {
  final code = await jwtIdCode;
  await getQuery(
      '/getAllCollectibles',
      {'Authorization': code},
      Map<String, String>.from({'tracking': 'x123'}),
      Map<String, dynamic>.from({}));
}
