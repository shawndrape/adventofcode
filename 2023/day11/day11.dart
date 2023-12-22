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

Map<(Point<int>, Point<int>), int> pathsWithSteps(List<String> grid,
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

    Point<int> path = pointA - pointB;
    //we -1 the expansion factor to reflect that one "step" is taken in numSteps
    return path.x.abs() +
        path.y.abs() +
        (numOfEmptyColumnsOnPath + numOfEmptyRowsOnPath) *
            (expansionFactor - 1);
  }

  var steps = <(Point<int>, Point<int>), int>{
    for (var pair in galaxyPairs) pair: stepsToGalaxy(pair)
  };

  return steps;
}

void main() {
  sum(Map<Object, int> map) => map.values.sum;
  group('part 1', () {
    test('example', () {
      expect(sum(pathsWithSteps(example.split("\n")))).toEqual(374);
    });
    test('input file', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithSteps(grid);
      expect(sum(actual)).toEqual(9445168);
    });
  });
  group('part 2', () {
    //for part 2, the order of magnitude for the gaps increases significantly
    //so rather than simulate the board, track the axis points where gaps occur
    //and add steps accordingly.
    test('example via both mechanisms', () {
      var actualFactor1 = pathsWithSteps(example.split("\n"));

      expect(sum(actualFactor1))
          .toEqual(sum(pathsWithSteps(example.split("\n"))));
    });
    test('input file for part 1 equivalency', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithSteps(grid);
      expect(sum(actual)).toEqual(9445168);
    });
    test('example w/ more expansions', () {
      var grid = example.split('\n');

      expect(sum(pathsWithSteps(grid, 10))).toEqual((1030));
      expect(sum(pathsWithSteps(grid, 100))).toEqual((8410));
    });
    test('input file', () async {
      var file = File('day11_input.txt');
      var blob = await file.readAsString();
      var grid = blob.split("\n");

      var actual = pathsWithSteps(grid, 1000000);
      expect(sum(actual)).toEqual(742305960572);
    });
  });
}
