import 'package:pokemon_taskhunt_2/enums/move_effects.dart';

enum StatusEffect {
  clear(true),
  burn(false),
  freeze(false),
  paralysis(false),
  poison(false),
  poison2(false),
  sleep(false),
  drowsy(true),
  bound(true),
  confusion(true);

  const StatusEffect(this.volatile);
  final bool volatile;

  StatusEffect convertFromME(MoveEffect effect) {
    switch (effect.effect) {
      case Effect.burn: return StatusEffect.burn;
      case Effect.freeze: return StatusEffect.freeze;
      case Effect.paralysis: return StatusEffect.paralysis;
      case Effect.poison:
        if (effect.alt) return StatusEffect.poison2;
        return StatusEffect.poison;
      case Effect.sleep: return StatusEffect.sleep;
      case Effect.drowsy: return StatusEffect.drowsy;
      case Effect.damageOverTime: return StatusEffect.bound;
      case Effect.confusion: return StatusEffect.confusion;

      default: return StatusEffect.clear;
    }
  }
}