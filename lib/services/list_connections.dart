import 'package:http/http.dart' as http;
import 'dart:convert';
import '../state.dart';

class DatabaseConnectionException implements Exception {
  String errorResponse;
  int statusCode;

  DatabaseConnectionException(this.errorResponse, this.statusCode);
}

class NetworkException implements Exception {}

Future<List<String>> getCollections(String host, String name, String? auth) async {
  final url = Uri.parse('$host/$name/collections');

  late final http.Response response;

  try {
    response = await http.get(url, headers: {'Authorization': auth ?? ''});
  } catch (e) {
    throw NetworkException();
  }

  final data = jsonDecode(response.body);

  print('Recieved response from api (GET /$name/collections):');
  print(data);

  if (data['error'] != null) throw DatabaseConnectionException(data['error'], response.statusCode);

  final collections = data['data'] as List<dynamic>;
  if (collections.isEmpty) return [];

  return collections as List<String>;
}

Future<void> fetchCollections(String host, String name, String? auth) async {
  collections = await getCollections(host, name, auth);
}
