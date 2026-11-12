import 'package:flutter/material.dart';

import '../state/converter_state.dart';
import '../theme.dart';
import '../utils/currency_info.dart';
import '../utils/format.dart';
import 'history_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, required this.state});

  final ConverterState state;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '100');

  ConverterState get state => widget.state;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      state.convert(_amountController.text);
    }
  }

  void _swap() {
    state.swap();
    // если сумма уже введена - сразу пересчитываем в другую сторону
    if (state.validateAmount(_amountController.text) == null &&
        state.lastResult != null) {
      state.convert(_amountController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'История',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoryScreen(state: state)),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Сумма',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              validator: state.validateAmount,
                              onFieldSubmitted: (_) => _convert(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _currencyPicker(
                                  'Из',
                                  state.from,
                                  state.setFrom,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: IconButton.filledTonal(
                                  onPressed: state.isLoading ? null : _swap,
                                  icon: const Icon(Icons.swap_horiz),
                                  tooltip: 'Поменять местами',
                                ),
                              ),
                              Expanded(
                                child: _currencyPicker(
                                  'В',
                                  state.to,
                                  state.setTo,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : _convert,
                    icon: const Icon(Icons.currency_exchange),
                    label: const Text('Конвертировать'),
                  ),
                  const SizedBox(height: 20),
                  _buildResult(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _currencyPicker(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [
            for (final c in ConverterState.currencies)
              DropdownMenuItem(value: c, child: Text('${currencyFlag(c)}  $c')),
          ],
          onChanged: state.isLoading
              ? null
              : (v) {
                  if (v != null) onChanged(v);
                },
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final theme = Theme.of(context);

    switch (state.status) {
      case LoadStatus.initial:
        return const Text(
          'Введите сумму и нажмите «Конвертировать»',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        );

      case LoadStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        );

      case LoadStatus.error:
        return Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 40,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Ошибка',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _convert, child: const Text('Повторить')),
              ],
            ),
          ),
        );

      case LoadStatus.success:
        final r = state.lastResult!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatMoney(r.amount)} ${r.from} =',
                  style: const TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${formatMoney(r.result)} ${r.to}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Divider(height: 24),
                Text('Курс: 1 ${r.from} = ${formatRate(r.rate)} ${r.to}'),
                if (r.rateUpdatedAt != null)
                  Text(
                    'Обновлено: ${formatDateTime(r.rateUpdatedAt!)}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
              ],
            ),
          ),
        );
    }
  }
}
