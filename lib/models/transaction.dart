// lib/models/transaction.dart

class Transaction {
  final String account;
  final double spending;
  final double monthlySpending;

  Transaction({
    required this.account,
    required this.spending,
    required this.monthlySpending,
  });
}
