import 'dart:math';

import 'package:spec/spec.dart';

//assume top-left is 0, 0
//no need to track history of pipe
//just need (for each direction) current and previous
//with curr and prev, you can apply connectedSegments
//to curr, toss away the one equal to prev, and keep next
//oh, and increment a counter

//once both directions' `curr` are equal (or the set of prev, curr has overlap)
//you have the answer

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

Point<int> findStartingPipe(String input) {
  var x = 0, y = 0;
  for (var line in input.split("\n")) {
    if ((x = line.indexOf("S")) > -1) return Point(x, y);
    y++;
  }
  throw Exception("No S found in input");
}

(Point<int>, Point<int>) findInitialDirections(String input, Point<int> start) {
  List<String> grid = input.split("\n");
  assert(grid[start.y][start.x] == "S");
  var startingPoints = <Point<int>>[];
  var minX = 0;
  var minY = 0;
  var maxY = grid.length - 1;
  var maxX = grid[0].length - 1;

  //starting from point's top-left (-1, -1), scan for digits
  for (var y = -1; y <= 1; y++) {
    for (var x = -1; x <= 1; x++) {
      if (x == 0 && y == 0) continue;
      if (start.x + x < minX || start.x + x > maxX) continue;
      if (start.y + y < minY || start.y + y > maxY) continue;
      var directions = connectedSegments(grid[y][x]);
      if (directions.isEmpty) continue;
      directions.removeWhere((element) => (Point(x, y) + element) == start);
      if (directions.length == 1) startingPoints.addAll(directions);
    }
  }

  assert(startingPoints.length == 2);
  return (startingPoints[0], startingPoints[1]);
}

void main() {
  group('utils', () {
    test('find start', () {
      var expected = Point(0, 2);

      expect(findStartingPipe(complicatedExample)).toEqual(expected);
    });
    test('error on missing start', () {
      var badInput = complicatedExample.replaceAll("S", "8");

      expect(() => findStartingPipe(badInput)).throws.isException();
    });
  });
}
