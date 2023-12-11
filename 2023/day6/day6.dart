import 'package:spec/spec.dart';

var example_input = {
  1: (time: 7, dist: 9),
  2: (time: 15, dist: 40),
  3: (time: 30, dist: 200),
};

/*
Time:        45     98     83     73
Distance:   295   1734   1278   1210
*/
var input_file = {
  (time: 45, dist: 295),
  (time: 98, dist: 1734),
  (time: 83, dist: 1278),
  (time: 73, dist: 1210),
};

distanceFromLength(int time, int length) => (time - length) * length;

({int min, int max}) minAndMaxButtonLengthForRace(int time, int dist) {
  var min_button_length, max_button_length;
  for (var len = 1; len < time; len++) {
    if (distanceFromLength(time, len) > dist) {
      min_button_length = len;
      break;
    }
  }

  for (var len = time - 1; len >= 1; len--) {
    if (distanceFromLength(time, len) > dist) {
      max_button_length = len;
      break;
    }
  }

  return (min: min_button_length, max: max_button_length);
}

void main() {
  group('part 1', () {
    test('example', () {
      var expected = {
        1: (min: 2, max: 5),
        2: (min: 4, max: 11),
        3: (min: 11, max: 19)
      };

      for (var MapEntry(:key, value: race_details) in example_input.entries) {
        expect(minAndMaxButtonLengthForRace(
                race_details.time, race_details.dist))
            .toEqual(expected[key]!);
      }

      var error_margin = example_input.values
          .map((e) => minAndMaxButtonLengthForRace(e.time, e.dist))
          .fold(1, (previousValue, e) => previousValue * (e.max - e.min + 1));

      expect(error_margin).toEqual(288);
    });
    test('input file', () {
      var error_margin = input_file
          .map((e) => minAndMaxButtonLengthForRace(e.time, e.dist))
          .fold(1, (previousValue, e) => previousValue * (e.max - e.min + 1));

      expect(error_margin).toEqual(1413720);
    });
    group('part 2', () {
      test('example', () {
        var single_race = (time: 71530, dist: 940200);

        var (min: min_len, max: max_len) =
            minAndMaxButtonLengthForRace(single_race.time, single_race.dist);
        var error_margin = max_len - min_len + 1;

        expect(error_margin).toEqual(71503);
      });
      test('input file', () {
        var single_race = (time: 45988373, dist: 295173412781210);

        var (min: min_len, max: max_len) =
            minAndMaxButtonLengthForRace(single_race.time, single_race.dist);
        var error_margin = max_len - min_len + 1;

        expect(error_margin).toEqual(30565288);
      });
    });
  });
}
