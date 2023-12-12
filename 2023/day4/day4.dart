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
  var gameId = int.parse(title.replaceFirst(RegExp(r"Card\s+"), ""));

  var [winningNumbers, chosenNumbers] = details.split("|");
  var winningInts =
      winningNumbers.trim().split(RegExp(r'\s+')).map(int.parse).toSet();
  var matches = chosenNumbers
      .trim()
      .split(RegExp(r'\s+'))
      .map(int.parse)
      .where((element) => winningInts.contains(element))
      .length;

  return (game: gameId, matches: matches, score: pointsForGame(matches));
}

class Card {
  int id;
  Set<int> winningNumbers;
  List<int> chosenNumbers;

  Card(this.id, this.winningNumbers, this.chosenNumbers);

  factory Card.fromLine(String cardLine) {
    var [title, details] = cardLine.split(":");
    var gameId = int.parse(title.replaceFirst(RegExp(r"Card\s+"), ""));

    var [winningNumbers, chosenNumbers] = details.split("|");
    var winningInts =
        winningNumbers.trim().split(RegExp(r'\s+')).map(int.parse).toSet();
    var chosenInts =
        chosenNumbers.trim().split(RegExp(r'\s+')).map(int.parse).toList();
    return Card(gameId, winningInts, chosenInts);
  }

  int get matches =>
      chosenNumbers.where((e) => winningNumbers.contains(e)).length;

  List<int> get additionalCards =>
      [for (var i = id + 1; i <= id + matches; i++) i];
}

void main() {
  group('part 1', () {
    test('example', () {
      var expectedWinnings = [8, 2, 2, 1, 0, 0];

      var results = example.split("\n").map(getWinnings).map((e) => e.score);

      expect(results).toEqual(expectedWinnings);
      expect(results.sum).toBe(13);
    });
    test('input file', () async {
      var input = File('day4_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var cardWinningSum = 0;
      await for (var card in lines) {
        cardWinningSum += getWinnings(card).score;
      }

      expect(cardWinningSum).greaterThan(472);
      expect(cardWinningSum).toBe(22488);
    });
  });
  group('part 2', () {
    Stream<String> asyncExample() async* {
      for (var line in example.split("\n")) {
        yield line;
      }
    }

    test('example', () async {
      Map<int, int> cardCounts = await countCards(asyncExample());

      var expected = {
        1: 1,
        2: 2,
        3: 4,
        4: 8,
        5: 14,
        6: 1,
      };

      expect(cardCounts).toEqual(expected);
      expect(cardCounts.values.sum).toBe(30);
    });

    test('input file', () async {
      var input = File('day4_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var cardCounts = await countCards(lines);

      expect(cardCounts.values.sum).toBe(7013204);
    });
  });
}

Future<Map<int, int>> countCards(Stream<String> cardSummary) async {
  var cardCounts = <int, int>{};

  await for (var line in cardSummary) {
    var card = Card.fromLine(line);
    cardCounts[card.id] ??= 1;
    var numOfCards = cardCounts[card.id]!;
    for (var wonCard in card.additionalCards) {
      cardCounts[wonCard] = (cardCounts[wonCard] ?? 1) + numOfCards;
    }
  }
  return cardCounts;
}
