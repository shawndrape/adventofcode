import 'dart:collection';

import 'package:spec/spec.dart';

Map<int, int> parseFilter(String summary) {
  var result = <int, int>{};
  for (var line in summary.split("\n")) {
    var [dest, source, length] = line.split(" ").map(int.parse).toList();
    for (var x = 0; x < length; x++) {
      result[x + source] = x + dest;
    }
  }
  return result;
}

int Function(int e) generateFilter(Map<int, int> filterPattern) =>
    (int e) => filterPattern[e] ?? e;

void main() {
  const example_input = {
    0: "79 14 55 13",
    1: """50 98 2
52 50 48""",
    2: """0 15 37
37 52 2
39 0 15""",
    3: """49 53 8
0 11 42
42 0 7
57 7 4""",
    4: """88 18 7
18 25 70""",
    5: """45 77 23
81 45 19
68 64 13""",
    6: """0 69 1
1 0 69""",
    7: """60 56 37
56 93 4""",
  };
  group('part 1', () {
    test('example', () {
      /*
      Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
      Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
      Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
      Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
      */
      var expected_values_array = [
        [79, 81, 81, 81, 74, 78, 78, 82],
        [14, 14, 53, 49, 42, 42, 43, 43],
        [55, 57, 57, 53, 46, 82, 82, 86],
        [13, 13, 52, 41, 34, 34, 35, 35],
      ];

      var actual = example_input[0]!.split(" ").map(int.parse).map((e) => [e]);

      for (var x = 1; x <= 7; x++) {
        var filterSource = example_input[x]!;
        var filterMap = parseFilter(filterSource);
        var filter = generateFilter(filterMap);
        actual = actual.map((e) => [...e, filter(e.last)]);
      }
      expect(actual).toEqual(expected_values_array);
    });
  });
}
