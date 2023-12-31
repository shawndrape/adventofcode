import 'dart:io';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

var exampleInput = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45""";

int extrapolateNextValue(List<int> series) {
  var currentList = series;
  var lastElementPerRecurse = <int>[];
  while (currentList.every((e) => e == 0) == false) {
    lastElementPerRecurse.add(currentList.last);
    currentList = reduceListBySubtraction(currentList);
  }
  return lastElementPerRecurse.sum;
}

int extrapolatePrevValue(List<int> series) {
  var currentList = series;
  var firstElementPerRecurse = <int>[];
  while (currentList.every((e) => e == 0) == false) {
    firstElementPerRecurse.add(currentList.first);
    currentList = reduceListBySubtraction(currentList);
  }
  return firstElementPerRecurse.reversed.reduce((prev, curr) => curr - prev);
}

List<int> reduceListBySubtraction(List<int> list) =>
    [for (var i = 0; i < list.length - 1; i++) list[i + 1] - list[i]];

void main() {
  group('part 1', () {
    test('example', () {
      var expected = [18, 28, 68];

      var actual = exampleInput
          .split("\n")
          .map((e) => e.split(" ").map(int.parse).toList())
          .map((e) => extrapolateNextValue(e));

      expect(actual).toEqual(expected);
    });
    test('handle descending', () {
      expect(extrapolateNextValue([10, 7, 4, 1, -2])).toEqual(-5);
    });
    test('input file', () async {
      var file = File('day09_input.txt');
      var lines = await file.readAsLines();

      var actual = lines
          .map((e) => e.split(" ").map(int.parse).toList())
          .map((e) => extrapolateNextValue(e));

      expect(actual.sum).toEqual(1725987467);
    });
  });
  group('part 2', () {
    test('example', () {
      var actual = extrapolatePrevValue([1, 3, 6, 10, 15, 21]);

      expect(actual).toEqual(0);
    });
    test('extended example', () {
      var expected = [-3, 0, 5];

      var actual = exampleInput
          .split("\n")
          .map((e) => e.split(" ").map(int.parse).toList())
          .map((e) => extrapolatePrevValue(e));

      expect(actual).toEqual(expected);
    });
    test('input file', () async {
      var file = File('day09_input.txt');
      var lines = await file.readAsLines();

      var actual = lines
          .map((e) => e.split(" ").map(int.parse).toList())
          .map((e) => extrapolatePrevValue(e));

      expect(actual.sum).not.toEqual(0);
      expect(actual.sum).lessThan(1261);
      expect(actual.sum).toBe(971);
    });
  });
}
