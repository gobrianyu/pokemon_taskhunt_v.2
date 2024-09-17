import 'dart:math';

import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';
import 'package:pokemon_taskhunt_2/models/task_list.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';

class BlitzGame {
  int balance;
  int round;
  Map<Items, int> items;
  List<Items> buffs;
  int tasksCompleted;
  int starsCompleted;
  TaskList taskList;
  List party;

  BlitzGameData data;

  factory BlitzGame() {
    return BlitzGame.withFields(balance: 200, round: 1, items: initItems(), buffs: [], party: [], taskList: TaskList(16, 50), starsCompleted: 0, tasksCompleted: 0, data: BlitzGameData());
  }

  BlitzGame.withFields({required this.balance, required this.round, required this.items, required this.buffs, required this.party, required this.taskList, required this.starsCompleted, required this.tasksCompleted, required this.data});
  
  static Map<Items, int> initItems() {
    Map<Items, int> map = {};
    map[Items.pokeBall] = 5;
    return map;
  }

  void incrementRound() {
    round++;
  }

  void claimTask(Task task) {
    if (taskList.tasks.contains(task)) {
      tasksCompleted++;
      starsCompleted += task.difficulty;
      taskList.removeTask(task);
    }
  }

  void incrementBalance(int amount) {
    balance += amount;
    if (balance > 9999999) {
      balance = 9999999;
    }
  }

  void decrementBalance(int amount) {
    balance -= amount;
  }

  void addItem(Items item, int amount) {
    items.update(item, (existing) => existing + amount, ifAbsent: () => amount);
  }

  void sortItems() {
    items = Map.fromEntries(
    items.entries.toList()
      ..sort((e1, e2) => e1.key.key.compareTo(e2.key.key)));
  }

  void useItem(Items item) {
    if (items[item] != null) {
      if (items[item]! <= 1) {
        items.remove(item);
      } else {
        items.update(item, (existing) => --existing);
      }
    }
  }

  BlitzGame clone() {
    return BlitzGame.withFields(balance: balance, round: round, items: items, buffs: buffs, party: party, taskList: taskList, starsCompleted: starsCompleted, tasksCompleted: tasksCompleted, data: data);
  }

  Pokemon generateEncounter(List<DexEntry> dex) {
    Random random = Random();
    int key = random.nextInt(dex.length);
    bool isShiny = random.nextInt(4096) == 0;
    return Pokemon.fromDexEntry(dex[key], 1, isShiny);
  }
}

class BlitzGameData {
  int totalCoinsEarned;
  int catchCoinsEarned;
  int battleCoinsEarned;
  int sellCoinsEarned;
  int totalExpEarned;
  int catchExpEarned;
  int battleExpEarned;
  num lastCaught;
  int totalCaught;
  Map<Regions, int> regionCaught;
  Set uniqueCaught; //TODO
  Map<Types, int> typeCaught;
  int starterCaught;
  int regionalCaught;
  int pseudoCaught;
  int fossilCaught;
  int paradoxCaught;
  int shinyCaught;
  int failCaught;
  int totalHatched;
  Map<Types, int> typeHatched;
  Map<Regions, int> regionHatched;
  num lastHatched; // key
  int totalLevelUps;
  int totalBattles;
  int battleWins;
  int battleLosses;
  Map<Types, int> typeBattles; // number of battles USING specific type
  Map<Types, int> typeBattleWins; // number of battle wins AGAINST specific type
  int battleWinsDisad;
  int battleLossesAd;
  int totalItemsUsed;
  Map<Items, int> itemsUsed;
  int totalItemsBought;
  Map<Items, int> itemsBought;
  int totalItemsSold;
  Map<Items, int> itemsSold;
  num lastEvolved;
  int totalEvolved;

