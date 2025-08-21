import 'dart:collection';
import 'dart:math';

import 'package:pokemon_taskhunt_2/enums/move_effects.dart';
import 'package:pokemon_taskhunt_2/enums/stats.dart';
import 'package:pokemon_taskhunt_2/enums/status_effects.dart';
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';
import 'package:pokemon_taskhunt_2/enums/types.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';

class BattlePokemon {
  final Pokemon mon;
  int remainingHP;
  StatusEffect nvStatusEffect;
  List<StatusEffect> vStatusEffects;
  BattleBuffs buffs;

  BattlePokemon({
    required this.mon,
    required this.remainingHP,
    required this.nvStatusEffect,
    required this.vStatusEffects,
    required this.buffs
  });

  factory BattlePokemon.initFromMon(Pokemon mon) {
    return BattlePokemon(
      mon: mon,
      remainingHP: mon.calcStat(Stat.hp),
      nvStatusEffect: StatusEffect.clear,
      vStatusEffects: [],
      buffs: BattleBuffs.init()
    );
  }

  double calcEffStat(Stat stat) {
    double multiplier = _getMultiplier(stat);

    if (stat == Stat.accuracy || stat == Stat.critRate) return multiplier;

    // check paralysis: if paralysed, apply 0.5x speed multiplier
    if (nvStatusEffect == StatusEffect.paralysis && stat == Stat.speed) multiplier *= 0.5;

    return (mon.calcStat(stat) * multiplier);
  }

  bool clearNvStatusEffect() {
    if (nvStatusEffect == StatusEffect.clear) return false;
    nvStatusEffect = StatusEffect.clear;
    return true;
  }

  bool applyNvStatusEffect(StatusEffect effect) {
    if (nvStatusEffect != StatusEffect.clear || !effect.volatile) return false;
    nvStatusEffect = effect;
    return true;
  }

  double _getMultiplier(Stat stat) {
    int stage = buffs.getStatStage(stat);
    if (stage == 0) return 1;
    if (stat == Stat.accuracy) {
      if (stage > 0) {
        return (stage + 3) / 3;
      } else {
        return 3 / (stage.abs() + 3);
      }
    }
    if (stage > 0) {
      return (stage + 2) / 2;
    } else {
      return 2 / (stage.abs() + 2);
    }
  }
}

class BattleState {
  final BattlePokemon self;
  final BattlePokemon opp;

  Random rand = Random();
  MovesDB movesDB = MovesDB();

  BattleState({
    required this.opp,
    required this.self,
  });
  

  Queue<BattleAction> getActions(Move selfMove) {
    Move oppMove = _getOppMove();
    BattleAction monAction = BattleAction(
      move: selfMove,
      attacker: self,
      defender: opp,
    );
    BattleAction oppAction = BattleAction(
      move: oppMove,
      attacker: opp,
      defender: self,
    );

    Queue<BattleAction> actions = Queue();

    // TODO: consider held items
    if (selfMove.priority == oppMove.priority) {
      int monSpeed = self.calcEffStat(Stat.speed).floor();
      int oppSpeed = opp.calcEffStat(Stat.speed).floor();
      if (monSpeed >= oppSpeed || monSpeed == oppSpeed && rand.nextInt(2) > 0) {
        actions.add(monAction);
        actions.add(oppAction);
      } else {
        actions.add(oppAction);
        actions.add(monAction);
      }
    } else if (selfMove.priority > oppMove.priority) {
      actions.add(monAction);
      actions.add(oppAction);
    } else {
      actions.add(oppAction);
      actions.add(monAction);
    }

    return actions;
  }

  
  int evalNumHits(BattleAction action) {
    int numHits = 1;
    
    int lowerBound = 1;
    int upperBound = 1;
    List<MoveEffect> effects = action.move.effect;
    if (effects.any((me) => (me.effect == Effect.multiHit && me.alt))) {
      upperBound = 10;
    } else if (effects.any((me) => (me.effect == Effect.tripleHit && me.alt))) {
      upperBound = 3;
    } else if (effects.any((me) => (me.effect == Effect.multiHit && !me.alt))) {
      int n = rand.nextInt(20);
      switch (n) {
        case < 7: return 2;
        case < 14: return 3;
        case < 17: return 4;
        default: return 5;
      }
    } else if (effects.any((me) => (me.effect == Effect.tripleHit && !me.alt))) {
      return 3;
    } else if (effects.any((me) => (me.effect == Effect.doubleHit && !me.alt))) {
      return 2;
    } else {
      return 1;
    }
    for (int i = lowerBound; i < upperBound; i++) {
      if (!evalHit(action.move, action.attacker)) break;
      numHits++; 
    }
    return numHits;
  }

  
  void doAction(BattleAction action) {
    Move move = action.move;
    int numHits = evalNumHits(action);
    
    if (evalHit(move, action.attacker)) {
      for (int i = 1; i <= numHits; i++) {
        double powerMultiplier = 1.0;
        if (move.effect.any((me) => (me.effect == Effect.tripleHit && me.alt))) {
          powerMultiplier *= i;
        }
        int dmg = calcTrueDmg(action.attacker, action.defender, move, powerMultiplier, rand);
        action.defender.remainingHP -= dmg;
        applyMoveEffects(move, action.attacker, action.defender);
      }
      
      // calculate damage
      // inflict damage
      // check for effects
      // check if effects hit (accuracy)
      // inflict effects
    } else {

    }
  }

