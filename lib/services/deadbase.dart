import 'package:http/http.dart' as http;
import 'dart:convert';

class DeadbaseConnectionException implements Exception {
  String errorResponse;
  int statusCode;

  DeadbaseConnectionException(this.errorResponse, this.statusCode);
}

class NetworkException implements Exception {}

class Deadbase {
  String host;
  String? auth;
  String name;

  Deadbase({required this.host, this.auth, required this.name});

  List<String>? pingedCollections;
  Future<void> ping() async {
    pingedCollections = await getCollections();
  }

  Future<List<String>> getCollections() async {
    if (pingedCollections != null) {
      final result = pingedCollections;
      pingedCollections = null;
      return result!;
    }

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

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);

    final collections = data['data'] as List<dynamic>;
    List<String> result;

    if (collections.isEmpty)
      result = [];
    else
      result = collections.map((e) => e as String).toList();

    return result;
  }

  Future<void> addCollection(String collectionName) async {
    final url = Uri.parse('$host/$name/collections');

    late final http.Response response;

    try {
      response = await http.post(url,
          headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'},
          body: jsonEncode({'name': collectionName}));
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (POST /$name/collections):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);
  }

  Future<void> renameCollection(String collectionName, String newCollectionName) async {
    final url = Uri.parse('$host/$name/collections/$collectionName');

    late final http.Response response;

    try {
      response = await http.put(url,
          headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'},
          body: jsonEncode({'name': newCollectionName}));
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (PUT /$name/collections/$collectionName):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);
  }

  Future<void> deleteCollection(String collectionName) async {
    final url = Uri.parse('$host/$name/collections/$collectionName');

    late final http.Response response;

    try {
      response = await http.delete(url, headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'});
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (DELETE /$name/collections/$collectionName):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);
  }

  Future<void> editDatabase(String newName, String? newAuth) async {
    final url = Uri.parse('$host/$name');

    late final http.Response response;

    try {
      response = await http.put(url,
          headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'},
          body: jsonEncode({'name': newName, 'auth': newAuth}));
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (PUT /$name):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);

    name = newName;
    auth = newAuth;
  }

  Future<List<String>> getDocuments(String collection) async {
    final url = Uri.parse('$host/$name/collections/$collection/documents');

    late final http.Response response;

    try {
      response = await http.get(url, headers: {'Authorization': auth ?? ''});
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (GET /$name/collections/$collection/documents):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);

    final documents = data['data'] as List<dynamic>;
    if (documents.isEmpty) return [];

    return documents.map((e) => e as String).toList();
  }

  Future<String> setDocument(String collection, Map<String, dynamic> documentData) async {
    final url = Uri.parse('$host/$name/collections/$collection/setDocument');

    late final http.Response response;

    try {
      response = await http.post(url,
          headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'}, body: jsonEncode(documentData));
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (POST /$name/collections/$collection/setDocument):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);

    return data['data'];
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    final url = Uri.parse('$host/$name/collections/$collection/documents/$documentId');

    late final http.Response response;

    try {
      response = await http.delete(url, headers: {'Authorization': auth ?? '', 'Content-Type': 'application/json'});
    } catch (e) {
      throw NetworkException();
    }

    final data = jsonDecode(response.body);

    print('Recieved response from api (DELETE /$name/collections/$collection/documents/$documentId):');
    print(data);

    if (data['error'] != null) throw DeadbaseConnectionException(data['error'], response.statusCode);
  }
}
