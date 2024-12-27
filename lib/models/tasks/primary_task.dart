import 'dart:math';

import 'package:pokemon_taskhunt_2/models/blitz_game.dart';
import 'package:pokemon_taskhunt_2/models/task.dart';

class PrimaryTask extends Task{

  final String primaryField;

  factory PrimaryTask(int difficulty) {
    return _generateTask(difficulty);
  }

  PrimaryTask.withFields({required super.total, required super.progress, required super.text, required super.isComplete, required super.difficulty, required super.type, required this.primaryField}) : super.withFields();

  @override
  void checkTask(BlitzGameData data) {
    if (!isComplete) {
      updateProgress(data.getField(primaryField));
    }
  }

  @override
  Task clone() {
    return PrimaryTask.withFields(total: total, progress: progress, text: text, isComplete: isComplete, difficulty: difficulty, type: type, primaryField: primaryField); 
  }
}

PrimaryTask _generateTask(int difficulty) {
  switch (difficulty) {
    case 1: return _weight1();
    case 2: return _weight2();
    case 3: return _weight3();
    case 4: return _weight4();
    case 5: return _weight5();
    case 6: return _weight6();
    default: throw const FormatException('Invalid task difficulty. Please provide a number between 1 and 6 inclusive.');
  }
}

PrimaryTask _weight1() {
  Random random = Random();
  switch (random.nextInt(865)) {
    case >= 0 && < 70: return _genGenTask('Earn 1000 Exp.', 1000, 1, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 1000 Coins', 1000, 1, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 750 Exp. from battling', 750, 1, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 750 Coins from battling', 750, 1, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 500 Exp. from catching Pokémon', 500, 1, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 500 Coins from catching Pokémon', 500, 1, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370:
      final int rng = random.nextInt(6) + 10;
      return _genGenTask('Catch $rng Pokémon', rng, 1, 'catch', 'totalCaught');
    case >= 370 && < 405:
      final int rng = random.nextInt(6) + 10;
      return _genGenTask('Catch $rng unique species of Pokémon', rng, 1, 'catch', 'uniqueCaught');
    case >= 405 && < 430: 
      final int rng = random.nextInt(2) + 1;
      return _genGenTask('Fail to catch $rng Pokémon', rng, 1, 'catch', 'failCaught');
    case >= 430 && < 480: 
      final int rng = random.nextInt(2) + 1;
      return _genGenTask('Hatch $rng Pokémon from eggs', rng, 1, 'hatch', 'totalHatched');
    case >= 480 && < 550: 
      final int rng = random.nextInt(4) + 5;
      return _genGenTask('Level up your Pokémon $rng times', rng, 1, 'team', 'totalLevelUps');
    case >= 550 && < 610: 
      final int rng = random.nextInt(6) + 10;
      return _genGenTask('Battle $rng times', rng, 1, 'battle', 'totalBattles');
    case >= 610 && < 660: 
      final int rng = random.nextInt(5) + 8;
      return _genGenTask('Win $rng battles', rng, 1, 'battle', 'battleWins');
    case >= 660 && < 685: 
      final int rng = random.nextInt(3) + 1;
      return _genGenTask('Lose $rng battles', rng, 1, 'battle', 'battleLosses');
    case >= 685 && < 735: 
      final int rng = random.nextInt(11) + 15;
      return _genGenTask('Use $rng items', rng, 1, 'item', 'totalItemsUsed');
    case >= 735 && < 790: 
      final int rng = random.nextInt(11) + 15;
      return _genGenTask('Buy $rng items in the shop', rng, 1, 'shop', 'shopItemsBought');
    case >= 790 && < 835: 
      final int rng = random.nextInt(11) + 5;
      return _genGenTask('Sell $rng items in the shop', rng, 1, 'shop', 'totalItemsSold');
    case >= 835 && < 865: return _genGenTask('Earn 1000 Coins selling items in the shop', 1000, 1, 'shop', 'sellCoinsEarned');
    default: throw Exception();
  }
}

PrimaryTask _weight2() {
  Random random = Random();
  switch (random.nextInt(989)) {
    case >= 0 && < 70: return _genGenTask('Earn 3000 Exp.', 3000, 2, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 3000 Coins', 3000, 2, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 2500 Exp. from battling', 3500, 2, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 2500 Coins from battling', 3500, 2, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 1500 Exp. from catching Pokémon', 1500, 2, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 1500 Coins from catching Pokémon', 1500, 2, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370:
      final int rng = random.nextInt(11) + 20;
      return _genGenTask('Catch $rng Pokémon', rng, 2, 'catch', 'totalCaught');
    case >= 370 && < 405: 
      final int rng = random.nextInt(11) + 20;
      return _genGenTask('Catch $rng unique species of Pokémon', rng, 2, 'catch', 'uniqueCaught');
    case >= 405 && < 421: return _genGenTask('Catch 1 regional variants', 1, 2, 'catch', 'regionalCaught');
    case >= 421 && < 446: 
      final int rng = random.nextInt(5) + 4;
      return _genGenTask('Fail to catch $rng Pokémon', rng, 2, 'catch', 'failCaught');
    case >= 446 && < 496: 
      final int rng = random.nextInt(4) + 3;
      return _genGenTask('Hatch $rng Pokémon from eggs', rng, 2, 'hatch', 'totalHatched');
    case >= 496 && < 566: 
      final int rng = random.nextInt(11) + 10;
      return _genGenTask('Level up your Pokémon $rng times', rng, 2, 'team', 'totalLevelUps');
    case >= 566 && < 626: 
      final int rng = (random.nextInt(7) + 10) * 2;
      return _genGenTask('Battle $rng times', rng, 2, 'battle', 'totalBattles');
    case >= 626 && < 676: 
      final int rng = random.nextInt(6) * 2 + 15;
      return _genGenTask('Win $rng battles', rng, 2, 'battle', 'battleWins');
    case >= 676 && < 701: 
      final int rng = (random.nextInt(3) + 3) * 2;
      return _genGenTask('Lose $rng battles', rng, 2, 'battle', 'battleLosses');
    case >= 701 && < 751: 
      final int rng = (random.nextInt(8) + 8) * 5;
      return _genGenTask('Use $rng items', rng, 2, 'item', 'totalItemsUsed');
    case >= 751 && < 806: 
      final int rng = (random.nextInt(8) + 8) * 5;
      return _genGenTask('Buy $rng items in the shop', rng, 2, 'shop', 'shopItemsBought');
    case >= 806 && < 851: 
      final int rng = (random.nextInt(5) + 6) * 5;
      return _genGenTask('Sell $rng items in the shop', rng, 2, 'shop', 'totalItemsSold');
    case >= 851 && < 881: return _genGenTask('Earn 2500 Coins selling items in the shop', 2500, 2, 'shop', 'sellCoinsEarned');
    case >= 881 && < 921: return _genGenTask('Evolve 1 Pokémon', 1, 2, 'team', 'totalEvolved');
    case >= 921 && < 928: return _genGenTask('Catch 1 Starter Pokémon', 1, 2, 'catch', 'starterCaught');
    case >= 928 && < 934: return _genGenTask('Catch 1 Fossil Pokémon', 1, 2, 'catch', 'fossilCaught');
    case >= 934 && < 974: 
      final int rng = random.nextInt(2) + 1;
      return _genGenTask('Win $rng type-disadvantage battles', rng, 2, 'battle', 'battleWinsDisad');
    case >= 974 && < 989:
      return _genGenTask('Lose 1 type-advantage battles', 1, 2, 'battle', 'battleLossesAd');
    default: throw Exception();
  }
}

PrimaryTask _weight3() {
  Random random = Random();
  switch (random.nextInt(999)) {
    case >= 0 && < 70: return _genGenTask('Earn 10000 Exp.', 10000, 3, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 10000 Coins', 10000, 3, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 7500 Exp. from battling', 7500, 3, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 7500 Coins from battling', 7500, 3, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 5000 Exp. from catching Pokémon', 5000, 3, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 5000 Coins from catching Pokémon', 5000, 3, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370:
      final int rng = (random.nextInt(5) + 8) * 5;
      return _genGenTask('Catch $rng Pokémon', rng, 3, 'catch', 'totalCaught');
    case >= 370 && < 405: 
      final int rng = (random.nextInt(5) + 8) * 5;
      return _genGenTask('Catch $rng unique species of Pokémon', rng, 3, 'catch', 'uniqueCaught');
    case >= 405 && < 421:
      final int rng = random.nextInt(2) + 2;
      return _genGenTask('Catch $rng regional variants', rng, 3, 'catch', 'regionalCaught');
    case >= 421 && < 446: 
      final int rng = random.nextInt(6) + 10;
      return _genGenTask('Fail to catch $rng Pokémon', rng, 3, 'catch', 'failCaught');
    case >= 446 && < 496: 
      final int rng = random.nextInt(5) + 8;
      return _genGenTask('Hatch $rng Pokémon from eggs', rng, 3, 'hatch', 'totalHatched');
    case >= 496 && < 566: 
      final int rng = (random.nextInt(5) + 5) * 5;
      return _genGenTask('Level up your Pokémon $rng times', rng, 3, 'team', 'totalLevelUps');
    case >= 566 && < 626: 
      final int rng = (random.nextInt(4) + 9) * 5;
      return _genGenTask('Battle $rng times', rng, 3, 'battle', 'totalBattles');
    case >= 626 && < 676: 
      final int rng = (random.nextInt(4) + 7) * 5;
      return _genGenTask('Win $rng battles', rng, 3, 'battle', 'battleWins');
    case >= 676 && < 701: 
      final int rng = random.nextInt(7) + 12;
      return _genGenTask('Lose $rng battles', rng, 3, 'battle', 'battleLosses');
    case >= 701 && < 751: 
      final int rng = (random.nextInt(6) + 10) * 10;
      return _genGenTask('Use $rng items', rng, 3, 'item', 'totalItemsUsed');
    case >= 751 && < 806: 
      final int rng = (random.nextInt(4) + 4) * 25;
      return _genGenTask('Buy $rng items in the shop', rng, 3, 'shop', 'shopItemsBought');
    case >= 806 && < 851: 
      final int rng = (random.nextInt(10) + 15) * 5;
      return _genGenTask('Sell $rng items in the shop', rng, 3, 'shop', 'totalItemsSold');
    case >= 851 && < 881: return _genGenTask('Earn 7500 Coins selling items in the shop', 7500, 3, 'shop', 'sellCoinsEarned');
    case >= 881 && < 921:
      final int rng = random.nextInt(2) + 2;
      return _genGenTask('Evolve $rng Pokémon', rng, 3, 'team', 'totalEvolved');
    case >= 921 && < 928: 
      final int rng = random.nextInt(2) + 2;
      return _genGenTask('Catch $rng Starter Pokémon', rng, 3, 'catch', 'starterCaught');
    case >= 928 && < 934: 
      final int rng = random.nextInt(2) + 2;
      return _genGenTask('Catch $rng Fossil Pokémon', rng, 3, 'catch', 'fossilCaught');
    case >= 934 && < 974: 
      final int rng = random.nextInt(6) + 5;
      return _genGenTask('Win $rng type-disadvantage battles', rng, 3, 'battle', 'battleWinsDisad');
    case >= 974 && < 989:
      final int rng = random.nextInt(3) + 3;
      return _genGenTask('Lose $rng type-advantage battles', rng, 3, 'battle', 'battleLossesAd');
    case >= 989 && < 994:
      return _genGenTask('Catch 1 Pseudo-Legendary Pokémon', 1, 3, 'catch', 'pseudoCaught');
    case >= 994 && < 999:
      return _genGenTask('Catch 1 Paradox Pokémon', 1, 3, 'catch', 'paradoxCaught');
    default: throw Exception();
  }
}

PrimaryTask _weight4() {
  Random random = Random();
  switch (random.nextInt(999)) {
    case >= 0 && < 70: return _genGenTask('Earn 30000 Exp.', 30000, 4, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 30000 Coins', 30000, 4, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 25000 Exp. from battling', 25000, 4, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 25000 Coins from battling', 25000, 4, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 15000 Exp. from catching Pokémon', 15000, 4, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 15000 Coins from catching Pokémon', 15000, 4, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370:
      final int rng = (random.nextInt(6) + 15) * 5;
      return _genGenTask('Catch $rng Pokémon', rng, 4, 'catch', 'totalCaught');
    case >= 370 && < 405: 
      final int rng = (random.nextInt(5) + 14) * 5;
      return _genGenTask('Catch $rng unique species of Pokémon', rng, 4, 'catch', 'uniqueCaught');
    case >= 405 && < 421:
      final int rng = random.nextInt(6) + 5;
      return _genGenTask('Catch $rng regional variants', rng, 4, 'catch', 'regionalCaught');
    case >= 421 && < 446: 
      final int rng = random.nextInt(8) + 18;
      return _genGenTask('Fail to catch $rng Pokémon', rng, 4, 'catch', 'failCaught');
    case >= 446 && < 496: 
      final int rng = random.nextInt(11) + 15;
      return _genGenTask('Hatch $rng Pokémon from eggs', rng, 4, 'hatch', 'totalHatched');
    case >= 496 && < 566: 
      final int rng = (random.nextInt(7) + 10) * 5;
      return _genGenTask('Level up your Pokémon $rng times', rng, 4, 'team', 'totalLevelUps');
    case >= 566 && < 626: 
      final int rng = (random.nextInt(6) + 15) * 5;
      return _genGenTask('Battle $rng times', rng, 4, 'battle', 'totalBattles');
    case >= 626 && < 676: 
      final int rng = (random.nextInt(4) + 13) * 5;
      return _genGenTask('Win $rng battles', rng, 4, 'battle', 'battleWins');
    case >= 676 && < 701: 
      final int rng = random.nextInt(6) + 20;
      return _genGenTask('Lose $rng battles', rng, 4, 'battle', 'battleLosses');
    case >= 701 && < 751: 
      final int rng = (random.nextInt(6) + 10) * 20;
      return _genGenTask('Use $rng items', rng, 4, 'item', 'totalItemsUsed');
    case >= 751 && < 806: 
      final int rng = (random.nextInt(7) + 9) * 25;
      return _genGenTask('Buy $rng items in the shop', rng, 4, 'shop', 'shopItemsBought');
    case >= 806 && < 851: 
      final int rng = (random.nextInt(6) + 10) * 15;
      return _genGenTask('Sell $rng items in the shop', rng, 4, 'shop', 'totalItemsSold');
    case >= 851 && < 881: return _genGenTask('Earn 20000 Coins selling items in the shop', 20000, 4, 'shop', 'sellCoinsEarned');
    case >= 881 && < 921:
      final int rng = random.nextInt(6) + 5;
      return _genGenTask('Evolve $rng Pokémon', rng, 4, 'team', 'totalEvolved');
    case >= 921 && < 928: 
      final int rng = random.nextInt(6) + 5;
      return _genGenTask('Catch $rng Starter Pokémon', rng, 4, 'catch', 'starterCaught');
    case >= 928 && < 934: 
      final int rng = random.nextInt(6) + 5;
      return _genGenTask('Catch $rng Fossil Pokémon', rng, 4, 'catch', 'fossilCaught');
    case >= 934 && < 974: 
      final int rng = (random.nextInt(6) + 10) * 2;
      return _genGenTask('Win $rng type-disadvantage battles', rng, 4, 'battle', 'battleWinsDisad');
    case >= 974 && < 989:
      final int rng = random.nextInt(6) + 10;
      return _genGenTask('Lose $rng type-advantage battles', rng, 4, 'battle', 'battleLossesAd');
    case >= 989 && < 994:
      final int rng = random.nextInt(5) + 4;
      return _genGenTask('Catch $rng Pseudo-Legendary Pokémon', rng, 4, 'catch', 'pseudoCaught');
    case >= 994 && < 999:
      final int rng = random.nextInt(5) + 4;
      return _genGenTask('Catch $rng Paradox Pokémon', rng, 4, 'catch', 'paradoxCaught');
    default: throw Exception();
  }
}

PrimaryTask _weight5() {
  Random random = Random();
  switch (random.nextInt(999)) {
    case >= 0 && < 70: return _genGenTask('Earn 100000 Exp.', 100000, 5, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 100000 Coins', 100000, 5, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 75000 Exp. from battling', 75000, 5, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 75000 Coins from battling', 75000, 5, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 50000 Exp. from catching Pokémon', 50000, 5, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 50000 Coins from catching Pokémon', 50000, 5, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370:
      final int rng = (random.nextInt(4) + 12) * 10;
      return _genGenTask('Catch $rng Pokémon', rng, 5, 'catch', 'totalCaught');
    case >= 370 && < 405: 
      final int rng = (random.nextInt(6) + 10) * 10;
      return _genGenTask('Catch $rng unique species of Pokémon', rng, 5, 'catch', 'uniqueCaught');
    case >= 405 && < 421:
      final int rng = random.nextInt(9) + 17;
      return _genGenTask('Catch $rng regional variants', rng, 5, 'catch', 'regionalCaught');
    case >= 421 && < 446: 
      final int rng = (random.nextInt(5) + 6) * 5;
      return _genGenTask('Fail to catch $rng Pokémon', rng, 5, 'catch', 'failCaught');
    case >= 446 && < 496: 
      final int rng = (random.nextInt(5) + 6) * 5;
      return _genGenTask('Hatch $rng Pokémon from eggs', rng, 5, 'hatch', 'totalHatched');
    case >= 496 && < 566: 
      final int rng = (random.nextInt(6) + 10) * 10;
      return _genGenTask('Level up your Pokémon $rng times', rng, 5, 'team', 'totalLevelUps');
    case >= 566 && < 626: 
      final int rng = (random.nextInt(4) + 12) * 10;
      return _genGenTask('Battle $rng times', rng, 5, 'battle', 'totalBattles');
    case >= 626 && < 676: 
      final int rng = (random.nextInt(3) + 10) * 10;
      return _genGenTask('Win $rng battles', rng, 5, 'battle', 'battleWins');
    case >= 676 && < 701: 
      final int rng = (random.nextInt(3) + 6) * 5;
      return _genGenTask('Lose $rng battles', rng, 5, 'battle', 'battleLosses');
    case >= 701 && < 751: 
      final int rng = (random.nextInt(6) + 20) * 20;
      return _genGenTask('Use $rng items', rng, 5, 'item', 'totalItemsUsed');
    case >= 751 && < 806: 
      final int rng = (random.nextInt(5) + 26) * 20;
      return _genGenTask('Buy $rng items in the shop', rng, 5, 'shop', 'shopItemsBought');
    case >= 806 && < 851: 
      final int rng = (random.nextInt(11) + 25) * 10;
      return _genGenTask('Sell $rng items in the shop', rng, 5, 'shop', 'totalItemsSold');
    case >= 851 && < 881: return _genGenTask('Earn 50000 Coins selling items in the shop', 50000, 5, 'shop', 'sellCoinsEarned');
    case >= 881 && < 921: 
      final int rng = random.nextInt(9) + 17;
      return _genGenTask('Evolve $rng Pokémon', rng, 5, 'team', 'totalEvolved');
    case >= 921 && < 928: 
      final int rng = random.nextInt(9) + 17;
      return _genGenTask('Catch $rng Starter Pokémon', rng, 5, 'catch', 'starterCaught');
    case >= 928 && < 934: 
      final int rng = random.nextInt(9) + 17;
      return _genGenTask('Catch $rng Fossil Pokémon', rng, 5, 'catch', 'fossilCaught');
    case >= 934 && < 974: 
      final int rng = random.nextInt(11) + 40;
      return _genGenTask('Win $rng type-disadvantage battles', rng, 5, 'battle', 'battleWinsDisad');
    case >= 974 && < 989: 
      final int rng = random.nextInt(6) + 20;
      return _genGenTask('Lose $rng type-advantage battles', rng, 5, 'battle', 'battleLossesAd');
    case >= 989 && < 994: 
      final int rng = random.nextInt(6) + 15;
      return _genGenTask('Catch $rng Pseudo-Legendary Pokémon', rng, 5, 'catch', 'pseudoCaught');
    case >= 994 && < 999:
      final int rng = random.nextInt(6) + 15;
      return _genGenTask('Catch $rng Paradox Pokémon', rng, 5, 'catch', 'paradoxCaught');
    default: throw Exception();
  }
}

PrimaryTask _weight6() {
  Random random = Random();
  switch (random.nextInt(1000)) {
    case >= 0 && < 70: return _genGenTask('Earn 1000000 Exp.', 1000000, 6, 'general', 'totalExpEarned');
    case >= 70 && < 130: return _genGenTask('Earn 1000000 Coins', 1000000, 6, 'general', 'totalCoinsEarned');
    case >= 130 && < 175: return _genGenTask('Earn 750000 Exp. from battling', 750000, 6, 'battle', 'battleExpEarned');
    case >= 175 && < 215: return _genGenTask('Earn 750000 Coins from battling', 750000, 6, 'battle', 'battleCoinsEarned');
    case >= 215 && < 260: return _genGenTask('Earn 500000 Exp. from catching Pokémon', 500000, 6, 'catch', 'catchExpEarned');
    case >= 260 && < 300: return _genGenTask('Earn 500000 Coins from catching Pokémon', 500000, 6, 'catch', 'catchCoinsEarned');
    case >= 300 && < 370: return _genGenTask('Catch 500 Pokémon', 500, 6, 'catch', 'totalCaught');
    case >= 370 && < 405: return _genGenTask('Catch 400 unique species of Pokémon', 400, 6, 'catch', 'uniqueCaught');
    case >= 405 && < 421: return _genGenTask('Catch 50 regional variants', 50, 6, 'catch', 'regionalCaught');
    case >= 421 && < 446: return _genGenTask('Fail to catch 100 Pokémon', 100, 6, 'catch', 'failCaught');
    case >= 446 && < 496: return _genGenTask('Hatch 100 Pokémon from eggs', 100, 6, 'hatch', 'totalHatched');
    case >= 496 && < 566: return _genGenTask('Level up your Pokémon 300 times', 300, 6, 'team', 'totalLevelUps');
    case >= 566 && < 626: return _genGenTask('Battle 300 times', 300, 6, 'battle', 'totalBattles');
    case >= 626 && < 676: return _genGenTask('Win 230 battles', 230, 6, 'battle', 'battleWins');
    case >= 676 && < 701: return _genGenTask('Lose 75 battles', 75, 6, 'battle', 'battleLosses');
    case >= 701 && < 751: return _genGenTask('Use 1000 items', 1000, 6, 'item', 'totalItemsUsed');
    case >= 751 && < 806: return _genGenTask('Buy 1200 items in the shop', 1200, 6, 'shop', 'shopItemsBought');
    case >= 806 && < 851: return _genGenTask('Sell 700 items in the shop', 700, 6, 'shop', 'totalItemsSold');
    case >= 851 && < 881: return _genGenTask('Earn 100000 Coins selling items in the shop', 100000, 6, 'shop', 'sellCoinsEarned');
    case >= 881 && < 921: return _genGenTask('Evolve 50 Pokémon', 50, 6, 'team', 'totalEvolved');
    case >= 921 && < 928: return _genGenTask('Catch 50 Starter Pokémon', 50, 6, 'catch', 'starterCaught');
    case >= 928 && < 934: return _genGenTask('Catch 50 Fossil Pokémon', 50, 6, 'catch', 'fossilCaught');
    case >= 934 && < 974: return _genGenTask('Win 100 type-disadvantage battles', 100, 6, 'battle', 'battleWinsDisad');
    case >= 974 && < 989: return _genGenTask('Lose 50 type-advantage battles', 50, 6, 'battle', 'battleLossesAd');
    case >= 989 && < 994: return _genGenTask('Catch 40 Pseudo-Legendary Pokémon', 40, 6, 'catch', 'pseudoCaught');
    case >= 994 && < 999: return _genGenTask('Catch 40 Paradox Pokémon', 40, 6, 'catch', 'paradoxCaught');
    case 999: return _genGenTask('Catch a shiny Pokémon', 1, 6, 'catch', 'shinyCaught');
    default: throw Exception();
  }
}

PrimaryTask _genGenTask(String text, int total, int difficulty, String type, String primaryField) {
  return PrimaryTask.withFields(total: total, progress: 0, text: text, isComplete: false, difficulty: difficulty, type: type, primaryField: primaryField);
}