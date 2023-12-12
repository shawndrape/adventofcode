import 'dart:io';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

String cardOrdering = "AKQJT98765432";
String cardOrderingWithJokers = "AKQT98765432J";

enum HandType {
  unknown,
  highCard,
  onePair,
  twoPair,
  threeKind,
  fullHouse,
  fourKind,
  fiveKind
}

class Hand implements Comparable<Hand> {
  String cards;
  int bid;
  bool usingJokers;

  Hand(this.cards, [this.bid = 0, this.usingJokers = false])
      : assert(
            cards.split('').every((element) => cardOrdering.contains(element)),
            'Invalid Hand'),
        assert(cards.length == 5, 'Not enough cards');

  bool get hasJokers => usingJokers && cards.contains("J");

  int get numOfJokers => cards.split("").where((e) => e == "J").length;

  //general approach: make a map of the characters and determine based on
  // counts and lengths in map
  HandType get type {
    return !hasJokers
        ? _handAnalyzerWithoutJokers()
        : _handAnalyzerWithJokers();
  }

  HandType _handAnalyzerWithoutJokers() {
    var charCount = <String, int>{};
    cards.split('').forEach((e) {
      charCount[e] = (charCount[e] ?? 0) + 1;
    });
    var combinations = charCount.values.toList();
    combinations.sort();
    switch (combinations.reversed.toList()) {
      case [5]:
        return HandType.fiveKind;
      case [4, 1]:
        return HandType.fourKind;
      case [3, 2]:
        return HandType.fullHouse;
      case [3, 1, 1]:
        return HandType.threeKind;
      case [2, 2, 1]:
        return HandType.twoPair;
      case [2, 1, 1, 1]:
        return HandType.onePair;
      case [1, 1, 1, 1, 1]:
        return HandType.highCard;
      default:
        return HandType.unknown;
    }
  }

  HandType _handAnalyzerWithJokers() {
    if (cards == "JJJJJ") return HandType.fiveKind;
    var charCount = <String, int>{};
    cards.split('').forEach((e) {
      charCount[e] = (charCount[e] ?? 0) + 1;
    });
    var currentNumOfJokers = charCount.remove("J") ?? 0;
    String mostFrequentCard = '';
    var highestCount = 0;
    for (var MapEntry(:key, :value) in charCount.entries) {
      if (value > highestCount) {
        mostFrequentCard = key;
        highestCount = value;
      }
    }
    charCount[mostFrequentCard] =
        charCount[mostFrequentCard]! + currentNumOfJokers;

    var combinations = charCount.values.toList();
    combinations.sort();
    switch (combinations.reversed.toList()) {
      case [5]:
        return HandType.fiveKind;
      case [4, 1]:
        return HandType.fourKind;
      case [3, 2]:
        return HandType.fullHouse;
      case [3, 1, 1]:
        return HandType.threeKind;
      case [2, 2, 1]:
        return HandType.twoPair;
      case [2, 1, 1, 1]:
        return HandType.onePair;
      case [1, 1, 1, 1, 1]:
        return HandType.highCard;
      default:
        return HandType.unknown;
    }
  }

  @override
  int compareTo(Hand other) {
    //reject mismatched joker rules
    assert(usingJokers == other.usingJokers,
        'Can not compare joker and non-joker rules');
    //same hand
    if (cards == other.cards) return 0;
    //rank hand type
    if (type != other.type) return other.type.index - type.index;
    //compare card ordering
    var orderingToUse = usingJokers ? cardOrderingWithJokers : cardOrdering;
    var orderingReversed = orderingToUse.split('').reversed.join();
    var index = 0;
    try {
      while (cards[index] == other.cards[index]) {
        index++;
      }
      return orderingReversed.indexOf(other.cards[index]) -
          orderingReversed.indexOf(cards[index]);
    } on RangeError {
      //if we exceeded indexes without finding different values, the hands are equal
      return 0;
    }
  }
}

var exampleInput = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""";

void main() {
  group('core Hand', () {
    test('compareTo higher', () {
      expect(Hand("AJ222").compareTo(Hand("A9222"))).lessThan(0);
    });
    test('compareTo lower', () {
      expect(Hand("A9222").compareTo(Hand("AJ222"))).greaterThan(0);
    });
    test('compareTo equal', () {
      expect(Hand("AK222").compareTo(Hand("AK222"))).toBe(0);
    });
    for (var e in [
      ("AAAAA", HandType.fiveKind),
      ("KKKJJ", HandType.fullHouse),
      ("98877", HandType.twoPair),
      ("98765", HandType.highCard),
      ("AKKKK", HandType.fourKind),
      ("AKKKT", HandType.threeKind),
      ("8K768", HandType.onePair),
    ]) {
      test('hand ${e.$1} has type ${e.$2}', () {
        expect(Hand(e.$1).type).toBe(e.$2);
      });
    }
  });
  group('part 1', () {
    test('example', () {
      var hands = exampleInput.split('\n').map((e) {
        var [cards, bid] = e.split(" ");
        return Hand(cards, int.parse(bid));
      }).toList();

      hands.sort();
      var winnings = hands.reversed.foldIndexed(0,
          (index, previous, element) => ((index + 1) * element.bid) + previous);

      expect(winnings).toEqual(6440);
    });
    test('input file', () async {
      var file = File('day7_input.txt');
      var lines = await file.readAsLines();

      var hands = lines.map((e) {
        var [cards, bid] = e.split(" ");
        return Hand(cards, int.parse(bid));
      }).toList();

      hands.sort();
      var winnings = hands.reversed.foldIndexed(0,
          (index, previous, element) => ((index + 1) * element.bid) + previous);

      expect(winnings).toEqual(252052080);
    });
  });
  group('part 2', () {
    test('example', () {
      var hands = exampleInput.split('\n').map((e) {
        var [cards, bid] = e.split(" ");
        return Hand(cards, int.parse(bid), true);
      }).toList();

      hands.sort();
      var winnings = hands.reversed.foldIndexed(0,
          (index, previous, element) => ((index + 1) * element.bid) + previous);

      expect(winnings).toEqual(5905);
    });
    test('input file', () async {
      var file = File('day7_input.txt');
      var lines = await file.readAsLines();

      var hands = lines.map((e) {
        var [cards, bid] = e.split(" ");
        return Hand(cards, int.parse(bid), true);
      }).toList();

      hands.sort();
      var winnings = hands.reversed.foldIndexed(0,
          (index, previous, element) => ((index + 1) * element.bid) + previous);

      expect(winnings).toEqual(252898370);
    });
  });
}
