import 'dart:io';
import 'dart:convert';

void main() async {
  print('----------');
  print('Starting File Scan...');
  print('Loading File...');
  final file = File('../../assets/moves_map.json');
  print('File Loaded.');
  print('Parsing File...');
  final jsonString = await file.readAsString();
  print('File Parsed.');
  print('Decoding File...');
  final List<dynamic> jsonData = jsonDecode(jsonString);
  print('File Decoded.');
  final moves = jsonData.map((item) => Move.fromJson(item)).toList();
  print('Analysing...');
  print('----------');

  int errorCount = 0;
  // Example usage
  for (var move in moves) {
    num storage = 0;
    for (num baseID in move.basePool) {
      if (baseID > 1025 || baseID <= 0) {
        print('Base ID$baseID not in valid range: Move ID${move.moveId}');
        errorCount++;
      } else if (baseID <= storage) {
        print('Base ID$baseID is less than or equal to previous ID$storage: Move ID${move.moveId}');
        errorCount++;
      } else if ((baseID * 100).round() / 100 != baseID) {
        print('Base ID$baseID format incorrect: Move ID${move.moveId}');
        errorCount++;
      }
      storage = baseID;
    }
    storage = 0;
    for (num extendedID in move.extendedPool) {
      if (move.basePool.contains(extendedID)) {
        print('Extended ID$extendedID already in base pool: Move ID${move.moveId}');
        errorCount++;
      }
      if (extendedID > 1025 || extendedID <= 0) {
        print('Extended ID$extendedID not in valid range: Move ID${move.moveId}');
        errorCount++;
      } else if (extendedID <= storage) {
        print('Extended ID$extendedID is less than or equal to previous ID$storage: Move ID${move.moveId}');
        errorCount++;
      } else if ((extendedID * 100).round() / 100 != extendedID) {
        print('Extended ID$extendedID format incorrect: Move ID${move.moveId}');
        errorCount++;
      }
      storage = extendedID;
    }
  }

  print('File scan completed. Found $errorCount errors.');
  print('----------');
}

class Move {
  final int moveId;
  final List<num> basePool;
  final List<num> extendedPool;

  Move({
    required this.moveId,
    required this.basePool,
    required this.extendedPool,
  });

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      moveId: json['move_id'] as int,
      basePool: List<num>.from(json['base_pool']),
      extendedPool: List<num>.from(json['extended_pool']),
    );
  }
}