import 'package:test/test.dart';

class Game {
  int id;
  List<({int red, int green, int blue})> matches;

  Game(this.id, this.matches);

  factory Game.fromLine(String summary) {
    var [ident, matches] = summary.split(":");
    //TODO - parse these properly
    return Game(2, [(red: 1, green: 2, blue: 0)]);
  }

  bool meetsConstraint(({int red, int green, int blue}) constraint) {
    return true;
  }
}

void main() {
  group('Part 1', () {
    /* 
      Conditions:
      No more than 12 red cubes, 13 green cubes, or 14 blue cubes
    */

    var limit = (red: 12, green: 13, blue: 14);

    test('from example', () {
      var example_lines = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
      """;

      for (var line in example_lines.split("\n")) {
        print(line.trim());
      }
    });
  });
}
