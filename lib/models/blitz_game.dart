import 'dart:math';

import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/moves_map_db.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';
import 'package:pokemon_taskhunt_2/models/task_list.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';

// TODO list:
// - stamina
// - update egg logic
// - implement buffs + slates
// -


// Represents a blitz-mode game session;
// randomly generates 16 tasks with summed difficulty of 50.

class BlitzGame {
  List<Pokemon?> spawns;  // List of current spawns on the board; resets every round
  int balance;
  int round;
  Map<Items, int> items;  // Player's bag
  Map<Items, int> buffs;  // TODO: create buffs class?

  TaskList taskList;  // List of tasks for this game session
  int tasksCompleted;
  int starsCompleted;

  List<Pokemon> party;  // Player's current party (team)
  List<Egg> eggs;  // See `incubator.dart`
  int unlockedEggSlots;

  Regions? slate;  // TODO: add to buffs?

  BlitzGameData data;  // Player stats data


  // Factory constructor; inits a game session at round 1 with:
  // - balance: 200
  // - 6 Poké balls in bag
  // - 2 unlocked egg slots in incubator
  // - everything else empty
  factory BlitzGame() {
    return BlitzGame.withFields(
      spawns: [],
      balance: 200,
      round: 1,
      items: initItems(),  // Returns bag with 6 Poké balls
      buffs: {},
      party: [],
      eggs: [Egg(imageAsset: "Mystery Egg", eggType: "", rarity: 4, shinyRate: 0, hatchCount: 10)],  // TODO: remove temporary egg from init
      taskList: TaskList(16, 50),  // 16 tasks with summed difficulty 50
      starsCompleted: 0,
      tasksCompleted: 0,
      data: BlitzGameData(),
      unlockedEggSlots: 2
    );
  }

  BlitzGame.withFields({
    required this.spawns,
    required this.balance,
    required this.round,
    required this.items,
    required this.buffs,
    required this.party,
    required this.eggs,
    required this.taskList,
    required this.starsCompleted,
    required this.tasksCompleted,
    required this.data,
    this.slate,  // TODO: implement
    required this.unlockedEggSlots
  });
  
  // Initializes an item bag with 6 Poké balls.
  static Map<Items, int> initItems() {
    Map<Items, int> bag = {};
    bag[Items.pokeBall] = 6;
    return bag;
  }

  // Updates spawn list with provided new spawn list.
  void setSpawns(List<Pokemon?> newSpawns) {
    spawns = newSpawns;
  }

  // Increments round; should only be called after successful catch,
  // forced skip, or when stamina is 0.
  void incrementRound() {
    round++;
    incrementEggCounter();
  }

  // Increments egg hatch progress; should only be called after
  // incrementing game round.
  void incrementEggCounter() {
    for (Egg egg in eggs) {
      egg.incrementCounter();
    }
  }

  void claimTask(Task task) {
    if (taskList.tasks.contains(task)) {
      tasksCompleted++;
      starsCompleted += task.difficulty;
      taskList.removeTask(task);
    }
  }

  // Gives provided held item to specified party member;
  // does nothing if member not found.
  void setHeldItem(Pokemon mon, Items? item) {
    for (Pokemon member in party) {
      if (member == mon) {
        member.heldItem = item;
      }
    }
  }

  // Increments player balance by specified amount;
  // balance unable to exceed 9,999,999 coins.
  // Updates relevant tasks.
  //
  // Params:
  // - amount: integer amount to increment balance by.
  // - sourceKey: integer key representing source of coins;
  //   used solely for purpose of updating player data.
  //     (0) no source
  //     (1) catching
  //     (2) battling
  //     (3) selling
  void incrementBalance(int amount, int sourceKey) {
    balance += amount;
    if (balance > 9999999) {
      amount -= (balance - 9999999);
      balance = 9999999;
    }
    data.totalCoinsEarned += amount;  // TODO: flush out data updating logic
    switch (sourceKey) {
      case 1: data.catchCoinsEarned += amount;
      case 2: data.battleCoinsEarned += amount;
      case 3: data.sellCoinsEarned += amount; 
    }
    taskList.updateTasks(data);
  }

  // Decrements player balance by specified amount. Typically called
  // when user spends coins. Caller should first check that balance
  // cannot be decremented past 0.
  void decrementBalance(int amount) {
    balance -= amount;
  }

