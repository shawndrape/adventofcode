import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

var exampleInput = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1""";

extension on String {
  String trimOperationalNodes() => replaceAll(RegExp(r'^\.+|\.+$'), '');
}

bool isValidGrouping(String field, List<int> groups) {
  if (field.contains("?")) {
    throw ArgumentError.value(
        field, 'field', 'Can not contain unknown (?) nodes');
  }
  var validGroupsPattern = RegExp(r'#+');
  var matches = validGroupsPattern.allMatches(field);
  var discoveredGroups = [for (var match in matches) match[0]!.length];
  return ListEquality().equals(groups, discoveredGroups);
}

int countPossibleConfigurations(String field, List<int> brokenGroups) {
  //the confirmed broken groups can tell us the minimum length required to
  //fullfil the requirements
  var brokenGroupsLength = brokenGroups.sum + brokenGroups.length - 1;
  var fieldTrimmed = field.trimOperationalNodes();
  var wiggleRoom = fieldTrimmed.length - brokenGroupsLength;
  print('pattern has $wiggleRoom slots wiggle room');
  if (wiggleRoom <= 0) return 1;

  //there is a viable strategy here to remove fully confirmed groups
  //based on their large size and the recursively process the rest of the field

  var viableGroupsPattern = RegExp(r'([\?#]+)');
  print('processing $field as $fieldTrimmed');
  var matches = viableGroupsPattern.allMatches(fieldTrimmed);
  if (matches.length == brokenGroups.length) {
    print('confirmed contiguous groups');
  } else {
    print('fewer groups found than known. Some ? are functional');
  }
  for (var match in matches) {
    print("Found pattern from ${match.start} to ${match.end}");
    print("Contains group: ${match[1]}");
  }
  return 0;
}

void main() {
  group(solo: true, 'utils', () {
    test('trim the known operational nodes on ends of field', () {
      expect("...#?#...".trimOperationalNodes()).toEqual("#?#");
      expect(countPossibleConfigurations(".???.###", [1, 1, 3])).toBe(1);
    });
    test('is valid grouping', () {
      expect(isValidGrouping("#.#.###", [1, 1, 3])).toBeTruthy();
    });
    test('grouping check requires full field knowledge', () {
      expect(() => isValidGrouping("???..###", [1, 1, 3]))
          .throws
          .isArgumentError();
    });
  });
  group('part 1', () {
    test(skip: true, 'edge cases', () {
      var input = "????...###.";
      var groups = [1, 1, 3];

      expect(countPossibleConfigurations(input, groups)).toBe(3);
    });
    test('example', () {
      var expected = [1, 4, 1, 1, 4, 10];

      var value = <int>[];
      for (var line in exampleInput.split("\n")) {
        var [field, brokenGroupsRaw] = line.split(" ");
        var brokenGroups = brokenGroupsRaw.split(",").map(int.parse).toList();
        value.add(countPossibleConfigurations(field, brokenGroups));
      }

      expect(value).toEqual(expected);
    });
  });
}
