import 'package:flutter/material.dart';
import 'package:pokemon_taskhunt_2/models/blitz_game.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';

class AccountProvider extends ChangeNotifier {
  final Map<double, int> _collection;
  bool _darkMode = false;
  final BlitzGame _blitzGame;

  BlitzGame get blitzGame => _blitzGame.clone();

  void setSpawns(List<Pokemon?> spawns) {
    _blitzGame.setSpawns(spawns);
    notifyListeners();
  }

  void incrementRound() {
    _blitzGame.incrementRound();
    notifyListeners();
  }

  void incrementBalance(int amount, sourceKey) {
    _blitzGame.incrementBalance(amount, sourceKey);
    notifyListeners();
  }

  void decrementBalance(int amount) {
    _blitzGame.decrementBalance(amount);
    notifyListeners();
  }

  void incrementFriendship(Pokemon? mon) {
    _blitzGame.incrementFriendship(mon);
    notifyListeners();
  }

  void setHeldItem(Pokemon mon, Items? item) {
    _blitzGame.setHeldItem(mon, item);
    notifyListeners();
  }

  void addItemThroughPurchase(Items? item, int amount, int sourceKey) {
    if (item == null) {
      return;
    }
    _blitzGame.addItemThroughPurchase(item, amount, sourceKey);
    _blitzGame.sortItems();
    notifyListeners();
  }

  void addItem(Items? item, int amount) {
    if (item == null) {
      return;
    }
    _blitzGame.addItem(item, amount);
    _blitzGame.sortItems();
    notifyListeners();
  }

  void unlockEggSlot(int price) {
    _blitzGame.unlockEggSlot(price);
    notifyListeners();
  }

  void removeItem(Items item) {
    _blitzGame.removeItem(item);
    notifyListeners();
  }

  void claimTask(Task task) {
    _blitzGame.claimTask(task);
    notifyListeners();
  }

  void partyAdd(Pokemon mon, Pokemon? toReplace) {
    _blitzGame.partyAdd(mon, toReplace);
    notifyListeners();
  }

  void addCatchExp(int amount) {
    _blitzGame.addCatchExp(amount);
    notifyListeners();
  }

  void addExp(int amount) {
    _blitzGame.addExp(amount);
    notifyListeners();
  }

  AccountProvider(): _collection = {}, _blitzGame = BlitzGame();
  
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