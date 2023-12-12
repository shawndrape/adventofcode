import 'package:spec/spec.dart';

var exampleInput = {
  1: (time: 7, dist: 9),
  2: (time: 15, dist: 40),
  3: (time: 30, dist: 200),
};

/*
Time:        45     98     83     73
Distance:   295   1734   1278   1210
*/
var inputFile = {
  (time: 45, dist: 295),
  (time: 98, dist: 1734),
  (time: 83, dist: 1278),
  (time: 73, dist: 1210),
};

distanceFromLength(int time, int length) => (time - length) * length;

({int min, int max}) minAndMaxButtonLengthForRace(int time, int dist) {
  int minButtonLength = 0, maxButtonLength = 0;
  for (var len = 1; len < time; len++) {
    if (distanceFromLength(time, len) > dist) {
      minButtonLength = len;
      break;
    }
  }

  for (var len = time - 1; len >= 1; len--) {
    if (distanceFromLength(time, len) > dist) {
      maxButtonLength = len;
      break;
    }
  }

  return (min: minButtonLength, max: maxButtonLength);
}

void main() {
  group('part 1', () {
    test('example', () {
      var expected = {
        1: (min: 2, max: 5),
        2: (min: 4, max: 11),
        3: (min: 11, max: 19)
      };

      for (var MapEntry(:key, value: raceDetails) in exampleInput.entries) {
        expect(minAndMaxButtonLengthForRace(raceDetails.time, raceDetails.dist))
            .toEqual(expected[key]!);
      }

      var errorMargin = exampleInput.values
          .map((e) => minAndMaxButtonLengthForRace(e.time, e.dist))
          .fold(1, (previousValue, e) => previousValue * (e.max - e.min + 1));

      expect(errorMargin).toEqual(288);
    });
    test('input file', () {
      var errorMargin = inputFile
          .map((e) => minAndMaxButtonLengthForRace(e.time, e.dist))
          .fold(1, (previousValue, e) => previousValue * (e.max - e.min + 1));

      expect(errorMargin).toEqual(1413720);
    });
    group('part 2', () {
      test('example', () {
        var singleRace = (time: 71530, dist: 940200);

        var (min: minLength, max: maxLength) =
            minAndMaxButtonLengthForRace(singleRace.time, singleRace.dist);
        var errorMargin = maxLength - minLength + 1;

        expect(errorMargin).toEqual(71503);
      });
      test('input file', () {
        var singleRace = (time: 45988373, dist: 295173412781210);

        var (min: minLength, max: maxLength) =
            minAndMaxButtonLengthForRace(singleRace.time, singleRace.dist);
        var errorMargin = maxLength - minLength + 1;

        expect(errorMargin).toEqual(30565288);
      });
    });
  });
}
