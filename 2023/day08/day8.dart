import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:spec/spec.dart';

var exampleInput = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)""";

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
  if (startingNode == null || nodeMap.isEmpty)
    throw Exception("Not enough lines in input to generate node map");
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

void main() async {
  group('core utils', () {
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
    test('example', () async {
      int stepCounter = await walkPathToTarget(
          Stream.fromIterable(exampleInput.split('\n')), "ZZZ");

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
}
