import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Appconfig {
  // singleton instance, load on creation
  Appconfig._internal() {
    load();
  }

  static final Appconfig _instance = Appconfig._internal();

  factory Appconfig() => _instance;

  Map<String, dynamic>? accountInfo;

  // load the application config as json
  void load() async {
    try {
      String jstring = await rootBundle.loadString('assets/accounttypes.json');
      accountInfo = json.decode(jstring);
    } catch (e) {
      debugPrint('Failed to load config -> $e');
    }
  }
}
