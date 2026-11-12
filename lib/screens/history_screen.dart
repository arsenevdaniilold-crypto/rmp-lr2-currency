import 'package:flutter/material.dart';

import '../state/converter_state.dart';
import '../utils/currency_info.dart';
import '../utils/format.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state});

  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('История конвертаций'),
            actions: [
              if (state.history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Очистить',
                  onPressed: state.clearHistory,
                ),
            ],
          ),
          body: state.history.isEmpty
              ? const Center(child: Text('Пока ничего не конвертировали'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.history.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = state.history[index];
                    return Card(
                      child: ListTile(
                        leading: Text(
                          currencyFlag(c.from),
                          style: const TextStyle(fontSize: 26),
                        ),
                        title: Text(
                          '${formatMoney(c.amount)} ${c.from} → '
                          '${formatMoney(c.result)} ${c.to}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Курс ${formatRate(c.rate)} · '
                          '${formatDateTime(c.createdAt)}',
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
