import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:spec/spec.dart';

Future<(Iterable<String>, String, Map<String, ({String l, String r})>)>
    parseInput(Stream<String> inputLines) async {
  var queue = StreamQueue<String>(inputLines);
  var transitionRules = await queue.next;
  assert(await queue.next == "");
  var nodeMap = <String, ({String l, String r})>{};
  var matcher = RegExp(r'(\w+) = \((\w+), (\w+)\)');
  String? startingNode;
  await for (var line in queue.rest) {
    var match = matcher.firstMatch(line)!;
    var [nodeName, leftTransition, rightTransition] =
        match.groups([1, 2, 3]).map((e) => e!).toList();
    nodeMap[nodeName] = (l: leftTransition, r: rightTransition);
    startingNode ??= nodeName;
  }
  if (startingNode == null || nodeMap.isEmpty) {
    throw Exception("Not enough lines in input to generate node map");
  }
  return (endlessTransitions(transitionRules), startingNode, nodeMap);
}

Iterable<String> endlessTransitions(String transitionRules) sync* {
  while (true) {
    yield* transitionRules.split("");
  }
}

Future<int> walkPathToTarget(Stream<String> pathData, String targetNode) async {
  var (ordering, _, nodes) = await parseInput(pathData);
  var currentNode = "AAA";

  var stepCounter = 0, iter = ordering.iterator;
  while (currentNode != targetNode && iter.moveNext()) {
    var nextStep = iter.current;
    var stepOptions = nodes[currentNode];
    if (stepOptions == null) throw Exception("Broken path detected");
    currentNode = switch (nextStep) {
      "L" => stepOptions.l,
      "R" => stepOptions.r,
      _ => throw FormatException("Invalid"),
    };
    stepCounter++;
  }
  return stepCounter;
}

Future<int> walkPathToTargetPart2(Stream<String> pathData) async {
  var (ordering, _, nodes) = await parseInput(pathData);
  //get the starting set of nodes
  var currentNodes = nodes.keys.where((element) => element.endsWith("A"));
  print('starting with nodes $currentNodes');

  allEndWithZ(Iterable<String> l) => l.every((e) => e.endsWith("Z"));

  // TODO - run through each node in starting set solo, then find Lowest Common Multiple

  var stepCounter = 0, iter = ordering.iterator;
  while (!allEndWithZ(currentNodes) && iter.moveNext()) {
    var nextStep = iter.current;
    currentNodes = currentNodes.map((currentNode) {
      var stepOptions = nodes[currentNode];
      if (stepOptions == null) throw Exception("Broken path detected");
      return switch (nextStep) {
        "L" => stepOptions.l,
        "R" => stepOptions.r,
        _ => throw FormatException("Invalid"),
      };
    }).toList();

    print(stepCounter++);
  }
  print(currentNodes);
  return stepCounter;
}

void main() async {
  group('core utils', () {
    var exampleInput = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)""";
    test('input parsing', () async {
      var (ordering, _, nodes) =
          await parseInput(Stream.fromIterable(exampleInput.split('\n')));

      expect(ordering.take(3).join()).toEqual("LLR");
      expect(ordering.take(5).join()).toEqual("LLRLL");
      expect(nodes).toEqual({
        "AAA": (l: "BBB", r: "BBB"),
        "BBB": (l: "AAA", r: "ZZZ"),
        "ZZZ": (l: "ZZZ", r: "ZZZ"),
      });
    });
  });
  group('part 1', () {
    var exampleInput = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)""";
    test('example', () async {
      var lines = Stream.fromIterable(exampleInput.split('\n'));
      int stepCounter = await walkPathToTarget(lines, "ZZZ");

      expect(stepCounter).toEqual(6);
    });
    test('input file', () async {
      var file = File('day8_input.txt');
      final lines =
          file.openRead().transform(utf8.decoder).transform(LineSplitter());
      int stepCounter = await walkPathToTarget(lines, "ZZZ");

      expect(stepCounter).toBe(19783);
    });
  });
  group('part 2', () {
    var exampleInput = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)""";
    test('example', () async {
      var lines = Stream.fromIterable(exampleInput.split('\n'));
      int stepCounter = await walkPathToTargetPart2(lines);

      expect(stepCounter).toEqual(6);
    });
    test('input file', () async {
      var file = File('day8_input.txt');
      final lines =
          file.openRead().transform(utf8.decoder).transform(LineSplitter());
      int stepCounter = await walkPathToTargetPart2(lines);

      //checked this value as the process was running to see if we may have overshot
      expect(stepCounter).greaterThan(6000000);
      expect(stepCounter).greaterThan(12000000);
      expect(stepCounter).greaterThan(25000000);
      //also tried 40M but it didn't confirm higher or lower. And I have a longer timeout

      //console log stopped printing at 88710214, but not the right answer either

      expect(stepCounter).toBe(19783);
    });
  });
}
