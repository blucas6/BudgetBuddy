import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Appconfig {

  // private constructor, denoted by '_'
  Appconfig._internal() {
    load();
  }

  // singleton instance
  static final Appconfig _instance = Appconfig._internal();

  // factory will check if singleton already exists or create a new one
  factory Appconfig() {
    return _instance;
  }

  // Handles the configuration for the app
  // '?' means it could be null
  Map<String, dynamic>? accountTypes;   // map of all account types possible for parsing

  // call load to initialize this object with the config properties for the app
  void load() async {
    try {
      String jstring = await rootBundle.loadString('assets/accounttypes.json');
      accountTypes = json.decode(jstring);
    } catch (e) {
      debugPrint('Failed to load config -> $e');
    }
  }
}