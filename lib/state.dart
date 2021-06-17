import './services/deadbase.dart';

List<Deadbase> stashedDatabases = [];

class InvalidDeadbaseIdException implements Exception {}

Deadbase getStashedDatabase(String id) {
  final integer = int.parse(id);
  if (stashedDatabases.length < integer + 1) throw InvalidDeadbaseIdException();

  return stashedDatabases[integer];
}

String Function(Deadbase) prepareStashDeadbase() {
  final newIndex = stashedDatabases.length;

  return (deadbase) {
    stashedDatabases.insert(newIndex, deadbase);
    return '$newIndex';
  };
}
