import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';

class MovesDBProvider extends ChangeNotifier {
  final MovesDB _movesDB = MovesDB();
  bool _isLoading = true;

  MovesDB get movesDB => _movesDB;
  bool get isLoading => _isLoading;

  MovesDBProvider() {
    _loadMovesDB();
  }

  Future<void> _loadMovesDB() async {
    const dataPath = 'assets/moves.csv';
    final data = await rootBundle.loadString(dataPath);
    _movesDB.initFromCsv(data);
    _isLoading = false;
    notifyListeners();
  }
}