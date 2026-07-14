enum AppCurrency { eur, usd }

extension AppCurrencyExtension on AppCurrency {
  String get code => name;

  String get symbol {
    switch (this) {
      case AppCurrency.eur:
        return '€';
      case AppCurrency.usd:
        return r'$';
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.eur:
        return 'Euro';
      case AppCurrency.usd:
        return 'Dollar américain';
    }
  }
}

AppCurrency appCurrencyFromCode(String? code) {
  return code == AppCurrency.usd.code ? AppCurrency.usd : AppCurrency.eur;
}
