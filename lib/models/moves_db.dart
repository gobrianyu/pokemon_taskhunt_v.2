import 'package:pokemon_taskhunt_2/models/move.dart';

class MovesDB{
  final List<Move> _moves;
  
  List<Move> get all {
    return List<Move>.from(_moves, growable: false);
  }

  MovesDB.initFromCsv(String csvString) : _moves = _loadMovesFromCsv(csvString);

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
    return rows.map((row) => Move.fromCsv(row)).toList();
  }
}