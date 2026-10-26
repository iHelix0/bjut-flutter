import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/information_item.dart';

class LocalInformationDataSource {
  LocalInformationDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<InformationItem>> loadItems() async {
    final raw = await _bundle.loadString(
      'assets/content/information/catalog.json',
    );
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('information catalog must be a list');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(InformationItem.fromJson)
        .toList(growable: false);
  }
}
