import '../models/exchange_rates.dart';
import 'api_client.dart';

class CurrencyRepository {
  CurrencyRepository(this._api);

  final ApiClient _api;

  Future<ExchangeRates> getRates(String baseCurrency) async {
    final json = await _api.getLatest(baseCurrency);
    try {
      return ExchangeRates.fromJson(json);
    } on FormatException catch (e) {
      throw ApiException(e.message);
    } catch (_) {
      throw ApiException('Не удалось разобрать ответ сервера');
    }
  }
}
