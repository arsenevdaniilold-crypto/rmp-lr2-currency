import 'package:flutter/material.dart';

import 'data/api_client.dart';
import 'data/currency_repository.dart';
import 'screens/converter_screen.dart';
import 'state/converter_state.dart';
import 'theme.dart';

void main() {
  final repository = CurrencyRepository(ApiClient());
  final state = ConverterState(repository);
  runApp(CurrencyApp(state: state));
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key, required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер валют',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ConverterScreen(state: state),
    );
  }
}
