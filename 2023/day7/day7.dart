import 'dart:io';

import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

String card_ordering = "AKQJT98765432";
String card_ordering_with_jokers = "AKQT98765432J";

enum HandType {
  Unknown,
  HighCard,
  OnePair,
  TwoPair,
  ThreeKind,
  FullHouse,
  FourKind,
  FiveKind
}

class Hand implements Comparable<Hand> {
  String cards;
  int bid;
  bool using_jokers;

  Hand(this.cards, [this.bid = 0, this.using_jokers = false])
      : assert(
            cards.split('').every((element) => card_ordering.contains(element)),
            'Invalid Hand'),
        assert(cards.length == 5, 'Not enough cards');

  bool get hand_has_jokers => using_jokers && cards.contains("J");

  int get num_of_jokers => cards.split("").where((e) => e == "J").length;

  //general approach: make a map of the characters and determine based on
  // counts and lengths in map
  HandType get type {
    return !hand_has_jokers
        ? _handAnalyzerWithoutJokers()
        : _handAnalyzerWithJokers();
  }

  HandType _handAnalyzerWithoutJokers() {
    var char_count = <String, int>{};
    cards.split('').forEach((e) {
      char_count[e] = (char_count[e] ?? 0) + 1;
    });
    var combinations = char_count.values.toList();
    combinations.sort();
    switch (combinations.reversed.toList()) {
      case [5]:
        return HandType.FiveKind;
      case [4, 1]:
        return HandType.FourKind;
      case [3, 2]:
        return HandType.FullHouse;
      case [3, 1, 1]:
        return HandType.ThreeKind;
      case [2, 2, 1]:
        return HandType.TwoPair;
      case [2, 1, 1, 1]:
        return HandType.OnePair;
      case [1, 1, 1, 1, 1]:
        return HandType.HighCard;
      default:
        return HandType.Unknown;
    }
  }

  HandType _handAnalyzerWithJokers() {
    var char_count = <String, int>{};
    cards.split('').forEach((e) {
      char_count[e] = (char_count[e] ?? 0) + 1;
    });
    var current_num_of_jokers = char_count.remove("J") ?? 0;
    //TODO - pattern matching can't mix literals and variables, so go through
    //the char_count and add the jokers to the highest value remaining
    // Edge case: Oops all jokers
    var combinations = char_count.values.toList();
    combinations.sort();
    switch (combinations.reversed.toList()) {
      case [5]:
        return HandType.FiveKind;
      case [4, 1]:
        return HandType.FourKind;
      case [3, 2]:
        return HandType.FullHouse;
      case [3, 1, 1]:
        return HandType.ThreeKind;
      case [2, 2, 1]:
        return HandType.TwoPair;
      case [2, 1, 1, 1]:
        return HandType.OnePair;
      case [1, 1, 1, 1, 1]:
        return HandType.HighCard;
      default:
        return HandType.Unknown;
    }
  }

  @override
  int compareTo(Hand other) {
    //reject mismatched joker rules
    assert(using_jokers == other.using_jokers,
        'Can not compare joker and non-joker rules');
    //same hand
    if (this.cards == other.cards) return 0;
    //rank hand type
    if (this.type != other.type) return other.type.index - this.type.index;
    //compare card ordering
    var ordering_to_use =
        using_jokers ? card_ordering_with_jokers : card_ordering;
    var ordering_reversed = ordering_to_use.split('').reversed.join();
    var index = 0;
    try {
      while (this.cards[index] == other.cards[index]) index++;
      return ordering_reversed.indexOf(other.cards[index]) -
          ordering_reversed.indexOf(this.cards[index]);
    } on RangeError {
      //if we exceeded indexes without finding different values, the hands are equal
      return 0;
    }
  }
}

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
    [
      ("AAAAA", HandType.FiveKind),
      ("KKKJJ", HandType.FullHouse),
      ("98877", HandType.TwoPair),
      ("98765", HandType.HighCard),
      ("AKKKK", HandType.FourKind),
      ("AKKKT", HandType.ThreeKind),
      ("8K768", HandType.OnePair),
    ].forEach((e) {
      test('hand ${e.$1} has type ${e.$2}', () {
        expect(Hand(e.$1).type).toBe(e.$2);
      });
    });
  });
  group('part 1', () {
    var input = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""";
    test('example', () {
      var hands = input.split('\n').map((e) {
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
}