  factory BlitzGameData() {
    return BlitzGameData.withFields(
      totalCoinsEarned: 0, 
      catchCoinsEarned: 0, 
      battleCoinsEarned: 0, 
      sellCoinsEarned: 0,
      totalExpEarned: 0,
      catchExpEarned: 0, 
      battleExpEarned: 0, 
      lastCaught: -1, 
      totalCaught: 0,
      uniqueCaught: {}, //TODO:
      regionCaught: {}, 
      typeCaught: {},
      starterCaught: 0,
      regionalCaught: 0, 
      pseudoCaught: 0, 
      fossilCaught: 0, 
      paradoxCaught: 0,
      shinyCaught: 0, 
      failCaught: 0, 
      totalHatched: 0,
      typeHatched: {},
      regionHatched: {}, 
      lastHatched: -1, 
      totalLevelUps: 0, 
      totalBattles: 0, 
      battleWins: 0, 
      battleLosses: 0,
      typeBattles: {},
      typeBattleWins: {},
      battleWinsDisad: 0,
      battleLossesAd: 0,
      totalItemsUsed: 0,
      itemsUsed: {},
      totalItemsBought: 0, 
      itemsBought: {}, 
      totalItemsSold: 0,
      itemsSold: {},
      lastEvolved: -1,
      totalEvolved: 0,
    );
  }

  BlitzGameData.withFields({
    required this.totalCoinsEarned,
    required this.catchCoinsEarned,
    required this.battleCoinsEarned,
    required this.sellCoinsEarned,
    required this.totalExpEarned,
    required this.catchExpEarned,
    required this.battleExpEarned,
    required this.lastCaught,
    required this.totalCaught,
    required this.uniqueCaught,
    required this.regionCaught,
    required this.typeCaught,
    required this.starterCaught,
    required this.regionalCaught,
    required this.pseudoCaught,
    required this.fossilCaught,
    required this.paradoxCaught,
    required this.shinyCaught,
    required this.failCaught,
    required this.totalHatched,
    required this.typeHatched,
    required this.regionHatched,
    required this.lastHatched,
    required this.totalLevelUps,
    required this.totalBattles,
    required this.battleWins,
    required this.battleLosses,
    required this.typeBattles,
    required this.typeBattleWins,
    required this.battleWinsDisad,
    required this.battleLossesAd,
    required this.totalItemsUsed,
    required this.itemsUsed,
    required this.totalItemsBought,
    required this.itemsBought,
    required this.totalItemsSold,
    required this.itemsSold,
    required this.lastEvolved,
    required this.totalEvolved,
  });

  dynamic getField(String key) {
    switch (key) {
      case 'totalCoinsEarned': return totalCoinsEarned;
      case 'catchCoinsEarned': return catchCoinsEarned;
      case 'battleCoinsEarned':  return battleCoinsEarned;
      case 'sellCoinsEarned': return sellCoinsEarned;
      case 'totalExpEarned': return totalExpEarned;
      case 'catchExpEarned': return catchExpEarned;
      case 'battleExpEarned': return battleExpEarned;
      case 'lastCaught': return lastCaught;
      case 'totalCaught': return totalCaught;
      case 'regionCaught': return regionCaught;
      case 'typeCaught': return typeCaught;
      case 'starterCaught': return starterCaught;
      case 'regionalCaught': return regionalCaught; 
      case 'pseudoCaught': return pseudoCaught;
      case 'fossilCaught': return fossilCaught;
      case 'paradoxCaught': return paradoxCaught;
      case 'shinyCaught': return shinyCaught;
      case 'failCaught': return failCaught;
      case 'totalHatched': return totalHatched;
      case 'typeHatched': return typeHatched;
      case 'regionHatched': return regionHatched;
      case 'lastHatched': return lastHatched;
      case 'totalLevelUps': return totalLevelUps;
      case 'totalBattles': return totalBattles; 
      case 'battleWins': return battleWins; 
      case 'battleLosses': return battleLosses;
      case 'typeBattles': return typeBattles;
      case 'typeBattleWins': return typeBattleWins;
      case 'battleWinsDisad': return battleWinsDisad;
      case 'battleLossesAd': return battleLossesAd;
      case 'totalItemsUsed': return totalItemsUsed;
      case 'itemsUsed': return itemsUsed;
      case 'totalItemsBought': return totalItemsBought; 
      case 'itemsBought': return itemsBought;
      case 'totalItemsSold': return totalItemsSold;
      case 'itemsSold': return itemsSold;
      case 'lastEvolved': return lastEvolved;
      case 'totalEvolved': return totalEvolved;
      default:
        throw ArgumentError('Field not found');
    }
  }
}