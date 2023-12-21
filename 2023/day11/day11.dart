import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
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

extension GalaxyMapping on Point<int> {
  int numSteps() => x.abs() + y.abs();
}

///Collect the points of galaxies, and put them on a set of pairs (ignores duplicates)
///Then subtract the points in each pair and record the steps that point represents
int sumOfPaths(List<String> input) {
  var knownGalaxies = <Point<int>>[];
  var grid = expandUniverse(input);

  //TODO - refactor to collection for
  for (int yAxis = 0; yAxis < grid.length; yAxis++) {
    for (int xAxis = 0; xAxis < grid[0].length; xAxis++) {
      if (grid[yAxis][xAxis] == "#") knownGalaxies.add(Point(xAxis, yAxis));
    }
  }
  var galaxyPairs = <(Point<int>, Point<int>)>{};
  for (var x = 0; x < knownGalaxies.length; x++) {
    for (var y = x + 1; y < knownGalaxies.length; y++) {
      galaxyPairs.add((knownGalaxies[x], knownGalaxies[y]));
    }
  }

  var steps = galaxyPairs.map((e) {
    var (pointA, pointB) = e;
    var difference = pointA - pointB;
    return difference.numSteps();
  });
  return steps.sum;
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
  group('part 1', () {
    test('example', () {
      expect(sumOfPaths(example.split("\n"))).toEqual(374);
    });
    test('input file', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = sumOfPaths(grid);
      expect(actual).toEqual(9445168);
    });
  });
}
