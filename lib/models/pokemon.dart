import 'dart:math';

import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';
import 'package:pokemon_taskhunt_2/models/moves_map_db.dart';
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';

class Pokemon {
  final Random random = Random();
  final num key;
  String nickname;
  final String species;
  final String speciesExtended;
  int level;
  int exp;
  int move1Id;
  int? move2Id;
  final MonMovesLib movePool;
  final double height;
  final double weight;
  final String expGroup;
  final int baseExpYield;
  final int gender; // -1 - none/unknown, 0 - male, 1 - female
  final num catchRate;
  final num fleeRate;
  final Evolutions evolutions;
  final List<Types> types;
  final Regions region;
  final Stats baseStats;
  final Stats ivs;
  final String imageAsset;
  final bool isShiny;
  int battles;
  int friendship;
  Items? heldItem;

  void setName(String name) {
    nickname = name;
  }

  factory Pokemon.fromDexEntry({
    required DexEntry entry,
    required int form,
    required int level,
    required bool isShiny,
    required int ivFloor,
    required MonMovesLib movePool
  }) {
    final String species = entry.forms[form].name;
    final String speciesExtended = entry.forms[form].specialForm ?? species;
    final Random random = Random(); 
    int gender = -1;
    if (entry.genderKnown) {
      if (entry.genderRatio! == 100) {
        gender = 0;
      } else {
        gender = random.nextInt((entry.genderRatio! * 100 + 100).round()) > 100 ? 0 : 1; // i.e. 0.33 => 1 : 3 (mf)
      }
    }

    String imageAsset;
    if (isShiny) {
      if (gender == 1) {
        imageAsset = entry.forms[form].imageAssetFShiny;
      } else {
        imageAsset = entry.forms[form].imageAssetMShiny;
      }
    } else {
      if (gender == 1) {
        imageAsset = entry.forms[form].imageAssetF;
      } else {
        imageAsset = entry.forms[form].imageAssetM;
      }
    }

    int move1Id = _generateMove1(movePool, random);
    int? move2Id;
    if (random.nextInt(256) <= level && movePool.basePool.length > 1) {
      move2Id = _generateMove2(movePool, random, move1Id);
    }

    return Pokemon.withFields(
      speciesExtended: speciesExtended,
      exp: 0,
      level: level,
      nickname: species,
      expGroup: entry.expGroup, 
      baseExpYield: entry.expYield,
      height: entry.forms[form].height,
      weight: entry.forms[form].weight,
      move1Id: move1Id,
      move2Id: move2Id,
      movePool: movePool,
      gender: gender,
      catchRate: entry.catchRate,
      fleeRate: entry.fleeRate, 
      evolutions: entry.forms[form].evolutions[0], 
      types: entry.forms[form].type,
      region: entry.forms[form].region,
      baseStats: entry.forms[form].stats[0],
      ivs: _generateIVs(ivFloor, random),
      imageAsset: imageAsset,
      isShiny: isShiny, 
      key: entry.forms[form].key, 
      species: species,
      friendship: 0,
      battles: 0,
      heldItem: _generateHeldItem()
    );
  }

  Pokemon.withFields({
    required this.speciesExtended,
    required this.nickname,
    required this.exp, 
    required this.level, 
    required this.expGroup,
    required this.height,
    required this.weight,
    required this.move1Id,
    this.move2Id,
    required this.movePool,
    required this.baseExpYield, 
    required this.gender, 
    required this.catchRate, 
    required this.fleeRate, 
    required this.evolutions, 
    required this.types, 
    required this.region, 
    required this.baseStats, 
    required this.ivs,
    required this.imageAsset, 
    required this.isShiny, 
    required this.key, 
    required this.species,
    required this.friendship,
    required this.battles,
    this.heldItem
  });

  int getNumStars() {
    int total = ivs.atk + ivs.def + ivs.hp + ivs.speed + ivs.spAtk + ivs.spDef;
    switch (total) {
      case < 23: return 0;
      case >= 23 && < 45: return 1;
      case >= 45 && < 68: return 2;
      case >= 68 && < 90: return 3;
      case 90: return 4;
      default: return 0;  // should be impossible
    }
  }

  void incrementExp(int amount) {
    exp += amount;
    _updateLevel();
  }

  void _updateLevel() {
    int cap = _getNextExpCap(level, expGroup);
    if (exp >= cap) {
      level++;
      exp -= cap;
      _updateLevel();
    }
  }

  List<Move> getMoves(MovesDB movesDB) {
    List<Move> moves = [movesDB.getById(move1Id)];
    if (move2Id != null) {
      moves.add(movesDB.getById(move2Id!));
    }
    return moves;
  }

  int nextExpCap() {
    return _getNextExpCap(level, expGroup);
  }

