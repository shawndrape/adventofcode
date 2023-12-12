import 'package:collection/collection.dart';
import 'package:spec/spec.dart';

List<({int dest, int source, int length})> parseFilter(String summary) {
  var result = <({int dest, int source, int length})>[];
  var split = summary.split("\n");
  // var counter = 1;
  for (var line in split) {
    // print('parse filter rule $counter of ${split.length}');
    var [dest, source, length] = line.split(" ").map(int.parse).toList();
    result.add((dest: dest, source: source, length: length));
    // counter++;
  }
  return result;
}

int Function(int e) generateFilter(
        List<({int dest, int source, int length})> filterPattern) =>
    (e) {
      var applicableFilter = filterPattern
          .where((rule) => rule.source <= e && e < (rule.source + rule.length))
          .firstOrNull;
      if (applicableFilter == null) return e;
      var offset = e - applicableFilter.source;
      return applicableFilter.dest + offset;
    };

({int first, int length}) toTuple(Iterable<dynamic> iter) {
  var iterator = iter.iterator;
  iterator.moveNext();
  int first = iterator.current;
  iterator.moveNext();
  int length = iterator.current;
  // assert(!iterator.moveNext());
  return (first: first, length: length);
}

var counter = 0;
printWithCounter(String message) {
  counter++;
  print('[$counter] $message');
}

// start with a single queue
// pop range and check all filter rules
// if one filter clips, process the overlap and queue the remainder

Iterable<({int first, int length})> Function(
    int start, int length) generateFilterForRange(
        List<({int dest, int source, int length})> filterPattern) =>
    (int firstOG, int lengthOG) {
      var toBeProcessed = QueueList<List<dynamic>>();
      var processedRanges = <List<dynamic>>[];
      toBeProcessed.add([firstOG, lengthOG, 'OG']);
      while (toBeProcessed.isNotEmpty) {
        var [first, length, _] = toBeProcessed.removeFirst();
        var matchesAnyRule = false;
        for (var rule in filterPattern) {
          //range starts before and ends within pattern
          // x < src < x+l < src + srcl
          if (first < rule.source &&
              rule.source < first + length &&
              first + length <= rule.source + rule.length) {
            matchesAnyRule = true;
            toBeProcessed.add([first, rule.source - first, 'b1']);
            processedRanges
                .add([rule.dest, first + length - rule.source, 'b2']);
          }

          //range entirely within filter pattern
          // src < x < x + l < src + srcl
          if (rule.source <= first &&
              first + length <= rule.source + rule.length) {
            matchesAnyRule = true;
            processedRanges.add([rule.dest + first - rule.source, length, 'c']);
          }

          //range starts before and ends after pattern
          //x < src < src + srcl < x + l
          if (first < rule.source &&
              rule.source + rule.length < first + length) {
            matchesAnyRule = true;
            processedRanges.add([rule.dest, rule.length, 'd2']);
            toBeProcessed.addAll([
              [first, rule.source - first, 'd1'],
              [
                rule.source + rule.length,
                (first + length) - (rule.source + rule.length),
                'd3'
              ],
            ]);
          }

          //range starts within and ends after pattern
          // src < x < src + srcl < x + l
          if (rule.source < first &&
              first < rule.source + rule.length &&
              rule.source + rule.length < first + length) {
            matchesAnyRule = true;
            processedRanges.add([
              rule.dest + first - rule.source,
              (rule.source + rule.length - first),
              'e1'
            ]);
            toBeProcessed.add([
              rule.source + rule.length,
              length - (rule.source + rule.length - first),
              'e2'
            ]);
          }

          if (matchesAnyRule) break;
        }
        if (!matchesAnyRule) {
          //range entirely before filter patterns
          // x < x +l < src < src + srcl

          //range entirely after filter patterns
          // src < src + srcl < x < x + l
          processedRanges.add([first, length, 'no match']);
        }
      }

      if (processedRanges.any((element) => element[1] <= 0)) {
        throw Exception('Unexpected empty or negative ranges');
      }
      return processedRanges.map(toTuple);
    };

