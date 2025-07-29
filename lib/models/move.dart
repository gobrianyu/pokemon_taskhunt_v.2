import 'package:pokemon_taskhunt_2/models/types.dart';

const Map<int, int> priorityMoves = {
  270:5,
  643:4, 890:4, 197:4, 203:4, 588:4, 774:4, 182:4, 596:4, 834:4,
  252:3, 501:3, 900:3, 469:3,
  502:2, 245:2, 364:2, 642:2, 266:2, 476:2,
  691:1, 453:1, 608:1, 418:1, 785:1, 420:1, 839:1, 183:1, 98:1, 425:1, 389:1, 891:1, 410:1, 594:1,
  672:-3,264:-3,686:-3,
  419:-4,
  68:-5, 429:-5,
  509:-6, 525:-6, 46:-6, 18:-6, 100:-6,
  433:-7,
};

class Move {
  final int id;
  final String name;
  final Types type;
  final String category;
  final int pp;
  final int? power;
  final int? accuracy;
  final String? effect;
  final double? probability;
  final String? flavourText;
  final int priority;

  Move({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.pp,
    this.power,
    this.accuracy,
    this.effect,
    this.probability,
    this.flavourText,
    required this.priority,
  });

  factory Move.fromCsv(List<dynamic> row) {
    int id = int.parse(row[0]);
    int priority = priorityMoves[id] ?? 0;
    
    return Move(
      id: id,
      name: row[1],
      type: Types.tryFromString(row[2]),
      category: row[3],
      pp: int.parse(row[4]),
      power: row[5].toString().isEmpty ? null : int.parse(row[5]),
      accuracy: row[6].toString().isEmpty ? null : int.parse(row[6]),
      effect: row[7].toString().isEmpty ? '' : row[7],
      probability: row[8].toString().isEmpty ? null : double.parse(row[8]),
      flavourText: row[9].toString().isEmpty ? '' : row[9],
      priority: priority,
    );
  }

  factory Move.placeholder() {
    return Move(
      id: 0,
      name: 'Placeholder',
      type: Types.normal,
      category: 'Physical',
      pp: 100,
      power: 50,
      accuracy: 100,
      flavourText: 'This is a placeholder move.',
      priority: 0,
    );
  }
}