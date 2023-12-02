import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
//   group('Trebuchet - part 1', () {
//     /*
// --- Day 1: Trebuchet?! ---
// Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.

// You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.

// Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

// You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").

// As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.

// The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

// For example:

// 1abc2
// pqr3stu8vwx
// a1b2c3d4e5f
// treb7uchet

// In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

// Consider your entire calibration document. What is the sum of all of the calibration values?
// */
//     int calibrate(String value) {
//       final stripped_numbers = value.replaceAll(RegExp(r'[a-z]'), '');
//       final List<int> digits =
//           stripped_numbers.split('').map(int.parse).toList();
//       if (digits.length < 1) {
//         throw Exception('No number found');
//       }
//       if (digits.length == 1) {
//         return int.parse("${digits.first}${digits.first}");
//       }
//       return int.parse("${digits.first}${digits.last}");
//     }

//     test('calibration passed for example values', () {
//       var example_inputs = <String>[
//         '1abc2',
//         'pqr3stu8vwx',
//         'a1b2c3d4e5f',
//         'treb7uchet'
//       ];

//       var target_values = [12, 38, 15, 77];

//       var calibrated_values = example_inputs.map(calibrate);

//       expect(calibrated_values, equals(target_values));
//     });

//     test('calibration passes for input file', () async {
//       final expected_calibration_sum = 55172;

//       final input = File('day1/day1_input.txt');
//       final lines =
//           input.openRead().transform(utf8.decoder).transform(LineSplitter());
//       var calibration_sum = 0;
//       try {
//         await for (var line in lines) {
//           var calibrated_value = calibrate(line);
//           calibration_sum += calibrated_value;
//         }
//       } catch (e) {
//         print('oops: $e');
//       }
//       expect(calibration_sum, equals(expected_calibration_sum));
//     });
//   });

  group('Trebuchet - part 2', () {
    /* 
    --- Part Two ---
Your calculation isn't quite right. It looks like some of the digits are 
actually spelled out with letters: 
one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".

Equipped with this new information, you now need to find the real first and last digit on each line. For example:

two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen

In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.
    */
    int? word_to_digit(String value) => switch (value) {
          "one" => 1,
          "two" => 2,
          "three" => 3,
          "four" => 4,
          "five" => 5,
          "six" => 6,
          "seven" => 7,
          "eight" => 8,
          "nine" => 9,
          _ => int.tryParse(value)
        };

    String convert_digits(String value) {
      var string_buffer = "";
      var result_string = "";

      var matcher =
          RegExp(r'.*(\d|one|two|three|four|five|six|seven|eight|nine)');

      for (var char in value.split("")) {
        string_buffer += char;
        var match = matcher.firstMatch(string_buffer);
        if (match == null) continue;
        // result_string +=
        //     string_buffer.replaceFirst(match[1]!, word_to_digit(match[1]!));
        string_buffer = "";
      }

      return result_string + string_buffer;
    }

    List<int> extract_digits(String value) {
      print("processing $value");
      var results = <int>[];
      var matcher =
          RegExp(r'.*?(\d|one|two|four|five|six|seven|eight|three|nine).*');
      print('starting loop');
      for (var x = 0; x < value.length; x++) {
        print('X is $x');
        var match = matcher.matchAsPrefix(value, x);
        if (match == null) break;
        String match_text = match[1]!;
        print('found match of: $match_text');
        var match_value = word_to_digit(match_text);
        if (match_value == null)
          throw Exception('Found a non-digit in $match_text');

        results.add(match_value);
        var chars_to_skip = value.substring(x).indexOf(match_text);
        print("$match_text starts at position ${x + chars_to_skip} in $value");
        x += chars_to_skip;
      }
      return results;
    }

    int calibrate(String value) {
      final List<int> digits = extract_digits(value);
      print("found digits: $digits");
      if (digits.length < 1) {
        throw Exception('No number found: $digits from value $value');
      }
      if (digits.length == 1) {
        return int.parse("${digits.first}${digits.first}");
      }
      return int.parse("${digits.first}${digits.last}");
    }

    test('calibration passed for example values', () {
      final example_inputs = [
        'two1nine',
        'eightwothree',
        'abcone2threexyz',
        'xtwone3four',
        '4nineeightseven2',
        'zoneight234',
        '7pqrstsixteen',
      ];

      final expected_calibrations = [29, 83, 13, 24, 42, 14, 76];

      var calibrated_values = example_inputs.map(calibrate);

      expect(calibrated_values, equals(expected_calibrations));
      expect(calibrated_values.reduce((value, element) => value + element),
          equals(281));
    });

    test('hint from reddit thread', () {
      expect(calibrate('eighthree'), equals(83));
      expect(calibrate('oneighthree'), equals(13));
    });

    test('additional samples from test file', () {
      var values = [
        'fivefourcxdfgbtnhmscdlsrnnljvgjlthree1f',
        '4hsgqrzthtk',
        '3ninez24',
        'k9qgqsbbqdsj44tr',
        'djcsxdmd6jrgtmxpk5onegrljnflbhmnnx',
        'sxxrhpkpclbjms3jq',
        '8ngmpfiveoneninerpbscdgjxztkzldcjbrk',
        '637zbrfpsvhj2hzmvx',
        '4eight6chc6',
        '5one9nine',
        '7sevengqrqztfvmhkqnjveightl2twovtgdlhv',
        'twosixeighteightmm62',
        'zlbtcjgninevbctrmsqkqkkjmvcfthnfvnl4',
        'fivesjmgr7two',
      ];

      var expected_calibrations = [
        51,
        44,
        34,
        94,
        61,
        33,
        89,
        62,
        46,
        59,
        72,
        22,
        94,
        52
      ];

      expect(expected_calibrations, values.map(calibrate));
    });

    test('calibration passes for input file', () async {
      final expected_calibration_sum = 54925;

      final input = File('day1/day1_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());
      var calibration_sum = 0;
      try {
        await for (var line in lines) {
          var calibrated_value = calibrate(line);
          assert(calibrated_value < 100);
          calibration_sum += calibrated_value;
        }
      } catch (e) {
        print('oops: $e');
      }

      expect(calibration_sum, lessThan(54953));
      expect(calibration_sum, equals(expected_calibration_sum));
    });
  });
}
