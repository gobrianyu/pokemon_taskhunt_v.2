import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/blitz_game.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';

class AccountProvider extends ChangeNotifier {
  final Map<double, int> _collection;
  bool _darkMode = false;
  final BlitzGame _game;

  BlitzGame get game => _game.clone();

  void incrementBalance(int amount) {
    _game.incrementBalance(amount);
    notifyListeners();
  }

  void decrementBalance(int amount) {
    _game.decrementBalance(amount);
    notifyListeners();
  }

  void addItem(Items item, int amount) {
    _game.addItem(item, amount);
    _game.sortItems();
    notifyListeners();
  }

  void useItem(Items item) {
    _game.useItem(item);
    //_game.sortItems();
    notifyListeners();
  }

  void claimTask(Task task) {
    _game.claimTask(task);
    notifyListeners();
  }

  AccountProvider(): _collection = {}, _game = BlitzGame();
  
  // Map<double, int> _initCollection() {
  //   Map<double, int> coll = {};
  //   for (int i = 0; i < )
  // }

  Map<double, int> get collection => Map.from(_collection);

  bool get darkMode => _darkMode;

  void _updateCollection(double key, int status) {
    _collection[key] = status;
  }

  void _toggleMode() {
    _darkMode = !_darkMode;
  }
}