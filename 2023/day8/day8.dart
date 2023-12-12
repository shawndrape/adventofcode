import 'package:async/async.dart';
import 'package:spec/spec.dart';

var exampleInput = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)""";

parseInput(Stream<String> inputLines) async {
  var queue = StreamQueue<String>(inputLines);
  var transitionRules = await queue.next;
  assert(await queue.next == "");
  var nodeMap = <String, ({String l, String r})>{};
  var matcher = RegExp(r'(\w+) = \((\w+), (\w+)\)');
  await for (var line in queue.rest) {
    var match = matcher.firstMatch(line)!;
    var [nodeName, leftTransition, rightTransition] = match.groups([1, 2, 3]);
    nodeMap[nodeName!] = (l: leftTransition!, r: rightTransition!);
  }
  return (transitionRules, nodeMap);
}

void main() async {
  group('core utils', () {
    test('input parsing', () async {
      var (ordering, nodes) =
          await parseInput(Stream.fromIterable(exampleInput.split('\n')));

      expect(ordering).toEqual("LLR");
      expect(nodes).toEqual({
        "AAA": (l: "BBB", r: "BBB"),
        "BBB": (l: "AAA", r: "ZZZ"),
        "ZZZ": (l: "ZZZ", r: "ZZZ"),
      });
    });
  });
}
