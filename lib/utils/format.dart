String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) {
  return '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
}

/// 9235.531 -> "9 235,53" (как пишут суммы у нас)
String formatMoney(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final digits = parts[0];
  final buf = StringBuffer(value < 0 ? '−' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return '$buf,${parts[1]}';
}

/// Курс: 92.3554, а маленький (1 VND = 0.00003506 EUR) - со значащими цифрами,
/// иначе было бы 0.0000
String formatRate(double rate) {
  if (rate >= 0.01) return rate.toStringAsFixed(4);
  return rate.toStringAsPrecision(4);
}