  // Adds specified amount of an item to the player's item bag.
  // Called only for shop-related purchases (i.e. Shop, Black Market, Egg Market). // TODO: update once shop names decided
  // This method does not take care of balance transactions.
  // 
  // Params:
  // - item: item that was purchased.
  // - amount: integer amount to increment balance by.
  // - sourceKey: integer key representing source of purchase;
  //   used solely for purpose of updating player data.
  //     (0) no source [unlikely/impossible]
  //     (1) [regular] shop
  //     (2) black market
  //     (3) egg market
  void addItemThroughPurchase(Items item, int amount, int sourceKey) {
    switch (sourceKey) {
      case 1:
        data.shopItemsBought += amount;
        data.itemsBought.update(item, (existing) => existing + amount, ifAbsent: () => amount);
    }
    addItem(item, amount);
  }

  // Adds specified amount of an item to the player's item bag.
  void addItem(Items item, int amount) {
    data.totalItemsBought += amount;
    items.update(item, (existing) => existing + amount, ifAbsent: () => amount);
    taskList.updateTasks(data);
  }

  void addCatchExp(int amount) {
    data.catchExpEarned += amount;
    addExp(amount);
  }

  void addBattleExp(int amount) {
    data.battleExpEarned += amount;
    addExp(amount);
  }

  void unlockEggSlot(int price) {
    if (price <= balance) {
      unlockedEggSlots++;
      decrementBalance(price);
    }
    // TODO: Implement
  }

  void incrementFriendship(Pokemon? mon) {
    if (mon == null) {
      for (Pokemon member in party) {
        if (member.friendship < 5) member.friendship++;
      }
    } else {
      for (Pokemon member in party) {
        if (member == mon && member.friendship < 5) {
          member.friendship++;
        }
      }
    }
  }

  void addExp(int amount) {
    if (party.isNotEmpty) {
      for (Pokemon mon in party) {
        double expEarned = amount / party.length * (1 + mon.friendship / 10);
        if (mon.heldItem == Items.luckyEgg) expEarned *= 2;
        mon.incrementExp(expEarned.round());
      }
    }
    data.totalExpEarned += amount;
    taskList.updateTasks(data);
  }

  void sortItems() {
    items = Map.fromEntries(
    items.entries.toList()
      ..sort((e1, e2) => e1.key.key.compareTo(e2.key.key)));
  }

  void removeItem(Items item) {
    if (items[item] != null) {
      if (items[item]! <= 1) {
        items.remove(item);
      } else {
        items.update(item, (existing) => --existing);
      }
    }
  }

  BlitzGame clone() {
    return BlitzGame.withFields(spawns: spawns, balance: balance, round: round, items: items, buffs: buffs, party: party, eggs: eggs, taskList: taskList, starsCompleted: starsCompleted, tasksCompleted: tasksCompleted, data: data, unlockedEggSlots: unlockedEggSlots);
  }

