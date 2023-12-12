import 'dart:convert';
import 'dart:io';

import 'package:spec/spec.dart';

class Game {
  int id;
  Iterable<({int red, int green, int blue})> rounds;

  Game(this.id, this.rounds);

  factory Game.fromLine(String summary) {
    var [ident, rounds] = summary.split(":");

    var idMatch = RegExp(r'Game (\d*)').matchAsPrefix(ident);
    if (idMatch == null) throw Exception("Game ID not found");

    var roundDescriptions = rounds.split(";").map((e) => e.trim());

    return Game(
        int.parse(idMatch[1]!), roundDescriptions.map(_constructRecord));
  }

  bool meetsConstraint(({int red, int green, int blue}) constraint) {
    return rounds.every((element) => switch (element) {
          (:int red, :int green, :int blue)
              when (red <= constraint.red) &
                  (green <= constraint.green) &
                  (blue <= constraint.blue) =>
            true,
          _ => false
        });
  }

  ({int red, int green, int blue}) smallestConstraint() {
    var minRed = 0, minGreen = 0, minBlue = 0;
    for (var round in rounds) {
      if (round.red > minRed) minRed = round.red;
      if (round.green > minGreen) minGreen = round.green;
      if (round.blue > minBlue) minBlue = round.blue;
    }
    return (red: minRed, green: minGreen, blue: minBlue);
  }

  static ({int red, int green, int blue}) _constructRecord(String round) {
    //find red
    var redValue = RegExp(r'.*?(\d+) red.*').firstMatch(round);
    //find blue
    var blueValue = RegExp(r'.*?(\d+) blue.*').firstMatch(round);
    //find green
    var greenValue = RegExp(r'.*?(\d+) green.*').firstMatch(round);

    return (
      red: int.tryParse(redValue?[1] ?? '') ?? 0,
      blue: int.tryParse(blueValue?[1] ?? '') ?? 0,
      green: int.tryParse(greenValue?[1] ?? '') ?? 0
    );
  }
}

var exampleLines = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green""";

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

      expect(game.rounds).toEqual(expected);
    });
  });
  group('Part 1', () {
    /* 
      Conditions:
      No more than 12 red cubes, 13 green cubes, or 14 blue cubes
    */

    var limit = (red: 12, green: 13, blue: 14);

    test('from example', () {
      var games = exampleLines.split('\n').map(Game.fromLine);
      var validGames = games.where((element) => element.meetsConstraint(limit));
      expect(validGames
          .map((e) => e.id)
          .reduce((value, element) => value + element)).toEqual(8);
    });

    test('from input file', () async {
      final input = File('day2_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var validGamesSum = 0;

      try {
        await for (var line in lines) {
          var game = Game.fromLine(line);
          if (game.meetsConstraint(limit)) validGamesSum += game.id;
        }
      } catch (e) {
        print('oops: $e');
      }

      expect(validGamesSum).toEqual(2541);
    });
  });
  group('Part 2', () {
    test('from example', () {
      var games = exampleLines.split('\n').map(Game.fromLine);
      var expectedMinimumPowers = [48, 12, 1560, 630, 36];

      var gamePowers = games
          .map((e) => e.smallestConstraint())
          .map((e) => e.red * e.blue * e.green);

      expect(gamePowers).toEqual(expectedMinimumPowers);
      expect(gamePowers.reduce((value, element) => value + element))
          .toEqual(2286);
    });
    test('from input', () async {
      final input = File('day2_input.txt');
      final lines =
          input.openRead().transform(utf8.decoder).transform(LineSplitter());

      var gamePowerSum = 0;

      try {
        await for (var line in lines) {
          var game = Game.fromLine(line);
          var c = game.smallestConstraint();
          var gamePower = c.red * c.green * c.blue;
          gamePowerSum += gamePower;
        }
      } catch (e) {
        print('oops: $e');
      }

      expect(gamePowerSum).toEqual(66016);
    });
  });
}