  void applyMoveEffects(Move move, BattlePokemon attacker, BattlePokemon defender) {
    List<MoveEffect> effects = move.effect;
    for (MoveEffect effect in effects) {
      double rate = move.probability ?? 100;
      if (rand.nextInt(100) < rate) {
        if (effect.targetSelf) {

        }
      } 
    }
  }

  // Evaluates whether a battle action will be successful. Evaluates to true if yes, otherwise false.
  // Note: Evasion stats are not present in calculations
  bool evalHit(Move move, BattlePokemon user) {
    // check paralysis
    if (user.nvStatusEffect == StatusEffect.paralysis) {
      if (rand.nextInt(4) == 0) return false;  // 25% chance of full-paralysis
    }
    double attackerAccuracy = user.calcEffStat(Stat.accuracy);
    if (move.accuracy == null || move.accuracy == 65536) return true;
    int actualAccuracy = (move.accuracy! * attackerAccuracy).floor();
    if (actualAccuracy >= 100) return true;
    return rand.nextInt(100) < actualAccuracy;
  }

  bool inflictOppStatus() {
    return true;
  }

  int inflictSelfBuff(Stat stat, int strength) {
    int prevStage = self.buffs.getStatStage(stat);
    self.buffs.addBuff(stat, strength);
    return self.buffs.getStatStage(stat) - prevStage;
  }

  int inflictOppBuff(Stat stat, int strength) {
    int prevStage = opp.buffs.getStatStage(stat);
    opp.buffs.addBuff(stat, strength);
    return self.buffs.getStatStage(stat) - prevStage;
  }

  

  // Selects opponent's move for present the turn using rough calculations for expected damage in the immediate turn.
  Move _getOppMove() {
    Move move1 = movesDB.getById(opp.mon.move1Id);
    if (opp.mon.move2Id != null) {
      Move move2 = movesDB.getById(opp.mon.move2Id!);

      double move1Multiplier = _getRoughPowerMultiplier(move1);
      double move2Multiplier = _getRoughPowerMultiplier(move2);
      
      double move1Dmg = calcDmgRough(opp, self, move1, move1Multiplier, false);
      double critMove1Dmg = calcDmgRough(opp, self, move1, move2Multiplier, true);

      double move2Dmg = calcDmgRough(opp, self, move2, move1Multiplier, false);
      double critMove2Dmg = calcDmgRough(opp, self, move2, move2Multiplier, true);

      double move1CritChance = critChance(opp, move1);
      double move2CritChance = critChance(opp, move2);

      double weightedMove1Dmg = move1CritChance * critMove1Dmg + (1 - move1CritChance) * move1Dmg;
      double weightedMove2Dmg = move2CritChance * critMove2Dmg + (1 - move2CritChance) * move2Dmg;

      if (weightedMove2Dmg > weightedMove1Dmg || (weightedMove2Dmg == weightedMove1Dmg && rand.nextInt(2) > 0)) return move2;
    }
    return move1;
  }

  double _getRoughPowerMultiplier(Move move) {
    List<MoveEffect> effects = move.effect;
    if (effects.any((me) => (me.effect == Effect.multiHit && me.alt))) {
      return 5.862;
    } else if (effects.any((me) => (me.effect == Effect.tripleHit && me.alt))) {
      return 4.707;
    } else if (effects.any((me) => (me.effect == Effect.multiHit && !me.alt))) {
      return 3.1;
    } else if (effects.any((me) => (me.effect == Effect.tripleHit && !me.alt))) {
      return 3.0;
    } else if (effects.any((me) => (me.effect == Effect.doubleHit && !me.alt))) {
      return 2.0;
    }
    return 1.0;
  }

