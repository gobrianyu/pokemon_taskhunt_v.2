import 'package:pokemon_taskhunt_2/models/move.dart';

class MovesDB{
  static final MovesDB _instance = MovesDB._internal();
  final List<Move> _moves;
  
  List<Move> get all {
    return List<Move>.from(_moves, growable: false);
  }

  Move getById(int moveId) {
    Move toReturn = _moves[moveId];
    if (toReturn.id != moveId) {
      return _moves.firstWhere((move) => move.id == moveId);
    }
    return toReturn;
  }

  // Private constructor
  MovesDB._internal() : _moves = [];

  // Factory constructor to return the same instance
  factory MovesDB() {
    return _instance;
  }

  void initFromCsv(String csvString) {
    final movesList = _loadMovesFromCsv(csvString);
    _moves.addAll(movesList);
  }

  static List<Move> _loadMovesFromCsv(String csvString) {
    final lines = csvString.split('\n');
    if (lines.isNotEmpty && lines[0].startsWith('sep=|')) {
      lines.removeAt(0);
    }
    if (lines.isNotEmpty && lines[0].startsWith('id')) {
      lines.removeAt(0);
    }
    List<List<dynamic>> rows = [];
    for (String line in lines) {
      rows.add(line.split('|'));
    }
    final movePool = rows.map((row) => Move.fromCsv(row)).toList();
    movePool.insert(0, Move.placeholder());
    return movePool;
  }
}