enum Effect {
  highCrit(),
  doubleHit(),
  tripleHit(),
  multiHit(),

  // Status effects
  burn(),
  freeze(),
  paralysis(),
  flinch(),  // no corresponding StatusEffect enum; treated separately TODO
  poison(),
  poison2(),
  sleep(),
  drowsy(),
  confusion(),
  damageOverTime(),

  wake(),

  invalid();

  const Effect();

  static Effect lookup(String name) {
    return Effect.values.firstWhere(
      (eff) => eff.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Effect.invalid,
    );
  }
}

class MoveEffect {
  static List<int> altMoveIds = [

  ];

  final Effect effect;
  final bool targetSelf;
  final bool targetOpp;
  final bool alt;  // alternate form (e.g. Population Bomb multihit vs generic multhit)

  MoveEffect({
    required this.effect,
    required this.targetSelf,
    required this.targetOpp,
    required this.alt,
  });

  static MoveEffect lookup(String name) {
    Effect effect = Effect.values.firstWhere(
      (eff) => eff.name.toLowerCase() == name.toLowerCase(),
      orElse: () => deepLookup(name)
    );
    return MoveEffect(effect: effect, targetSelf: true, targetOpp: false, alt: false);
  }

  static Effect deepLookup(String name) {
    if (name.substring(0, 3) == 'opp') {
      return Effect.lookup(name.substring(3));
    }
    return Effect.invalid;
  }
}