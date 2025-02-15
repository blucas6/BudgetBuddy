import 'package:intl/intl.dart';

class TransactionObj {
  late DateTime date;
  int? id, cardn;
  late double cost;
  String? content, category, account;
  late List<String> tags;
  String separator = ';';

  TransactionObj(
      {this.id,
      String? dates,
      this.cardn,
      this.content,
      this.category,
      double? somecost,
      this.account,
      var sometags}) {
    date = dates != null ? DateTime.parse(dates) : DateTime.parse('1980-01-01');
    tags = sometags is String ? sometags.split(separator) : (sometags != null ? sometags : []);
    cost = somecost == null ? 0 : somecost;
  }

  // return a map of the object
  Map<String, dynamic> getProperties() {
    return {
      'ID': id,
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Card': cardn,
      'Description': content,
      'Category': category,
      'Cost': cost,
      'Account': account,
      'Tags': tags
    };
  }

  // same as above, when adding objects to the database and the
  // ID is not yet set, use a map of the obj without the ID
  Map<String, dynamic> getPropertiesNoID() {
    return {
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Card': cardn,
      'Description': content,
      'Category': category,
      'Cost': cost,
      'Account': account,
      'Tags': tags.join(separator)
    };
  }

  // inverse of getProperties
  TransactionObj.loadFromMap(Map<String, dynamic> map) :
    id = map['ID'],
    date = map['Date'] is String ? DateTime.parse(map['Date']) : map['Date'],
    cardn = map['Card'],
    content = map['Description'],
    category = map['Category'],
    cost = map['Cost'] is double ? map['Cost'] : (map['Cost'] is int ? map['Cost'].toDouble() : (map['Cost'] is String ? double.parse(map['Cost']) : null)),   // in case of integers
    account = map['Account'],
    tags = map['Tags'] is String ? map['Tags'].split(';') : map['Tags'];

  // provide a sample transaction
  TransactionObj.defaultTransaction() :
    id = -1,
    date = DateTime.parse('1980-01-01'),
    cardn = 999,
    content = 'Default Transaction',
    category = 'Default',
    cost = -1,
    account = '',
    tags = [];

  // provide a blank map to generate a transactionObj from
  Map<String, dynamic> getBlankMap() {
    return {
      'ID': 0,
      'Date': DateTime.parse('1980-01-01'),
      'Card': 0,
      'Description': '',
      'Category': '',
      'Cost': 0,
      'Account': '',
      'Tags': List<String>.empty(growable: true)
    };
  }

  // defines which cells are displayable in the transaction widget
  Map<String, dynamic> getDisplayProperties() {
    return {
      'ID': false,
      'Date': true,
      'Card': true,
      'Description': true,
      'Category': true,
      'Cost': true,
      'Account': false,
      'Tags': true
    };
  }

  // build SQL query according to properties
  Map<String, dynamic> getSQLProperties() {
    return {
      'ID': 'INTEGER PRIMARY KEY',
      'Date': 'DATE',
      'Card': 'INTEGER',
      'Description': 'TEXT',
      'Category': 'TEXT',
      'Cost': 'DOUBLE',
      'Account': 'TEXT',
      'Tags': 'TEXT'
    };
  }

  // getter for the year as a string
  String get year {
    return date.year.toString();
  }

  // getter for the month as a string
  String get month {
    List<String> monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return monthNames[date.month - 1];
  }
}