  int totalExp() {
    int totalExp = 0;
    for (int i = 1; i <= level - 1; i++) {
      totalExp += _getNextExpCap(i, expGroup);
    }
    return totalExp + exp;
  }

  // TODO:
  List<double> checkEvoEligibility(AccountProvider account, Items? item) {
    final List<double> eligibleEvos = [];
    if (evolutions.next.isNotEmpty) {
      final evoClone = List.from(evolutions.next);
      for (NextEvo evo in evoClone) {
        if (evo.level != null && evo.level! <= level) {
          if (evo.item.isEmpty) {
            eligibleEvos.add(evo.key);
          } else {
            List<String> removeables = ['random'];
            if (heldItem != null) removeables.add(heldItem!.name.toLowerCase());
            account.darkMode ? removeables.add('dark mode') : removeables.add('light mode');
            if (friendship == 10) removeables.add('friendship');
            if (battles == 20) removeables.add('battle');
            if (account.blitzGame.slate != null) removeables.add('${account.blitzGame.slate!.name} slate'.toLowerCase());

            evo.item.removeWhere((e) => removeables.contains(e.toLowerCase()));

            if (item == null && evo.item.isEmpty) {
              eligibleEvos.add(evo.key);
            } else if (item != null && evo.item.any((e) => e.toLowerCase() == item.name.toLowerCase())) {
              if (evo.item.isEmpty) eligibleEvos.add(evo.key);
            }           
          }
        }
      }
    }
    return eligibleEvos;
  }

  Pokemon evolve(DexEntry entry, int form, MonMovesLib movePool) {
    final String speciesEvo = entry.forms[form].name;
    final String speciesExtendedEvo = entry.forms[form].specialForm ?? species;

    String imageAssetEvo;
    if (isShiny) {
      if (gender == 1) {
        imageAssetEvo = entry.forms[form].imageAssetFShiny;
      } else {
        imageAssetEvo = entry.forms[form].imageAssetMShiny;
      }
    } else {
      if (gender == 1) {
        imageAssetEvo = entry.forms[form].imageAssetF;
      } else {
        imageAssetEvo = entry.forms[form].imageAssetM;
      }
    }
    
    return Pokemon.withFields(
      speciesExtended: speciesExtendedEvo,
      nickname: nickname,
      exp: exp,
      level: level,
      expGroup: entry.expGroup,
      baseExpYield: entry.expYield,
      height: entry.forms[form].height,
      weight: entry.forms[form].weight,
      move1Id: move1Id,
      move2Id: move2Id,
      movePool: movePool,
      gender: gender,
      catchRate: entry.catchRate,
      fleeRate: entry.fleeRate,
      evolutions: entry.forms[form].evolutions[0],
      types: entry.forms[form].type,
      region: entry.forms[form].region,
      baseStats: entry.forms[form].stats[0],
      ivs: ivs,
      imageAsset: imageAssetEvo,
      isShiny: isShiny,
      key: entry.forms[form].key,
      species: speciesEvo,
      friendship: friendship,
      battles: battles
    );
  }

  void unlockSecondMove() {
    if (move2Id == null) {
      MovesDB movesDB = MovesDB();
      int moveId;
      if (movesDB.getById(move1Id).category.toLowerCase() == 'status') {
        moveId = _generateMove1(movePool, random);
      } else {
        moveId = _generateMove2(movePool, random, move1Id);
      }
      setMove2Id(moveId);
    }
  }

  void setMove2Id(int moveId) {
    move2Id = moveId;
  }

  int calcHP([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.hp + ivs.hp) * 2 + trueBaseCalc) * level / 100).floor() + level + 10;
  }

  int calcAtk([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.atk + ivs.atk) * 2 + trueBaseCalc) * level / 100).floor() + 5;
  }
  
  int calcDef([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.def + ivs.def) * 2 + trueBaseCalc) * level / 100).floor() + 5;
  }

  int calcSpAtk([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.spAtk + ivs.spAtk) * 2 + trueBaseCalc) * level / 100).floor() + 5;
  }

  int calcSpDef([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.spDef + ivs.spDef) * 2 + trueBaseCalc) * level / 100).floor() + 5;
  }

  int calcSpeed([int? baseCalc]) {
    int trueBaseCalc;
    if (baseCalc != null) {
      trueBaseCalc = baseCalc;
    } else {
      trueBaseCalc = _calcBaseCalc();
    }
    return (((baseStats.speed + ivs.speed) * 2 + trueBaseCalc) * level / 100).floor() + 5;
  }

  int _calcBaseCalc() {
    int statExp = min(_getNextExpCap(level - 1, expGroup) + exp, 65535);
    return (sqrt(statExp).ceil() / 4).floor();
  }

  Stats getStats() {
    final int baseCalc = _calcBaseCalc();
    final int hp = calcHP(baseCalc);
    final int atk = calcAtk(baseCalc);
    final int def = calcDef(baseCalc);
    final int spAtk = calcSpAtk(baseCalc);
    final int spDef = calcSpDef(baseCalc);
    final int speed = calcSpeed(baseCalc);
    return Stats(hp: hp, atk: atk, def: def, spAtk: spAtk, spDef: spDef, speed: speed);
  }

  Stats maxStats() {
    final int hp = ((baseStats.hp + 15) * 2 + 64) + level + 10;
    final int atk = ((baseStats.atk + 15) * 2 + 64) + 5;
    final int def = ((baseStats.def  + 15) * 2 + 64) + 5;
    final int spAtk = ((baseStats.spAtk + 15) * 2 + 64) + 5;
    final int spDef = ((baseStats.spDef + 15) * 2 + 64) + 5;
    final int speed = ((baseStats.speed + 15) * 2 + 64) + 5;
    return Stats(hp: hp, atk: atk, def: def, spAtk: spAtk, spDef: spDef, speed: speed);
  }
}