void main() {
  const exampleInput = {
    0: "79 14 55 13",
    1: """50 98 2
52 50 48""",
    2: """0 15 37
37 52 2
39 0 15""",
    3: """49 53 8
0 11 42
42 0 7
57 7 4""",
    4: """88 18 7
18 25 70""",
    5: """45 77 23
81 45 19
68 64 13""",
    6: """0 69 1
1 0 69""",
    7: """60 56 37
56 93 4""",
  };

  const inputFile = {
    0: "630335678 71155519 260178142 125005421 1548082684 519777283 4104586697 30692976 1018893962 410959790 3570781652 45062110 74139777 106006724 3262608046 213460151 3022784256 121993130 2138898608 36769984",
    1: """2977255263 3423361099 161177662
3464809483 1524036300 40280620
1278969303 2583891002 282823382
3766263020 1796922321 171061976
411885923 23002578 152894367
564780290 442452799 75000259
2421385924 1454220354 69815946
3348169880 3014668733 58677303
903828313 1975611534 37514769
3406847183 1396258054 57962300
4043490501 3171884304 251476795
941343082 2866714384 147954349
1089297431 1206586182 189671872
2891116902 3584538761 18778869
0 517453058 122327491
2491201870 932395829 274190353
388883345 0 23002578
3944952233 3073346036 98538268
3505090103 671222912 261172917
2073455492 2013126303 347930432
2909895771 2361056735 67359492
1561792685 3603317630 511662807
2765392223 2458166323 125724679
3168183021 4114980437 179986859
3138432925 2428416227 29750096
122327491 175896945 266555854
671222912 1564316920 232605401
3937324996 1967984297 7627237""",
    2: """895998030 0 382128379
2851625320 2664267363 205943350
2518444693 3961786669 333180627
1879667741 2025490411 638776952
0 1243838521 558555556
3280896340 2870210713 1014070956
558555556 906396047 337442474
3057568670 3884281669 77505000
3135073670 1879667741 145822670
1278126409 382128379 524267668""",
    3: """0 1845976330 336090970
3299138007 3322545218 12048535
336090970 0 11457152
1280501317 1371665084 474311246
2583893821 3334593753 715244186
3311186542 2468197905 738651397
2468197905 3206849302 115695916
347548122 11457152 932953195
1754812563 944410347 427254737""",
    4: """1121222108 519789808 4326619
1125548727 524116427 429792955
1052043895 3930896885 69178213
3210593080 0 36442681
1669405426 2787769857 138341045
1919839172 3142586910 277606697
2197445869 2466152271 321617586
1555341682 3816833141 114063744
3431283943 3092543143 50043767
3481327710 1975836414 28620233
136025352 1371812880 335069822
0 3420193607 136025352
2600375975 3610804829 206028312
3247035761 36442681 184248182
3676380184 1048117966 323694914
2519063455 966805446 81312520
483991238 1706882702 268953712
3509947943 2926110902 166432241
1862332341 2408645440 57506831
752944950 220690863 299098945
2806404287 2004456647 404188793
1807746471 3556218959 54585870
471095174 953909382 12896064""",
    5: """3941111261 382813357 83783792
4083751028 2792620142 62769876
2924924808 517646744 141124785
10073304 296361721 86451636
2112077648 3356571260 325360811
2097723771 930487406 14353877
1038821361 2233157447 330985253
1604981575 0 157737476
4232208439 2231398376 1759071
3126943010 2564142700 228477442
3355420452 3681932071 528033316
3066049593 1302213021 60893417
2893234140 1091417457 31690668
4146520904 1005729922 85687535
764412615 658771529 271715877
4024895053 4212658256 21309254
1601614929 3144601228 3366646
2813498518 3276835638 79735622
0 944841283 10073304
3883453768 1363106438 57657493
1036128492 4209965387 2692869
1762719051 1160654846 141558175
2437438459 157737476 138624245
96524940 1420763931 667887675
2576062704 3147967874 128867764
1904277226 2855390018 50699775
1420621949 2906089793 129943385
1550565334 466597149 51049595
2704930468 3036033178 108568050
4046204307 1123108125 37546721
1369806614 954914587 50815335
1954977001 2088651606 142746770""",
    6: """3744493855 2753433800 53429527
3926657179 2806863327 207882975
567844723 1829271702 6392959
3797923382 3046866321 128733797
1711260618 465872733 110275892
2947786208 2530091374 223342426
2371290430 3335177849 39675908
1900678095 703125986 238513863
1521940365 941639849 16040471
979702084 962957535 519048585
2678536664 3987414423 22824189
316276095 2006380474 251568628
574237682 576148625 7838036
2512589774 2369848229 129456424
1821536510 386731148 79141585
659847979 2257949102 32337475
1498750669 0 23189696
2139191958 1482006120 151094619
2410966338 2361085516 8762713
248695366 629624702 67580729
1705983403 957680320 5277215
3436386005 3680199681 275987831
896869843 23189696 23822140
1540019357 265437244 43521643
3171128634 4029709925 265257371
700698880 1633100739 196170963
2659065351 4010238612 19471313
1660345362 583986661 45638041
2642046198 3175600118 17019153
4134540154 3966392426 21021997
145503080 1903188188 103192286
4155562151 3467714480 139405145
920691983 1844178087 59010101
2805227630 3192619271 142558578
692185454 1835664661 8513426
2732147574 3607119625 73080056
3712373836 3014746302 32120019
2361085516 3956187512 10204914
2701360853 2499304653 30786721
582075718 308958887 77772261
1583541000 188632882 76804362
3882034 47011836 141621046
0 699243952 3882034
1537980836 697205431 2038521
2419729051 3374853757 92860723""",
    7: """3880387060 2052152805 97611299
2442736538 3295723734 10591308
3014234548 3058886861 44150293
2722522139 3413370195 153277538
2877652345 3226748198 68975536
678696757 79205913 5515453
3758528684 3103037154 121858376
3648288667 2533118408 110240017
3457871155 4266074310 28892986
2176930761 3905620500 135283057
2312213818 2369019482 56130623
2875799677 3224895530 1852668
2052152805 3780842544 124777956
2598433171 3306315042 56382802
1279041455 278559111 48074772
2964261570 2302916483 49972978
344154771 1539624544 79809331
1030322972 1619433875 248718483
1905012367 1868152358 115533200
105230362 326633883 51970437
4085966662 2880778716 178108145
684212210 1466450827 73173717
919250672 396737705 108684083
868993622 1215278638 50257050
2962757902 2879275048 1503668
1847630888 378604320 18133385
3232700402 4040903557 225170753
2575587736 3390524760 22845435
3977998359 2425150105 107968303
3058384841 3362697844 27826916
789787709 0 79205913
4264074807 2272023994 30892489
3114006964 3594442940 118693438
460824111 202771015 75788096
423964102 1983685558 36860009
2946627881 2352889461 16130021
157200799 505421788 186953972
3486764141 2717750522 161524526
1027934755 692375760 2388217
2453327846 2149764104 122259890
2368344441 2643358425 74392097
0 1407620238 58830589
2654815973 3713136378 67706166
1865764273 117123148 39248094
3086211757 3566647733 27795207
58830589 156371242 46399773
536612207 1265535688 142084550
757385927 84721366 32401782
1327116227 694763977 520514661""",
  };
  group('part 1', () {
    test('example', () {
      /*
      Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
      Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
      Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
      Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
      */
      var expectedValuesArray = [
        [79, 81, 81, 81, 74, 78, 78, 82],
        [14, 14, 53, 49, 42, 42, 43, 43],
        [55, 57, 57, 53, 46, 82, 82, 86],
        [13, 13, 52, 41, 34, 34, 35, 35],
      ];

      var actual = exampleInput[0]!.split(" ").map(int.parse).map((e) => [e]);

      for (var x = 1; x <= 7; x++) {
        // print('parsing rule $x');
        var filterSource = exampleInput[x]!;
        var filterRules = parseFilter(filterSource);
        var filter = generateFilter(filterRules);
        // print('applying filter to seed list');
        actual = actual.mapIndexed((int index, e) {
          // print('applying filter $x to seed ${index + 1}');
          return [...e, filter(e.last)];
        });
      }
      expect(actual).toEqual(expectedValuesArray);

      var sortedByLocationAsc = actual.sorted((a, b) => a.last - b.last);
      expect(sortedByLocationAsc[0].last).toBe(35);
    });
    test('input file', () {
      //file structure not worth parsing into blocks, so it's been copied

      var actual = inputFile[0]!.split(" ").map(int.parse).map((e) => [e]);

      for (var x = 1; x <= 7; x++) {
        var filterSource = inputFile[x]!;
        var filterRules = parseFilter(filterSource);
        var filter = generateFilter(filterRules);
        actual = actual.map((e) => [...e, filter(e.last)]);
      }

      var sortedByLocationAsc = actual.sorted((a, b) => a.last - b.last);
      expect(sortedByLocationAsc[0].last).toBe(51580674);
    });
  });
  group('part 2', () {
    group('generateFilterForRange', () {
      // numbers 4 -> 7 should get 10 added to them
      var filterPattern = [(source: 4, dest: 14, length: 4)];
      var filter = generateFilterForRange(filterPattern);

      test('all before', () {
        expect(filter(0, 3)).toEqual([(first: 0, length: 3)]);
      });
      test('all after', () {
        expect(filter(9, 4)).toEqual([(first: 9, length: 4)]);
      });
      test('all between', () {
        expect(filter(5, 2)).toEqual([(first: 15, length: 2)]);
      });
      test('start before', () {
        expect(filter(2, 5))
            .toEqual({(first: 2, length: 2), (first: 14, length: 3)});
      });
      test('end after', () {
        expect(filter(5, 8))
            .toEqual({(first: 15, length: 3), (first: 8, length: 5)});
      });
      test('start before, end after', () {
        expect(filter(2, 11)).toEqual({
          (first: 2, length: 2),
          (first: 14, length: 4),
          (first: 8, length: 5)
        });
      });
      test('only process a sub-range once', () {
        var filterPattern = parseFilter("""45 77 23
81 45 19
68 64 13""");
        var filter = generateFilterForRange(filterPattern);
        expect(filter(74, 14))
            .toEqual({(first: 78, length: 3), (first: 45, length: 11)});
      });
    });

    test('example', () {
      var seedRanges = exampleInput[0]!.split(" ").map(int.parse);
      var groupedRanges = seedRanges.slices(2);
      //using first for now because example confirms the correct lowest location
      //comes from the first range

      var actual = groupedRanges.map((e) => (first: e[0], length: e[1]));

      print('should only print once: $actual');
      for (var x = 1; x <= 7; x++) {
        var filterSource = exampleInput[x]!;
        var filterRules = parseFilter(filterSource);
        var filter = generateFilterForRange(filterRules);
        actual = actual
            .expand((element) => filter(element.first, element.length))
            .toList();
        print('Actual after pass $x: $actual');
      }

      var sortedByLocationAsc = actual.sorted((a, b) => a.first - b.first);
      expect(sortedByLocationAsc[0].first).toBe(46);
    });
    test('input file', () {
      var seedRanges = inputFile[0]!.split(" ").map(int.parse);
      var groupedRanges = seedRanges.slices(2);

      var actual = groupedRanges.map((e) => (first: e[0], length: e[1]));

      for (var x = 1; x <= 7; x++) {
        var filterSource = exampleInput[x]!;
        var filterRules = parseFilter(filterSource);
        var filter = generateFilterForRange(filterRules);
        actual = actual
            .expand((element) => filter(element.first, element.length))
            .toList();
      }

      var sortedByLocationAsc = actual.sorted((a, b) => a.first - b.first);

      expect(sortedByLocationAsc[0].first).greaterThan(74139777);
      expect(sortedByLocationAsc[0].first).lessThan(260178142);
    });
  });
}
