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

var valid_example_numbers = {467, 35, 633, 617, 592, 755, 644, 598};

List<List<String>> traversable_schematic(String schematic) {
  List<List<String>> result = [];
  for (var line in schematic.split("\n")) {
    result.add(line.split(''));
  }
  return result;
}

///based on https://www.rapidtables.com/code/text/ascii-table.html
bool isSymbol(String char) {
  int charCode = char.codeUnitAt(0);

  switch (charCode) {
    case < 33:
    case 46:
    case >= 48 && < 58:
    case >= 65 && < 91:
    case >= 97 && < 123:
      return false;
    default:
      return true;
  }
}

Iterable<int> analyze_schematic(String schematic) {
  return {35};
}

void main() {
  group('part 1', () {
    test('test isSymbol', () {
      var sets = [
        (',', true),
        ('a', false),
        ('.', false),
        ('9', false),
        (r'$', true),
      ];
      for (var i in sets) {
        expect(isSymbol(i.$1)).toEqual(i.$2);
      }
    });
    test('example', () {
      var extracted_schematic_numbers = analyze_schematic(example_schematic);

      expect(extracted_schematic_numbers).toEqual(valid_example_numbers);
    });
  });
}