  List<Types> _encounterTypeBuffs(int level) {
    if (level > 2 || level < 0) {
      throw const FormatException();
    }
    if (buffs.isEmpty) {
      return [];
    }
    List<Types> typeList = [];
    if (level == 0) {
      if (buffs.containsKey(Items.lureNormal)) typeList.add(Types.normal);
      if (buffs.containsKey(Items.lureFire)) typeList.add(Types.fire);
      if (buffs.containsKey(Items.lureWater)) typeList.add(Types.water);
      if (buffs.containsKey(Items.lureElectric)) typeList.add(Types.electric);
      if (buffs.containsKey(Items.lureGrass)) typeList.add(Types.grass);
      if (buffs.containsKey(Items.lureIce)) typeList.add(Types.ice);
      if (buffs.containsKey(Items.lureFighting)) typeList.add(Types.fighting);
      if (buffs.containsKey(Items.lurePoison)) typeList.add(Types.poison);
      if (buffs.containsKey(Items.lureGround)) typeList.add(Types.ground);
      if (buffs.containsKey(Items.lureFlying)) typeList.add(Types.flying);
      if (buffs.containsKey(Items.lurePsychic)) typeList.add(Types.psychic);
      if (buffs.containsKey(Items.lureBug)) typeList.add(Types.bug);
      if (buffs.containsKey(Items.lureRock)) typeList.add(Types.rock);
      if (buffs.containsKey(Items.lureGhost)) typeList.add(Types.ghost);
      if (buffs.containsKey(Items.lureDragon)) typeList.add(Types.dragon);
      if (buffs.containsKey(Items.lureDark)) typeList.add(Types.dark);
      if (buffs.containsKey(Items.lureSteel)) typeList.add(Types.steel);
      if (buffs.containsKey(Items.lureFairy)) typeList.add(Types.fairy);
    } else if (level == 1) {
      if (buffs.containsKey(Items.superLureNormal)) typeList.add(Types.normal);
      if (buffs.containsKey(Items.superLureFire)) typeList.add(Types.fire);
      if (buffs.containsKey(Items.superLureWater)) typeList.add(Types.water);
      if (buffs.containsKey(Items.superLureElectric)) typeList.add(Types.electric);
      if (buffs.containsKey(Items.superLureGrass)) typeList.add(Types.grass);
      if (buffs.containsKey(Items.superLureIce)) typeList.add(Types.ice);
      if (buffs.containsKey(Items.superLureFighting)) typeList.add(Types.fighting);
      if (buffs.containsKey(Items.superLurePoison)) typeList.add(Types.poison);
      if (buffs.containsKey(Items.superLureGround)) typeList.add(Types.ground);
      if (buffs.containsKey(Items.superLureFlying)) typeList.add(Types.flying);
      if (buffs.containsKey(Items.superLurePsychic)) typeList.add(Types.psychic);
      if (buffs.containsKey(Items.superLureBug)) typeList.add(Types.bug);
      if (buffs.containsKey(Items.superLureRock)) typeList.add(Types.rock);
      if (buffs.containsKey(Items.superLureGhost)) typeList.add(Types.ghost);
      if (buffs.containsKey(Items.superLureDragon)) typeList.add(Types.dragon);
      if (buffs.containsKey(Items.superLureDark)) typeList.add(Types.dark);
      if (buffs.containsKey(Items.superLureSteel)) typeList.add(Types.steel);
      if (buffs.containsKey(Items.superLureFairy)) typeList.add(Types.fairy);
    } else {
      if (buffs.containsKey(Items.maxLureNormal)) typeList.add(Types.normal);
      if (buffs.containsKey(Items.maxLureFire)) typeList.add(Types.fire);
      if (buffs.containsKey(Items.maxLureWater)) typeList.add(Types.water);
      if (buffs.containsKey(Items.maxLureElectric)) typeList.add(Types.electric);
      if (buffs.containsKey(Items.maxLureGrass)) typeList.add(Types.grass);
      if (buffs.containsKey(Items.maxLureIce)) typeList.add(Types.ice);
      if (buffs.containsKey(Items.maxLureFighting)) typeList.add(Types.fighting);
      if (buffs.containsKey(Items.maxLurePoison)) typeList.add(Types.poison);
      if (buffs.containsKey(Items.maxLureGround)) typeList.add(Types.ground);
      if (buffs.containsKey(Items.maxLureFlying)) typeList.add(Types.flying);
      if (buffs.containsKey(Items.maxLurePsychic)) typeList.add(Types.psychic);
      if (buffs.containsKey(Items.maxLureBug)) typeList.add(Types.bug);
      if (buffs.containsKey(Items.maxLureRock)) typeList.add(Types.rock);
      if (buffs.containsKey(Items.maxLureGhost)) typeList.add(Types.ghost);
      if (buffs.containsKey(Items.maxLureDragon)) typeList.add(Types.dragon);
      if (buffs.containsKey(Items.maxLureDark)) typeList.add(Types.dark);
      if (buffs.containsKey(Items.maxLureSteel)) typeList.add(Types.steel);
      if (buffs.containsKey(Items.maxLureFairy)) typeList.add(Types.fairy);
    }
    return typeList;
  }

  int shakeRate(Pokemon mon, Items? berry, Items ball) {
    if (ball.key >= 5 || (berry != null && berry.key > 10)) {
      throw const FormatException('Invalid items.');
    }
    if (ball.key == 4) {
      return 255;
    }
    final Stats bStats = mon.baseStats;
    final int bStatTotal = bStats.atk + bStats.hp + bStats.def + bStats.spAtk + bStats.spDef + bStats.speed;
    num rate = 1.25 * sqrt(mon.catchRate) * pow(10000 / bStatTotal / mon.level, 0.5) + averageLevel() / 2;
    if (berry != null) {
      if (berry.key == 5) {
        rate *= 1.5;
      } else if (berry.key == 7) {
        rate *= 2.25;
      } else if (berry.key == 9) {
        rate *= 4;
      }
    }

    if (ball.key == 2) {
      rate *= 1.5;
    } else if (ball.key == 3) {
      rate *= 2;
    }
    
    return rate.round();
  }

