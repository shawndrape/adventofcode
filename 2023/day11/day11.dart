import 'package:spec/spec.dart';

var example = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....""";

List<String> expandUniverse(List<String> grid) {
  var result = <String>[];
  for (var line in grid) {
    if (line.contains("#")) {
      result.add(line);
    } else {
      result.addAll([line, line]);
    }
  }
  var emptyGalaxyColumns = [
    for (var x = 0; x < result[0].length; x++)
      if (!result.any((element) => element[x] == "#")) x
  ];
  var finalValue = result.map((e) {
    var stringArray = e.split('');
    for (int j = 0; j < emptyGalaxyColumns.length; j++) {
      var i = emptyGalaxyColumns[j];
      stringArray.insert(i + j, '.');
    }
    return stringArray.join();
  }).toList();
  return finalValue;
}

void main() {
  group('core utils', () {
    test('expandUniverse', () {
      var expected = """
....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......""";

      expect(expandUniverse(example.split("\n"))).toEqual(expected.split("\n"));
    });
  });
}
