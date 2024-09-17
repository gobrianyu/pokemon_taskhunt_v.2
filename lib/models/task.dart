import 'package:pokemon_taskhunt_2/models/blitz_game.dart';

abstract class Task {
  final int total;
  int progress;
  String text;
  bool isComplete;
  int difficulty;
  String type;

  Task.withFields({required this.total, required this.progress, required this.text, required this.isComplete, required this.difficulty, required this.type});

  void checkTask(BlitzGameData data);

  void updateProgress(int amount) {
    if (!isComplete && progress < total) {
      progress = amount;
      if (progress > total) {
        progress = total;
        updateCompleted();
      }
    }
  }

  void updateCompleted() {
    if (progress == total) {
      isComplete = true;
    }
  }

  Task clone();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.text == text &&
        other.difficulty == difficulty && 
        other.total == total &&
        other.type == type;
  }
  
  @override
  int get hashCode => text.hashCode ^ difficulty.hashCode ^ total.hashCode ^ type.hashCode;
}