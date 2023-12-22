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

extension on int {
  bool between(int a, int b) {
    if (a == b) return false; //can not be between single value
    if (a > b) {
      return b < this && this < a;
    } else {
      return a < this && this < b;
    }
  }
}

///Collect the points of galaxies, and put them on a set of pairs (ignores duplicates)
///Then subtract the points in each pair and record the steps that point represents
Map<(Point<int>, Point<int>), int> pathsWithSteps(List<String> input) {
  var grid = expandUniverse(input);

  var knownGalaxies = [
    for (int yAxis = 0; yAxis < grid.length; yAxis++)
      for (int xAxis = 0; xAxis < grid[0].length; xAxis++)
        if (grid[yAxis][xAxis] == "#") Point(xAxis, yAxis)
  ];
  var galaxyPairs = <(Point<int>, Point<int>)>{
    for (var x = 0; x < knownGalaxies.length; x++)
      for (var y = x + 1; y < knownGalaxies.length; y++)
        (knownGalaxies[x], knownGalaxies[y])
  };

  // var steps = galaxyPairs.map((e) {
  //   var (pointA, pointB) = e;
  //   var difference = pointA - pointB;
  //   return difference.numSteps();
  // });
  var steps = {
    for (var pair in galaxyPairs) pair: (pair.$1 - pair.$2).numSteps()
  };
  return steps;
}

Map<(Point<int>, Point<int>), int> pathsWithStepsOfExpandedUniverse(
    List<String> grid,
    [int expansionFactor = 2]) {
  var emptyGalaxyColumns = [
    for (var x = 0; x < grid[0].length; x++)
      if (!grid.any((element) => element[x] == "#")) x
  ];
  var emptyGalaxyRows = [
    for (var (i, line) in grid.indexed)
      if (!line.contains("#")) i
  ];
  var knownGalaxies = [
    for (int yAxis = 0; yAxis < grid.length; yAxis++)
      for (int xAxis = 0; xAxis < grid[0].length; xAxis++)
        if (grid[yAxis][xAxis] == "#") Point(xAxis, yAxis)
  ];

  var galaxyPairs = <(Point<int>, Point<int>)>{
    for (var x = 0; x < knownGalaxies.length; x++)
      for (var y = x + 1; y < knownGalaxies.length; y++)
        (knownGalaxies[x], knownGalaxies[y])
  };

  int stepsToGalaxy((Point<int>, Point<int>) e) {
    var (pointA, pointB) = e;
    var numOfEmptyColumnsOnPath =
        emptyGalaxyColumns.where((e) => e.between(pointA.x, pointB.x)).length;
    var numOfEmptyRowsOnPath =
        emptyGalaxyRows.where((e) => e.between(pointA.y, pointB.y)).length;

    var difference = pointA - pointB;
    //we -1 the expansion factor to reflect that one "step" is taken in numSteps
    return difference.numSteps() +
        (numOfEmptyColumnsOnPath + numOfEmptyRowsOnPath) *
            (expansionFactor - 1);
  }

  var steps = <(Point<int>, Point<int>), int>{
    for (var pair in galaxyPairs) pair: stepsToGalaxy(pair)
  };

  return steps;
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
      expect(pathsWithSteps(example.split("\n")).values.sum).toEqual(374);
    });
    test('input file', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithSteps(grid);
      expect(actual.values.sum).toEqual(9445168);
    });
  });
  group('part 2', () {
    //for part 2, the order of magnitude for the gaps increases significantly
    //so rather than simulate the board, track the axis points where gaps occur
    //and add steps accordingly.
    test('example via both mechanisms', () {
      var actualFactor1 = pathsWithStepsOfExpandedUniverse(example.split("\n"));

      expect(actualFactor1.values.sum)
          .toEqual(pathsWithSteps(example.split("\n")).values.sum);
    });
    test('input file for part 1 equivalency', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithStepsOfExpandedUniverse(grid);
      expect(actual.values.sum).toEqual(9445168);
    });
    test('example w/ more expansions', () {
      var grid = example.split('\n');

      expect(pathsWithStepsOfExpandedUniverse(grid, 10).values.sum)
          .toEqual((1030));
      expect(pathsWithStepsOfExpandedUniverse(grid, 100).values.sum)
          .toEqual((8410));
    });
    test('input file', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithStepsOfExpandedUniverse(grid, 1000000);
      expect(actual.values.sum).toEqual(742305960572);
    });
  });
}
