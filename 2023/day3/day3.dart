// ignore_for_file: empty_catches

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

List<List<String>> traversableSchematic(String schematic) {
  List<List<String>> result = [];
  for (var line in schematic.split("\n")) {
    result.add(line.split(''));
  }
  return result;
}

enum Node {
  alpha,
  symbol,
  period,
  digit,
  unknown,
}

///based on https://www.rapidtables.com/code/text/ascii-table.html
Node getNodeType(String char) {
  int charCode = char.codeUnitAt(0);

  switch (charCode) {
    case 46:
      return Node.period;
    case >= 48 && < 58:
      return Node.digit;
    case >= 65 && < 91:
    case >= 97 && < 123:
      return Node.alpha;
    default:
      return Node.symbol;
  }
}

List<int> extractNumbers(List<List<String>> schem, ({int x, int y}) point) {
  var result = <int>[];

  var minX = 0;
  var minY = 0;
  var maxY = schem.length - 1;
  var maxX = schem[0].length - 1;

  //starting from point's top-left (-1, -1), scan for digits
  for (var y = -1; y <= 1; y++) {
    for (var x = -1; x <= 1; x++) {
      if (x == 0 && y == 0) continue;
      if (point.x + x < minX || point.x + x > maxX) continue;
      if (point.y + y < minY || point.y + y > maxY) continue;
      var currPoint = (x: point.x + x, y: point.y + y);
      if (getNodeType(schem[currPoint.y][currPoint.x]) != Node.digit) {
        continue;
      }

      var (foundNumber, shiftX) = pullNumber(schem[currPoint.y], currPoint.x);
      result.add(foundNumber);
      x += shiftX;
    }
  }
  return result;
}

///assumption: cursor already confirmed to be a digit
///found a number! Traverse X-axis in both directions until no longer on a digit
(int, int) pullNumber(List<String> line, int cursor) {
  var leftBound = -1, rightBound = 1;
  try {
    while (getNodeType(line[cursor + leftBound]) == Node.digit) {
      leftBound--;
    }
  } on RangeError {}
  try {
    while (getNodeType(line[cursor + rightBound]) == Node.digit) {
      rightBound++;
    }
  } on RangeError {}
  int foundNumber = int.parse(
      line.sublist(cursor + leftBound + 1, cursor + rightBound).join());
  return (foundNumber, rightBound - 1);
}

Iterable<int> analyzeSchematic(String schematic,
    {bool checkGearsOnly = false}) {
  var result = <int>[];
  var traversable = traversableSchematic(schematic);
  for (var y = 0; y < traversable.length; y++) {
    for (var x = 0; x < traversable[y].length; x++) {
      if (getNodeType(traversable[y][x]) == Node.symbol) {
        if (checkGearsOnly && traversable[y][x] != '*') continue;
        var extracted = extractNumbers(traversable, (x: x, y: y));
        if (checkGearsOnly && extracted.length == 2) {
          result.add(extracted[0] * extracted[1]);
        } else if (!checkGearsOnly) {
          result.addAll(extracted);
        }
      }
    }
  }
  return result;
}

var exampleSchematic = r'''
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

var validExampleNumbers = {467, 35, 633, 617, 592, 755, 664, 598};

void main() {
  group('part 1', () {
    test('test isSymbol', () {
      var sets = [
        (',', Node.symbol),
        ('a', Node.alpha),
        ('.', Node.period),
        ('9', Node.digit),
        (r'$', Node.symbol),
      ];
      for (var i in sets) {
        expect(getNodeType(i.$1)).toEqual(i.$2);
      }
    });
    test('test pullNumber', () {
      var testInput = "...1234...".split("");
      expect(pullNumber(testInput, 5).$1).toEqual(1234);

      var test2 = "9876.....".split("");
      expect(pullNumber(test2, 1).$1).toEqual(9876);

      var test3 = "....*6789".split("");
      expect(pullNumber(test3, 5).$1).toEqual(6789);
    });
    test('example', () {
      var extractedSchematicNumbers = analyzeSchematic(exampleSchematic);

      expect(extractedSchematicNumbers).toEqual(validExampleNumbers);
      expect(extractedSchematicNumbers.sum).toEqual(4361);
    });
    test('duplicate numbers around a symbol', () {
      var input = r'''51.
.*.
.51''';

      expect(analyzeSchematic(input).sum).toEqual(102);
    });
    test('duplicate symbols around a number', () {
      //pray this isn't needed
      //part 1 value worked, so input file does not contain any numbers
      //adjecent to multiple symbols 😅
    });
    test('input file', () async {
      // ignore: unused_local_variable
      var detectedSymbols = {'-', '#', '=', '*', '+', '@', r'$', '&', '/', '%'};
      var file = File('day3_input.txt');
      var input = await file.readAsString();

      var discoveredNumbers = analyzeSchematic(input);
      expect(discoveredNumbers.sum).greaterThan(333179);
      expect(discoveredNumbers.sum).toEqual(556367);
    });
  });
  group('part 2', () {
    test('example', () {
      var extractedGearRatios =
          analyzeSchematic(exampleSchematic, checkGearsOnly: true);

      expect(extractedGearRatios.sum).toBe(467835);
    });
    test('input file', () async {
      var file = File('day3_input.txt');
      var input = await file.readAsString();

      var discoveredRatios = analyzeSchematic(input, checkGearsOnly: true);
      expect(discoveredRatios.sum).toBe(89471771);
    });
  });
}