  void endTurn() {
    
  }
}



class BattleAction {
  Move move;
  final BattlePokemon defender;
  final BattlePokemon attacker;

  BattleAction({
    required this.move,
    required this.defender,
    required this.attacker,
  });
}



class BattleBuffs {
  final Map<Stat, int> buffs;

  BattleBuffs({
    required this.buffs
  });

  factory BattleBuffs.init() {
    return BattleBuffs(
      buffs: {
        Stat.hp: 0,
        Stat.atk: 0,
        Stat.def: 0,
        Stat.spAtk: 0,
        Stat.spDef: 0,
        Stat.speed: 0,
        Stat.accuracy: 0,
        Stat.critRate: 0,
      }
    );
  }

  int getStatStage(Stat stat) {
    return buffs[stat] ?? 0;
  }

  void addBuff(Stat stat, int strength) {
    buffs.update(stat, (value) {
      if (stat == Stat.critRate) return (value + strength).clamp(0, 3);
      return (value + strength).clamp(-6, 6);
    }, ifAbsent: () => strength);
  }
}



double calcEffectiveness(Types atkType, List<Types> defTypes) {
  double multiplier = 1;
  for (Types type in defTypes) {
    if (type.immunities.contains(atkType)) return 0;
    if (type.weaknesses.contains(atkType)) {
      multiplier *= 2;
    } else if (type.resistances.contains(atkType)) {
      multiplier /= 2;
    }
  }
  return multiplier;
}


int calcTrueDmg(BattlePokemon attacker, BattlePokemon defender, Move move, double powerMultiplier, Random rand) {
  // apply crit multiplier
  double crit = 1.0;
  
  bool isCrit = evalCrit(attacker, move, rand);
  if (isCrit) {
    crit = 1.5;
  }

  double random = (rand.nextInt(16) + 85) / 100;
  
  return (calcDmgRough(attacker, defender, move, powerMultiplier, isCrit) * crit * random).floor();
}



bool evalCrit(BattlePokemon battleMon, Move move, Random rand) {
  double prob = critChance(battleMon, move);
  return rand.nextInt(1000) < (prob * 1000).round();
}

double critChance(BattlePokemon battleMon, Move move) {
  int stage = battleMon.buffs.getStatStage(Stat.critRate);
  if (move.effect.any((me) => me.effect == Effect.highCrit)) {
    if (move.probability == 100) return 1.0;
    stage++;
  }
  double prob = 1/24;
  switch(stage) {
    case 1: prob = 1/8;
    case 2: prob = 1/2;
    case >= 3: prob = 1;
  }
  // TODO: case of high-crit chance move
  return prob;
}

double calcDmgRough(BattlePokemon attacker, BattlePokemon defender, Move move, double powerMultiplier, bool isCrit) {
  if (move.power == null || move.power == 0 || move.category.toLowerCase() == 'status') {
    return 0;
  }

  double effectiveness = calcEffectiveness(move.type, defender.mon.types);
  if (effectiveness == 0) return 0;

  int defStat;
  int atkStat;
  double burn = 1.0;
  if (move.category.toLowerCase() == 'physical') {
    defStat = defender.calcEffStat(Stat.def).floor();
    atkStat = attacker.calcEffStat(Stat.atk).floor();
    if (isCrit) {
      defStat = min(defStat, defender.mon.calcStat(Stat.def));
      atkStat = max(atkStat, attacker.mon.calcStat(Stat.atk));
    }
    if (attacker.nvStatusEffect == StatusEffect.burn) burn = 0.5;
  } else {
    defStat = defender.calcEffStat(Stat.spDef).floor();
    atkStat = attacker.calcEffStat(Stat.spAtk).floor();
    if (isCrit) {
      defStat = min(defStat, defender.mon.calcStat(Stat.spDef));
      atkStat = max(atkStat, attacker.mon.calcStat(Stat.spAtk));
    }
  }

  double stab = 1;
  if (attacker.mon.types.contains(move.type)) stab = 1.5;

  return (((2 * attacker.mon.level) / 5 + 2) * move.power! * powerMultiplier * atkStat / defStat / 50 + 2) * stab * effectiveness * burn;
}
