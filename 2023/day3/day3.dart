import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

var example_schematic = r'''
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..''';

var valid_example_numbers = {467, 35, 633, 617, 592, 755, 664, 598};

List<List<String>> traversableSchematic(String schematic) {
  List<List<String>> result = [];
  for (var line in schematic.split("\n")) {
    result.add(line.split(''));
  }
  return result;
}

enum Node {
  ALPHA,
  SYMBOL,
  PERIOD,
  DIGIT,
  UNKNOWN,
}

///based on https://www.rapidtables.com/code/text/ascii-table.html
Node getNodeType(String char) {
  int charCode = char.codeUnitAt(0);

  switch (charCode) {
    case 46:
      return Node.PERIOD;
    case >= 48 && < 58:
      return Node.DIGIT;
    case >= 65 && < 91:
    case >= 97 && < 123:
      return Node.ALPHA;
    default:
      return Node.SYMBOL;
  }
}

Set<int> extractNumbers(List<List<String>> schem, ({int x, int y}) point) {
  var result = <int>{};

  var min_x = 0;
  var min_y = 0;
  var max_y = schem.length - 1;
  var max_x = schem[0].length - 1;

  //starting from point's top-left (-1, -1), scan for digits
  for (var x = -1; x <= 1; x++) {
    for (var y = -1; y <= 1; y++) {
      if (x == 0 && y == 0) continue;
      if (point.x + x < min_x || point.x + x > max_x) continue;
      if (point.y + y < min_y || point.y + y > max_y) continue;
      var curr_point = (x: point.x + x, y: point.y + y);
      if (getNodeType(schem[curr_point.y][curr_point.x]) != Node.DIGIT)
        continue;

      int found_number = pullNumber(schem[curr_point.y], curr_point.x);
      result.add(found_number);
    }
  }
  return result;
}

///assumption: cursor already confirmed to be a digit
///found a number! Traverse X-axis in both directions until no longer on a digit
int pullNumber(List<String> line, int cursor) {
  var left_bound = -1, right_bound = 1;
  try {
    while (getNodeType(line[cursor + left_bound]) == Node.DIGIT) left_bound--;
  } on RangeError {}
  try {
    while (getNodeType(line[cursor + right_bound]) == Node.DIGIT) right_bound++;
  } on RangeError {}
  int found_number = int.parse(
      line.sublist(cursor + left_bound + 1, cursor + right_bound).join());
  return found_number;
}

Iterable<int> analyzeSchematic(String schematic) {
  var result = <int>{};
  var traversable = traversableSchematic(schematic);
  for (var y = 0; y < traversable.length; y++) {
    for (var x = 0; x < traversable[y].length; x++) {
      if (getNodeType(traversable[y][x]) == Node.SYMBOL)
        result.addAll(extractNumbers(traversable, (x: x, y: y)));
    }
  }
  return result;
}

void main() {
  group('part 1', () {
    test('test isSymbol', () {
      var sets = [
        (',', Node.SYMBOL),
        ('a', Node.ALPHA),
        ('.', Node.PERIOD),
        ('9', Node.DIGIT),
        (r'$', Node.SYMBOL),
      ];
      for (var i in sets) {
        expect(getNodeType(i.$1)).toEqual(i.$2);
      }
    });
    test('test pullNumber', () {
      var testInput = "...1234...".split("");
      expect(pullNumber(testInput, 5)).toEqual(1234);

      var test2 = "9876.....".split("");
      expect(pullNumber(test2, 1)).toEqual(9876);

      var test3 = "....*6789".split("");
      expect(pullNumber(test3, 5)).toEqual(6789);
    });
    test('example', () {
      var extracted_schematic_numbers = analyzeSchematic(example_schematic);

      expect(extracted_schematic_numbers).toEqual(valid_example_numbers);
      expect(extracted_schematic_numbers.sum).toEqual(4361);
    });
  });
}
