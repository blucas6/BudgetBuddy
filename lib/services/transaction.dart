class Transaction {
  late DateTime? date;
  int? id, cardn;
  double? cost;
  String? content, category;

  Transaction(
      {this.id,
      String? dates,
      this.cardn,
      this.content,
      this.category,
      this.cost}) {
    date = dates != null ? DateTime.parse(dates) : DateTime.parse('9999-99-99');
  }

  Map<String, dynamic> getProperties() {
    return {
      'ID': id,
      'Date': date,
      'Card #': cardn,
      'Description': content,
      'Category': category,
      '\$': cost
    };
  }
}
