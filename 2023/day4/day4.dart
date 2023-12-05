import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

int pointsForGame(int numMatches) => switch (numMatches) {
      <= 0 => 0,
      > 10 => 0,
      _ => pow(2, numMatches - 1).toInt(),
    };

var example = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""";

({int game, int matches, int score}) getWinnings(String card) {
  var [title, details] = card.split(":");
  var game_id = int.parse(title.replaceFirst(RegExp(r"Card\s+"), ""));

  var [winning_numbers, chosen_numbers] = details.split("|");
  var winning_ints =
      winning_numbers.trim().split(RegExp(r'\s+')).map(int.parse).toSet();
  var matches = chosen_numbers
      .trim()
      .split(RegExp(r'\s+'))
      .map(int.parse)
      .where((element) => winning_ints.contains(element))
      .length;

  return (game: game_id, matches: matches, score: pointsForGame(matches));
}

void main() {
  group('part 1', () {
    test('example', () {
      var expected_winnings = [8, 2, 2, 1, 0, 0];

      var results = example.split("\n").map(getWinnings).map((e) => e.score);

      expect(results).toEqual(expected_winnings);
      expect(results.sum).toBe(13);
    });
    test('input file', () async {
      var input = File('day4_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var card_winning_sum = 0;
      await for (var card in lines) {
        card_winning_sum += getWinnings(card).score;
      }

      expect(card_winning_sum).greaterThan(472);
      expect(card_winning_sum).toBe(22488);
    });
  });
}
