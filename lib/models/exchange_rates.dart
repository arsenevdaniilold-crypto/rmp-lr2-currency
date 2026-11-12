class ExchangeRates {
  ExchangeRates({
    required this.base,
    required this.rates,
    required this.updatedAt,
  });

  final String base;
  final Map<String, double> rates;
  final DateTime? updatedAt;

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    if (json['result'] != 'success') {
      throw FormatException('Сервер вернул ошибку: ${json['error-type']}');
    }

    final raw = json['rates'] as Map<String, dynamic>;
    final rates = raw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    final timestamp = json['time_last_update_unix'];
    return ExchangeRates(
      base: json['base_code'] as String,
      rates: rates,
      updatedAt: timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : null,
    );
  }

  double? rateTo(String code) => rates[code];
}
