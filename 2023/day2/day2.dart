import 'dart:convert';
import 'dart:io';

import 'package:spec/spec.dart';

class Game {
  int id;
  Iterable<({int red, int green, int blue})> matches;

  Game(this.id, this.matches);

  factory Game.fromLine(String summary) {
    var [ident, matches] = summary.split(":");

    var id_match = RegExp(r'Game (\d*)').matchAsPrefix(ident);
    if (id_match == null) throw Exception("Game ID not found");

    var match_descriptions = matches.split(";").map((e) => e.trim());

    return Game(
        int.parse(id_match[1]!), match_descriptions.map(_constructRecord));
  }

  bool meetsConstraint(({int red, int green, int blue}) constraint) {
    return matches.every((element) => switch (element) {
          (:int red, :int green, :int blue)
              when (red <= constraint.red) &
                  (green <= constraint.green) &
                  (blue <= constraint.blue) =>
            true,
          _ => false
        });
  }

  static ({int red, int green, int blue}) _constructRecord(String match) {
    //find red
    var red_value = RegExp(r'.*?(\d+) red.*').firstMatch(match);
    //find blue
    var blue_value = RegExp(r'.*?(\d+) blue.*').firstMatch(match);
    //find green
    var green_value = RegExp(r'.*?(\d+) green.*').firstMatch(match);

    return (
      red: int.tryParse(red_value?[1] ?? '') ?? 0,
      blue: int.tryParse(blue_value?[1] ?? '') ?? 0,
      green: int.tryParse(green_value?[1] ?? '') ?? 0
    );
  }
}

void main() {
  group('core', () {
    var game = Game.fromLine(
        'Game 30: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red');
    test('factory finds id correctly', () {
      expect(game.id).toEqual(30);
    });
    test('factory finds matches correctly', () {
      var expected = [
        (green: 8, blue: 6, red: 20),
        (blue: 5, red: 4, green: 13),
        (green: 5, red: 1, blue: 0)
      ];

      expect(game.matches).toEqual(expected);
    });
  });
  group('Part 1', () {
    /* 
      Conditions:
      No more than 12 red cubes, 13 green cubes, or 14 blue cubes
    */

    var limit = (red: 12, green: 13, blue: 14);

    test('from example', () {
      var example_lines =
          """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green""";

      var games = example_lines.split('\n').map(Game.fromLine);
      var valid_games =
          games.where((element) => element.meetsConstraint(limit));
      expect(valid_games
          .map((e) => e.id)
          .reduce((value, element) => value + element)).toEqual(8);
    });

    test('from input file', () async {
      final input = File('day2/day2_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var valid_games_sum = 0;

      try {
        await for (var line in lines) {
          var game = Game.fromLine(line);
          if (game.meetsConstraint(limit)) valid_games_sum += game.id;
        }
      } catch (e) {
        print('oops: $e');
      }

      expect(valid_games_sum).toEqual(2541);
    });
  });
}
