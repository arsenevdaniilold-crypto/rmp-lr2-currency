/// Флаги валют для выпадающего списка
const _flags = {
  'RUB': '🇷🇺',
  'USD': '🇺🇸',
  'EUR': '🇪🇺',
  'CNY': '🇨🇳',
  'GBP': '🇬🇧',
  'JPY': '🇯🇵',
  'KZT': '🇰🇿',
  'BYN': '🇧🇾',
  'TRY': '🇹🇷',
  'CHF': '🇨🇭',
  'AED': '🇦🇪',
  'THB': '🇹🇭',
  'VND': '🇻🇳',
};

String currencyFlag(String code) => _flags[code] ?? '🏳️';
