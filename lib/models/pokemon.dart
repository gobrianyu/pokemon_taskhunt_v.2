import 'dart:math';

import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/items.dart';
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';
import 'package:pokemon_taskhunt_2/providers/account_provider.dart';

class Pokemon {
  final num key;
  final String species;
  final String speciesExtended;
  int level;
  int exp;
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

  factory Pokemon.fromDexEntry(DexEntry entry, int form, int level, bool isShiny, int ivFloor) {
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

    return Pokemon.withFields(
      speciesExtended: speciesExtended,
      exp: 0,
      level: level, 
      expGroup: entry.expGroup, 
      baseExpYield: entry.expYield, 
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
    required this.exp, 
    required this.level, 
    required this.expGroup, 
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

  Pokemon evolve(DexEntry entry, int form) {
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
      exp: exp,
      level: level,
      expGroup: entry.expGroup,
      baseExpYield: entry.expYield,
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

  Stats getStats() {
    final num statExp = min(_getNextExpCap(level - 1, expGroup) + exp, 65535);
    final int baseCalc = (sqrt(statExp).ceil() / 4).floor();
    final int hp = (((baseStats.hp + ivs.hp) * 2 + baseCalc) * level / 100).floor() + level + 10;
    final int atk = (((baseStats.atk + ivs.atk) * 2 + baseCalc) * level / 100).floor() + 5;
    final int def = (((baseStats.def + ivs.def) * 2 + baseCalc) * level / 100).floor() + 5;
    final int spAtk = (((baseStats.spAtk + ivs.spAtk) * 2 + baseCalc) * level / 100).floor() + 5;
    final int spDef = (((baseStats.spDef + ivs.spDef) * 2 + baseCalc) * level / 100).floor() + 5;
    final int speed = (((baseStats.speed + ivs.speed) * 2 + baseCalc) * level / 100).floor() + 5;
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