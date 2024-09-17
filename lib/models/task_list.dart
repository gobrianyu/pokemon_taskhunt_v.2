import 'dart:math';

import 'package:pokemon_taskhunt_2/models/task.dart';
import 'package:pokemon_taskhunt_2/models/tasks/primary_task.dart';

List<int> generateList(int numTasks, int numStars) {
  if (numStars > numTasks * 6) {
    throw Exception();
  }
  Random random = Random();
  List<int> numbers = List.filled(numTasks, 1);
  int sum = numbers.reduce((a, b) => a + b);
  int difference = numStars - sum;
  while (difference > 0) {
    for (int i = 0; i < numbers.length; i++) {
      int currentMaxIncrement = min(difference, 6 - numbers[i]);
      int increment = random.nextInt(currentMaxIncrement + 1);
      if (increment == currentMaxIncrement) {
        increment = random.nextInt(currentMaxIncrement + 1);
      }
      numbers[i] += increment;
      difference -= increment;
    }
  }
  numbers.sort((a, b) => a.compareTo(b));
  return numbers;
}

class TaskList {
  final List tasks;
  final int totalStars;

  factory TaskList(int numTasks, int numStars) {
    final List<int> difficulties = generateList(numTasks, numStars);
    final List taskList = [];

    for (int difficulty in difficulties) {
      Task newTask = PrimaryTask(difficulty);
      while (taskList.contains(newTask)) {
        newTask = PrimaryTask(difficulty);
      }
      taskList.add(newTask);
    }

    return TaskList.withFields(tasks: taskList, totalStars: numStars);
  }

  TaskList.withFields({required this.tasks, required this.totalStars});

  
  void removeTask(Task task) {
    if (tasks.contains(task)) {
      tasks.remove(task);
    } 
  }

  List clone() {
    return List.from(tasks);
  }
}