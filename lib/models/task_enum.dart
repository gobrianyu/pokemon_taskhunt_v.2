// DEPRECATED FILE - UNUSED

enum TaskEnum {
  earnExpTotal(1, 6, [1000, 1000, 3000, 3000, 10000, 10000, 30000, 30000, 100000, 100000, 1000000, 1000000], 'totalExpEarned', null),
  earnExpBattle(1, 6, [1000, 1000, 3000, 3000, 10000, 10000, 30000, 30000, 100000, 100000, 1000000, 1000000], 'battleExpEarned', null),
  earnExpCatch(1, 6, [], 'catchExpEarned', null),
  
  earnCoinTotal(1, 6, [], 'totalCoinsEarned', null),
  earnCoinBattle(1, 6, [], 'battleCoinsEarned', null),
  earnCoinCatch(1, 6, [], 'catchCoinsEarned', null),

  speciesCatch(5, 6, [1, 1, 1, 1, 1, 1], 'lastCaught', null),

  ;


  const TaskEnum(this.minDifficulty, this.maxDifficulty, this.quantities, this.primaryField, this.secondaryField);
  final int minDifficulty;
  final int maxDifficulty;
  final List<int> quantities; // formatted 12 numbers in order: [lvl 1 min, lvl 1 max, lvl 2 min, lvl 2 max, ... , lvl 6 max]; -1 for invalid difficulties
  final String primaryField;
  final String? secondaryField;
}