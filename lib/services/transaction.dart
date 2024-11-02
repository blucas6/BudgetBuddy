import 'package:intl/intl.dart';

class TransactionObj {
  late DateTime date;
  int? id, cardn;
  double? cost;
  String? content, category;

  TransactionObj(
      {this.id,
      String? dates,
      this.cardn,
      this.content,
      this.category,
      this.cost}) {
    date = dates != null ? DateTime.parse(dates) : DateTime.parse('1980-01-01');
  }

  // return a map of the object
  Map<String, dynamic> getProperties() {
    return {
      'ID': id,
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Card': cardn,
      'Description': content,
      'Category': category,
      'Cost': cost
    };
  }

  // inverse of getProperties
  TransactionObj.loadFromMap(Map<String, dynamic> map) :
    id = map['ID'],
    date = map['Date'],
    cardn = map['Card'],
    content = map['Description'],
    category = map['Category'],
    cost = map['Cost'];

  // provide a sample transaction
  TransactionObj.defaultTransaction() :
    id = -1,
    date = DateTime.parse('1980-01-01'),
    cardn = 999,
    content = 'Default Transaction',
    category = 'Default',
    cost = -1;
}
