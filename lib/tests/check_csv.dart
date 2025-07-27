import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage: dart check_csv.dart <file_path>');
    return;
  }

  final filePath = arguments[0];
  final file = File(filePath);

  if (!await file.exists()) {
    print('File not found: $filePath');
    return;
  }

  final lines = await file.readAsLines();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final commaCount = '|'.allMatches(line).length;
    if (commaCount != 9) {
      print('Line ${i + 1} has $commaCount delimiters');
    }
  }
}