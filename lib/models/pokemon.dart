import 'dart:math';

import 'package:pokemon_taskhunt_2/models/dex_entry.dart';
import 'package:pokemon_taskhunt_2/models/regions.dart';
import 'package:pokemon_taskhunt_2/models/types.dart';

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
  final List<Evolutions> evolutions;
  final List<Types> types;
  final Regions region;
  final Stats baseStats;
  final Stats ivs;
  final String imageAsset;
  final bool isShiny;
  int friendship;


  factory Pokemon(int level, bool isShiny) {
    return Pokemon.fromDexEntry(entry, 1, level, isShiny);
  }

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
      evolutions: entry.forms[form].evolutions, 
      types: entry.forms[form].type,
      region: entry.forms[form].region,
      baseStats: entry.forms[form].stats,
      ivs: _generateIVs(ivFloor, random),
      imageAsset: imageAsset,
      isShiny: isShiny, 
      key: entry.forms[form].key, 
      species: species,
      friendship: 0,
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
  });

  void incrementExp(int amount) {
    exp += amount;
    updateLevel();
  }

  void updateLevel() {
    
  }

  int nextExpCap() {
    return 1;
  }

  void checkEvoEligibility() {

  }

  Stats getStats() {
    return Stats(hp: 0, atk: 0, def: 0, spAtk: 0, spDef: 0, speed: 0);
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
    throw FormatException('Invalid input: ($level). Pokémon levels must be between 1 and 100 inclusive.');
  }
  if (cat.toLowerCase() == 'fast') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 4 / 5 + 0.5).round();
  } else if (cat.toLowerCase() == 'medium fast') {
    return (pow(level + 1, 3) - pow(level, 3)).round();
  } else if (cat.toLowerCase() == 'medium slow') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 6 / 5 - (pow(level + 1, 2) - pow(level, 2)) * 15 + 100 + 0.5).round();
  } else if (cat.toLowerCase() == 'slow') {
    return ((pow(level + 1, 3) - pow(level, 3)) * 5 / 4 + 0.5).round();
  } else if (cat.toLowerCase() == 'erratic') {
    if (level < 50) {

    } else if (level < 68) {
      
    } else if (level < 98) {

    } else {
      //2n^3 - 1/50 n^4
      return ((pow(level + 1, 3) - pow(level, 3) * 2) - (pow(level + 1, 4) - pow(level, 4)) / 50 + 0.5).round();
    }
  } else if (cat.toLowerCase() == 'fluctuating') {

  }
  throw FormatException('Invalid input: unrecognized Pokémon experience group provided: $cat');
}