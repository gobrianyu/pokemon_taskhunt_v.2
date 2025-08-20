import 'dart:collection';
import 'dart:math';

import 'package:pokemon_taskhunt_2/enums/stats.dart';
import 'package:pokemon_taskhunt_2/models/move.dart';
import 'package:pokemon_taskhunt_2/models/moves_db.dart';
import 'package:pokemon_taskhunt_2/enums/types.dart';
import 'package:pokemon_taskhunt_2/models/pokemon.dart';

class BattlePokemon {
  final Pokemon mon;
  int remainingHP;
  List statusEffects;
  BattleBuffs buffs;

  BattlePokemon({
    required this.mon,
    required this.remainingHP,
    required this.statusEffects,
    required this.buffs
  });

  factory BattlePokemon.initFromMon(Pokemon mon) {
    return BattlePokemon(
      mon: mon,
      remainingHP: mon.calcHP(),
      statusEffects: [],
      buffs: BattleBuffs.init()
    );
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
  

  Queue<BattleAction> getTurn(Move selfMove) {
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
      int monSpeed = _calcSpeed(self.mon);
      int oppSpeed = _calcSpeed(opp.mon);
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

  
  void doAction(BattleAction action) {

  }

  bool inflictStatus() {
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

  int _calcSpeed(Pokemon mon) {
    double multiplier = _getMultipler(mon, Stat.speed);
    return (mon.calcSpeed() * multiplier).floor();
  }

  double _getMultipler(Pokemon mon, Stat stat) {
    BattleBuffs buffPool;
    if (mon == self.mon) {
      buffPool = self.buffs;
    } else {
      buffPool = opp.buffs;
    }
    int stage = buffPool.getStatStage(stat);
    if (stage == 0) return 1;
    if (stage > 0) {
      return (stage + 2) / 2;
    } else {
      return 2 / (stage.abs() + 2);
    }
  }

  // Selects opponent's move for present the turn.
  Move _getOppMove() {
    Move move1 = movesDB.getById(opp.mon.move1Id);
    if (opp.mon.move2Id != null) {
      Move move2 = movesDB.getById(opp.mon.move2Id!);
      int move1Power = calcDmgRough(opp, self, move1);
      int move2Power = calcDmgRough(opp, self, move2);
      if (move2Power > move1Power || (move2Power == move1Power && rand.nextInt(2) > 0)) return move2;
    }
    return move1;
  }

  void endTurn() {
    // for (BattleBuff buff in self.buffs) {
    //   buff.decrementDuration();
    //   if (buff.duration == 0) {
    //     opp.buffs.remove(buff);
    //   }
    // }
    // for (BattleBuff buff in opp.buffs) {
    //   buff.decrementDuration();
    //   if (buff.duration == 0) {
    //     opp.buffs.remove(buff);
    //   }
    // }
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
      }
    );
  }

  int getStatStage(Stat stat) {
    return buffs[stat] ?? 0;
  }

  void addBuff(Stat stat, int strength) {
    buffs.update(stat, (value) => (value + strength).clamp(-6, 6), ifAbsent: () => strength);
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


int calcDmgRough(BattlePokemon attacker, BattlePokemon defender, Move move) {
  if (move.power == null || move.power == 0 || move.category.toLowerCase() == 'status') {
    return 0;
  }

  double effectiveness = calcEffectiveness(move.type, defender.mon.types);
  if (effectiveness == 0) return 0;

  int defStat;
  int atkStat;
  double burn = 1;
  if (move.category.toLowerCase() == 'physical') {
    defStat = defender.mon.calcDef();
    atkStat = attacker.mon.calcAtk();
    if (attacker.statusEffects.contains('burn')) burn = 0.5;
  } else {
    defStat = defender.mon.calcSpDef();
    atkStat = attacker.mon.calcSpAtk();
  }

  double stab = 1;
  if (attacker.mon.types.contains(move.type)) stab = 1.5;

  return ((((2 * attacker.mon.level) / 5 + 2) * move.power! * atkStat / defStat / 50 + 2) * stab * effectiveness * burn).floor();
}
