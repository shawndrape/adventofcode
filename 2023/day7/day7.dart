import 'package:spec/spec.dart';

String card_ordering = "AKQJT98765432";

enum HandType {
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

  Hand(this.cards, this.bid)
      : assert(
            cards.split('').every((element) => card_ordering.contains(element)),
            'Invalid Hand');

  HandType get type {
    return HandType.HighCard;
  }

  @override
  int compareTo(Hand other) {
    //same hand
    if (this.cards == other.cards) return 0;
    //rank hand type
    if (this.type != other.type) return other.type.index - this.type.index;
    //compare card ordering
    var ordering_reversed = card_ordering.split('').reversed.join();
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
      expect(Hand("AJ", 0).compareTo(Hand("A9", 0))).lessThan(0);
    });
    test('compareTo lower', () {
      expect(Hand("A9", 0).compareTo(Hand("AJ", 0))).greaterThan(0);
    });
    test('compareTo equal', () {
      expect(Hand("AK", 0).compareTo(Hand("AK", 0))).toBe(0);
    });
  });
}
