import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'package:pensieve/Pensieve.dart';

void jsonTest() {
  String content = "";
  content +=
      '{"time":"2018-12-22 12:26:45.333","keys":["apple","banana"],"text":"apple and banana"}';
  content +=
      ',{"time":"2019-12-22 12:26:45.333","keys":["apple","orange"],"text":"apple and orange"}';

  // decode
  final listOfMaps = json.decode("[" + content + "]");

  final messages =
      List<Message>.from(listOfMaps.map((i) => Message.fromJson(i)));
  for (final msg in messages) {
    print(msg.toString());
  }

  // encode
  print(json.encode(messages));
  expect("[" + content + "]", json.encode(messages));
}

void main() {
  test('json_test', jsonTest);
}
