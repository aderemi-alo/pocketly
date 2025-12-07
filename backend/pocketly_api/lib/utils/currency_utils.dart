/// Supported currency codes (ISO 4217)
const List<String> supportedCurrencies = [
  'NGN', // Nigerian Naira
  'USD', // US Dollar
  'EUR', // Euro
  'GBP', // British Pound
  'JPY', // Japanese Yen
  'INR', // Indian Rupee
  'CAD', // Canadian Dollar
  'AUD', // Australian Dollar
];

/// Default currency code
const String defaultCurrency = 'NGN';

/// Validates if a currency code is supported
bool isValidCurrency(String? code) {
  if (code == null) return false;
  return supportedCurrencies.contains(code.toUpperCase());
}
