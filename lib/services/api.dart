import 'package:http/http.dart' as http;
import 'dart:convert';
import '../state.dart' as state;

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

  return collections.map((e) => e as String).toList();
}

Future<void> addCollection(String host, String databaseName, String? auth, String collectionName) async {
  final url = Uri.parse('$host/$databaseName/collections');

  late final http.Response response;

  try {
    response = await http.post(url,
        headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'},
        body: jsonEncode({'name': collectionName}));
  } catch (e) {
    throw NetworkException();
  }

  final data = jsonDecode(response.body);

  print('Recieved response from api (POST /$databaseName/collections):');
  print(data);

  if (data['error'] != null) throw DatabaseConnectionException(data['error'], response.statusCode);
}

Future<void> renameCollection(
    String host, String databaseName, String? auth, String collectionName, String newCollectionName) async {
  final url = Uri.parse('$host/$databaseName/collections/$collectionName');

  late final http.Response response;

  try {
    response = await http.put(url,
        headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'},
        body: jsonEncode({'name': newCollectionName}));
  } catch (e) {
    throw NetworkException();
  }

  final data = jsonDecode(response.body);

  print('Recieved response from api (PUT /$databaseName/collections/$collectionName):');
  print(data);

  if (data['error'] != null) throw DatabaseConnectionException(data['error'], response.statusCode);
}

Future<void> deleteCollection(String host, String databaseName, String? auth, String collectionName) async {
  final url = Uri.parse('$host/$databaseName/collections/$collectionName');

  late final http.Response response;

  try {
    response = await http.delete(url, headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'});
  } catch (e) {
    throw NetworkException();
  }

  final data = jsonDecode(response.body);

  print('Recieved response from api (DELETE /$databaseName/collections/$collectionName):');
  print(data);

  if (data['error'] != null) throw DatabaseConnectionException(data['error'], response.statusCode);
}

Future<void> fetchCollections(String host, String name, String? auth) async {
  state.collections = await getCollections(host, name, auth);
  state.host = host;
  state.databaseName = name;
  state.auth = auth;
}