  int averageLevel() {
    if (party.isEmpty) {
      return 0;
    }
    int total = 0;
    for (Pokemon mon in party) {
      total += mon.level;
    }
    return total ~/ party.length;
  }

  bool shakeCheck(int shakeRate) {
    Random random = Random();
    return random.nextInt(256) <= shakeRate;
  }

  void partyAdd(Pokemon mon, Pokemon? toReplace) {
    if (toReplace == null) {
      party.add(mon);
    } else {
      final int index = party.indexOf(toReplace);
      if (index == -1) {
        throw FormatException('Party member to replace not found: ${toReplace.species}.');
      }
      party.removeAt(index);
      party.insert(index, mon);
    }
  }

  Pokemon generateEncounter(List<DexEntry> dex, MovesMapDB movesMap) {
    Random random = Random();
    int levelCeiling = 1;
    for (Pokemon mon in party) {
      if (mon.level > levelCeiling) {
        levelCeiling = mon.level;
      }
    }

    // generating level
    int genLvl = party.isNotEmpty ? random.nextInt(levelCeiling) + 1 : 1;

    final List<Types> lureBuffs = _encounterTypeBuffs(0);
    final List<Types> superBuffs = _encounterTypeBuffs(1);
    final List<Types> maxBuffs = _encounterTypeBuffs(2);

    // generating dex entry
    int key = random.nextInt(dex.length);
    int form = random.nextInt(dex[key].forms.length);
    bool lureBlock = maxBuffs.isNotEmpty || superBuffs.isNotEmpty || lureBuffs.isNotEmpty;
    if (lureBlock) {
      for (Types type in dex[key].forms[form].type) {
        if (maxBuffs.contains(type) || superBuffs.contains(type) || lureBuffs.contains(type)) {
          lureBlock = false;
        }
      }
    }

    while (!dex[key].forms[form].validSpawn || dex[key].minSpawnLvl > genLvl || lureBlock) {
      key = random.nextInt(dex.length);
      form = random.nextInt(dex[key].forms.length);

      if (lureBlock) {
        for (Types type in dex[key].forms[form].type) {
          if (maxBuffs.contains(type) || superBuffs.contains(type) || lureBuffs.contains(type)) {
            lureBlock = false;
          }
        }
        if (lureBlock) {
          if (maxBuffs.isNotEmpty) {
            lureBlock = random.nextInt(2) == 0;
          } else if (superBuffs.isNotEmpty) {
            lureBlock = random.nextInt(3) == 0;
          } else {
            lureBlock = random.nextInt(5) == 0;
          }
        }
      }
    }
    DexEntry targetSpawn = dex[key];

    final double fullId = key + 1 + form * 0.01;
    MonMovesLib? movePool = movesMap.all[fullId];
    movePool ??= MonMovesLib(basePool: [], extendedPool: []);

    // calculating shiny rate
    int shinyTarget = 1;
    if (items.containsKey(Items.shinyCharm)) {
      shinyTarget *= 3;
    }
    bool isShiny = random.nextInt(4096) < shinyTarget;
    
    return Pokemon.fromDexEntry(entry: targetSpawn, form: form, level: genLvl, isShiny: isShiny, ivFloor: 0, movePool: movePool);
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
  int shopItemsBought;
  int blackItemsBought;
  int eggsBought;
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
      shopItemsBought: 0,
      blackItemsBought: 0,
      eggsBought: 0,
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
    required this.shopItemsBought,
    required this.blackItemsBought,
    required this.eggsBought,
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
      case 'uniqueCaught': return uniqueCaught.length;
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
      case 'shopItemsBought': return shopItemsBought;
      case 'blackItemsBought': return blackItemsBought;
      case 'eggsBought': return eggsBought; 
      case 'itemsBought': return itemsBought;
      case 'totalItemsSold': return totalItemsSold;
      case 'itemsSold': return itemsSold;
      case 'lastEvolved': return lastEvolved;
      case 'totalEvolved': return totalEvolved;
      default:
        throw ArgumentError('Field not found: $key');
    }
  }
}