import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("caching test", () {
    test("rout caching test", () {
      String listDivider = '\$';
      String itemDivider = '!';
      String test = "{123}${itemDivider}1$listDivider{234}${itemDivider}2$listDivider";

      debugPrint(test.split(listDivider).length.toString());
    });
  });
}
