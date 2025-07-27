import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon_taskhunt_2/models/dex_db.dart';

class DexDBProvider extends ChangeNotifier {
  DexDB? _dexDB;
  bool _isLoading = true;

  DexDB? get dexDB => _dexDB;
  bool get isLoading => _isLoading;

  DexDBProvider() {
    _loadDexDB();
  }

  Future<void> _loadDexDB() async {
    const dataPath = 'assets/dex.json';
    final data = await rootBundle.loadString(dataPath);
    _dexDB = DexDB.initFromJson(data);
    _isLoading = false;
    notifyListeners();
  }
}