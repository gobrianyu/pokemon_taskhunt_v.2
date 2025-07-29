import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/moves_map_db.dart';

class MovesMapDBProvider extends ChangeNotifier {
  MovesMapDB _movesMap = MovesMapDB();
  bool _isLoading = true;

  MovesMapDB get movesMap => _movesMap;
  bool get isLoading => _isLoading;

  MovesMapDBProvider() {
    _loadMovesMapDB();
  }

  Future<void> _loadMovesMapDB() async {
    const dataPath = 'assets/moves_map.json';
    final data = await rootBundle.loadString(dataPath);
    _movesMap = MovesMapDB.initFromJson(data);
    _isLoading = false;
    notifyListeners();
  }
}