/*
--- Day 1: Trebuchet?! ---
Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.

You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").

As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.

The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

For example:

1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet

In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

Consider your entire calibration document. What is the sum of all of the calibration values?
*/

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('calibration passed for example values', () {
    var example_inputs = <String>[
      '1abc2',
      'pqr3stu8vwx',
      'a1b2c3d4e5f',
      'treb7uchet'
    ];

    var target_values = [12, 38, 15, 77];

    var calibrated_values = example_inputs.map(calibrate);

    expect(calibrated_values, equals(target_values));
  });

  test('calibration passes for input file', () async {
    final expected_calibration_sum = 55172;

    final input = File('day1_input.txt');
    final lines =
        input.openRead().transform(utf8.decoder).transform(LineSplitter());
    var calibration_sum = 0;
    try {
      await for (var line in lines) {
        var calibrated_value = calibrate(line);
        calibration_sum += calibrated_value;
      }
    } catch (e) {
      print('oops: $e');
    }
    expect(calibration_sum, equals(expected_calibration_sum));
  });
}

int calibrate(String value) {
  final stripped_numbers = value.replaceAll(RegExp(r'[a-z]'), '');
  final List<int> digits = stripped_numbers.split('').map(int.parse).toList();
  if (digits.length < 1) {
    throw Exception('No number found');
  }
  if (digits.length == 1) {
    return int.parse("${digits.first}${digits.first}");
  }
  return int.parse("${digits.first}${digits.last}");
}
