class Transaction {
  late DateTime date;
  int id, cardn, cost;
  String content, category;

  Transaction(
    this.id,
    String date,
    this.cardn,
    this.content,
    this.category,
    this.cost
  )
  {
    this.date = DateTime.parse(date);
  }

  Map<String,dynamic> getProperties() {
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