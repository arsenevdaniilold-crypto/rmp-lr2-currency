import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/currency_repository.dart';
import '../models/conversion.dart';

enum LoadStatus { initial, loading, success, error }

class ConverterState extends ChangeNotifier {
  ConverterState(this._repository);

  final CurrencyRepository _repository;

  static const currencies = [
    'RUB',
    'USD',
    'EUR',
    'CNY',
    'GBP',
    'JPY',
    'KZT',
    'BYN',
    'TRY',
    'CHF',
    'AED',
    'THB', // тайский бат
    'VND', // вьетнамский донг
  ];

  String from = 'EUR';
  String to = 'RUB';

  LoadStatus status = LoadStatus.initial;
  String? errorMessage;
  Conversion? lastResult;

  final List<Conversion> history = [];

  bool get isLoading => status == LoadStatus.loading;

  void setFrom(String value) {
    from = value;
    notifyListeners();
  }

  void setTo(String value) {
    to = value;
    notifyListeners();
  }

  void swap() {
    final tmp = from;
    from = to;
    to = tmp;
    notifyListeners();
  }

  double? parseAmount(String? text) {
    if (text == null) return null;
    return double.tryParse(
      text.trim().replaceAll(',', '.').replaceAll(' ', ''),
    );
  }

  String? validateAmount(String? text) {
    if (text == null || text.trim().isEmpty) return 'Введите сумму';
    final value = parseAmount(text);
    if (value == null) return 'Некорректное число';
    if (value < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  Future<void> convert(String text) async {
    final amount = parseAmount(text);
    if (amount == null || amount < 0) return;

    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final rates = await _repository.getRates(from);
      final rate = rates.rateTo(to);
      if (rate == null) throw ApiException('Нет курса для валюты $to');

      lastResult = Conversion(
        amount: amount,
        from: from,
        to: to,
        rate: rate,
        rateUpdatedAt: rates.updatedAt,
        createdAt: DateTime.now(),
      );
      history.insert(0, lastResult!);
      status = LoadStatus.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}