class Egg {
  final String imageAsset;
  final String eggType;
  final int rarity;
  final int shinyRate;
  final int hatchCount;
  int hatchCounter = 0;
  Pokemon? mon;
  
  Egg({required this.imageAsset, required this.eggType, required this.rarity, required this.shinyRate, required this.hatchCount, this.mon});

  bool incrementCounter() {
    hatchCounter++;
    return hatchCount <= hatchCounter;
  }
}

Stats _generateIVs(int floor, Random random) {
  if (floor > 15) floor = 15;
  if (floor < 0) floor = 0;
  return Stats(
    hp: random.nextInt(16 - floor) + floor,
    atk: random.nextInt(16 - floor) + floor,
    def: random.nextInt(16 - floor) + floor,
    spAtk: random.nextInt(16 - floor) + floor,
    spDef: random.nextInt(16 - floor) + floor,
    speed: random.nextInt(16 - floor) + floor
  );
}

int _generateMove1(MonMovesLib moveLib, Random rand) {
  List<int> pool = moveLib.nonStatusBasePool;
  if (pool.isEmpty) {
    pool = moveLib.basePool; 
  }
  int index = rand.nextInt(pool.length);
  return pool[index];
}

int _generateMove2(MonMovesLib moveLib, Random rand, int move1Id) {
  int index = rand.nextInt(moveLib.basePool.length);
  int move2Id = moveLib.basePool[index];
  if (move2Id == move1Id) {
    index++;
    index = index % moveLib.basePool.length;
    move2Id = moveLib.basePool[index];
  }
  return move2Id;
}

int _getNextExpCap(int level, String cat) {
  if (level < 0 || level > 100) {
    throw FormatException('Invalid input: ($level). Pokémon levels must be between 0 and 100 inclusive.');
  }
  if (cat.toLowerCase() == 'fast') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 4 / 5).round();
  } else if (cat.toLowerCase() == 'medium fast') {
    return (pow(level + 1, 3) - pow(level, 3)).round();
  } else if (cat.toLowerCase() == 'medium slow') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 6 / 5 - (pow(level + 1, 2) - pow(level, 2)) * 15 + 100).round();
  } else if (cat.toLowerCase() == 'slow') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 5 / 4).round();
  } else if (cat.toLowerCase() == 'erratic') {
    if (level < 50) {
      return ((pow(level + 1, 3) - pow(level, 3) * 2) - (pow(level + 1, 4) - pow(level, 4)) / 50).round();
    } else if (level < 68) {
      return ((pow(level + 1, 3) - pow(level, 3) * 3 / 2) - (pow(level + 1, 4) - pow(level, 4)) / 100).round();
    } else if (level < 98) {
      return (((1911 - 10 * (level + 1)) ~/ 3 * pow(level + 1, 3) - (1911 - 10 * level) ~/ 3 * pow(level, 3)) / 500).round();
    } else {
      return ((pow(level + 1, 3) - pow(level, 3) * 8 / 5) - (pow(level + 1, 4) - pow(level, 4)) / 100).round();
    }
  } else if (cat.toLowerCase() == 'fluctuating') {
    if (level < 15) {
      return ((((level + 2) ~/ 3 + 24) * pow(level + 1, 3) - ((level + 1) ~/ 3 + 24) * pow(level, 3)) / 50).round();
    } else if (level < 36) {
      return ((pow(level + 1, 3) * (level + 15) - pow(level, 3) * (level + 14)) / 50).round();
    } else {
      return ((((level + 1) ~/ 2 + 32) * pow(level + 1, 3) - (level ~/ 2 + 32) * pow(level, 3)) / 50).round();
    }
  }
  throw FormatException('Invalid input: unrecognized Pokémon experience group provided: $cat');
}

Items? _generateHeldItem() {
  //TODO: implement
  return null;
}