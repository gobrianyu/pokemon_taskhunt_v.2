enum Stat {
  hp(),
  atk(),
  def(),
  spAtk(),
  spDef(),
  speed(),
  accuracy();

  const Stat();

  List<Stat> get allStats {
    return [
      Stat.hp,
      Stat.atk,
      Stat.def,
      Stat.spAtk,
      Stat.spDef,
      Stat.speed,
      Stat.accuracy,
    ];
  }
}