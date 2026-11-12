class Conversion {
  Conversion({
    required this.amount,
    required this.from,
    required this.to,
    required this.rate,
    required this.rateUpdatedAt,
    required this.createdAt,
  });

  final double amount;
  final String from;
  final String to;
  final double rate;
  final DateTime? rateUpdatedAt;
  final DateTime createdAt;

  double get result => amount * rate;
}
