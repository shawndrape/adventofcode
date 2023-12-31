import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

//assume top-left is 0, 0
// S needs to search for segments connecting back to it, but that's fine

Set<Point<int>> connectedSegments(String char) => switch (char) {
      "F" => {Point(1, 0), Point(0, 1)},
      "L" => {Point(0, -1), Point(1, 0)},
      "J" => {Point(0, -1), Point(-1, 0)},
      "7" => {Point(-1, 0), Point(0, 1)},
      "-" => {Point(-1, 0), Point(1, 0)},
      "|" => {Point(0, -1), Point(0, 1)},
      "." => {},
      _ => throw Exception("Invalid symbol")
    };

var complicatedExample = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ""";

Point<int> findStartingPipe(List<String> grid) {
  var x = 0, y = 0;
  for (var line in grid) {
    if ((x = line.indexOf("S")) > -1) return Point(x, y);
    y++;
  }
  throw Exception("No S found in input");
}

(Point<int>, Point<int>) findInitialDirections(
    List<String> grid, Point<int> start) {
  assert(grid[start.y][start.x] == "S");
  var startingPoints = <Point<int>>[];
  var minX = 0;
  var minY = 0;
  var maxY = grid.length - 1;
  var maxX = grid[0].length - 1;

  //starting from point's top-left (-1, -1), scan for pipes
  for (var y = -1; y <= 1; y++) {
    for (var x = -1; x <= 1; x++) {
      if (x == 0 && y == 0) continue;
      var currX = start.x + x;
      var currY = start.y + y;
      if (currX < minX || currX > maxX) continue;
      if (currY < minY || currY > maxY) continue;
      var directions = connectedSegments(grid[currY][currX]);
      if (directions.isEmpty) continue;
      if (directions
          .any((element) => (Point(currX, currY) + element) == start)) {
        startingPoints.add(Point(currX, currY));
      }
    }
  }

  assert(startingPoints.length == 2);
  return (startingPoints[0], startingPoints[1]);
}

(int, Point<int>) findTheMidpoint(List<String> grid) {
  //no need to track history of pipe
  //just need (for each direction) current and previous
  //with curr and prev, you can apply connectedSegments
  //to curr, toss away the one equal to prev, and keep next
  //oh, and increment a counter

  //once both directions' `curr` are equal (or the set of prev, curr has overlap)
  //you have the answer
  var startingPoint = findStartingPipe(grid);
  var (currentA, currentB) = findInitialDirections(grid, startingPoint);
  var prevA = startingPoint, prevB = startingPoint;
  var stepCount = 1;
  while (currentA != currentB && (prevB != currentA || prevA != currentB)) {
    //A first, then B
    var nextAOptions = connectedSegments(grid[currentA.y][currentA.x]);
    var nextA = nextAOptions
        .map((e) => currentA + e)
        .whereNot((element) => element == prevA)
        .first;
    prevA = currentA;
    currentA = nextA;

    var nextBOptions = connectedSegments(grid[currentB.y][currentB.x]);
    var nextB = nextBOptions
        .map((e) => currentB + e)
        .whereNot((element) => element == prevB)
        .first;
    prevB = currentB;
    currentB = nextB;

    stepCount++;
  }
  return (stepCount, currentA);
}

//expected answer: 4
var part2example1 = """
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........""";

List<String> expandGrid(List<String> grid) {
  var result = <String>[];
  int? gridLength;
  for (var line in grid) {
    result.add(line.split("").join("G"));
    gridLength ??= result[0].length;
    result.add(List<String>.generate(gridLength, (_) => "G", growable: false)
        .join(""));
  }
  result.removeLast();
  return result;
}

Set<Point<int>> connectedSegmentsExpanded(String char) => switch (char) {
      "F" => {Point(2, 0), Point(1, 0), Point(0, 1), Point(0, 2)},
      "L" => {Point(0, -2), Point(0, -1), Point(1, 0), Point(2, 0)},
      "J" => {Point(0, -2), Point(0, -1), Point(-1, 0), Point(-2, 0)},
      "7" => {Point(-2, 0), Point(-1, 0), Point(0, 1), Point(0, 2)},
      "-" => {Point(-2, 0), Point(-1, 0), Point(1, 0), Point(2, 0)},
      "|" => {Point(0, -2), Point(0, -1), Point(0, 1), Point(0, 2)},
      "." => {},
      "G" => throw Exception("evaluating a gap"),
      "I" => throw Exception("evaluating inner wall"),
      "O" => throw Exception("Evaluating outer wall"),
      _ => throw Exception("Invalid symbol")
    };

Set<Point<int>> findInitialDirectionsExpanded(
    List<String> grid, Point<int> start) {
  assert(grid[start.y][start.x] == "S");
  var startingPoints = <Point<int>>{};
  var minX = 0;
  var minY = 0;
  var maxY = grid.length - 1;
  var maxX = grid[0].length - 1;

  //starting from point's top-left (-2, -2), scan for pipes
  for (var y = -2; y <= 2; y += 2) {
    for (var x = -2; x <= 2; x += 2) {
      if (x == 0 && y == 0) continue;
      var currX = start.x + x;
      var currY = start.y + y;
      if (currX < minX || currX > maxX) continue;
      if (currY < minY || currY > maxY) continue;
      var directions = connectedSegmentsExpanded(grid[currY][currX]);
      if (directions.isEmpty) continue;
      var contributingPoints = directions.map((e) => Point(currX, currY) + e);
      if (contributingPoints.any((element) => element == start)) {
        startingPoints.addAll(contributingPoints);
        startingPoints.add(Point(currX, currY));
      }
    }
  }

  startingPoints.remove(start);
  assert(startingPoints.length == 8);
  return startingPoints;
}

void main() {
  group('utils', () {
    test('find start', () {
      var expected = Point(0, 2);

      expect(findStartingPipe(complicatedExample.split("\n")))
          .toEqual(expected);
    });
    test('error on missing start', () {
      var badInput = complicatedExample.replaceAll("S", "8");

      expect(() => findStartingPipe(badInput.split("\n"))).throws.isException();
    });
    test('find starting points', () {
      var expected = (Point(1, 2), Point(0, 3));

      var grid = complicatedExample.split("\n");
      expect(findInitialDirections(grid, findStartingPipe(grid)))
          .toEqual(expected);
    });
  });
  group('part 1', () {
    test('example', () {
      var expectedSteps = 8, expectedPoint = Point(4, 2);

      var (actualSteps, actualPoint) =
          findTheMidpoint(complicatedExample.split("\n"));

      expect(actualSteps).toEqual(expectedSteps);
      expect(actualPoint).toEqual(expectedPoint);
    });
    test('input file', () {
      var file = File('day10_input.txt');

      var input = file.readAsStringSync();
      var grid = input.split("\n");

      var (steps, _) = findTheMidpoint(grid);

      expect(steps).toEqual(6701);
    });
  });
  group('part 2', () {
    test('expand grid', () {
      var exampleGrid = """
.....
.S-7.
.|.|.
.L-J.
.....""";

      var expectedExpansion = """
.G.G.G.G.
GGGGGGGGG
.GSG-G7G.
GGGGGGGGG
.G|G.G|G.
GGGGGGGGG
.GLG-GJG.
GGGGGGGGG
.G.G.G.G.""";
      var expandedGrid = expandGrid(exampleGrid.split("\n"));
      expect(expandedGrid.join("\n")).toEqual(expectedExpansion);
    });
    test('identify expanded starts', () {
      var input = """
...
.S-
.|.""";
      var expandedGrid = expandGrid(input.split("\n"));
      var start = findStartingPipe(expandedGrid);

      expect(findInitialDirectionsExpanded(expandedGrid, start)).toEqual({
        Point(3, 2),
        Point(5, 2),
        Point(6, 2),
        Point(4, 2),
        Point(2, 3),
        Point(2, 5),
        Point(2, 6),
        Point(2, 4)
      });
    });
  });
}
