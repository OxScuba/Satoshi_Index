enum AppCurrency { eur, usd, gbp, chf, cad, aud, jpy, cny, hkd, sgd, rub, ils }

extension AppCurrencyExtension on AppCurrency {
  String get code => name;

  String get symbol {
    switch (this) {
      case AppCurrency.eur:
        return '€';
      case AppCurrency.usd:
        return r'$';
      case AppCurrency.gbp:
        return '£';
      case AppCurrency.chf:
        return 'CHF';
      case AppCurrency.cad:
        return r'CA$';
      case AppCurrency.aud:
        return r'A$';
      case AppCurrency.jpy:
        return '¥';
      case AppCurrency.cny:
        return 'CN¥';
      case AppCurrency.hkd:
        return r'HK$';
      case AppCurrency.sgd:
        return r'S$';
      case AppCurrency.rub:
        return '₽';
      case AppCurrency.ils:
        return '₪';
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.eur:
        return 'Euro';
      case AppCurrency.usd:
        return 'Dollar américain';
      case AppCurrency.gbp:
        return 'Livre sterling';
      case AppCurrency.chf:
        return 'Franc suisse';
      case AppCurrency.cad:
        return 'Dollar canadien';
      case AppCurrency.aud:
        return 'Dollar australien';
      case AppCurrency.jpy:
        return 'Yen japonais';
      case AppCurrency.cny:
        return 'Yuan chinois';
      case AppCurrency.hkd:
        return 'Dollar de Hong Kong';
      case AppCurrency.sgd:
        return 'Dollar de Singapour';
      case AppCurrency.rub:
        return 'Rouble russe';
      case AppCurrency.ils:
        return 'Nouveau shekel israélien';
    }
  }

  int get fractionDigits {
    switch (this) {
      case AppCurrency.jpy:
        return 0;
      case AppCurrency.eur:
      case AppCurrency.usd:
      case AppCurrency.gbp:
      case AppCurrency.chf:
      case AppCurrency.cad:
      case AppCurrency.aud:
      case AppCurrency.cny:
      case AppCurrency.hkd:
      case AppCurrency.sgd:
      case AppCurrency.rub:
      case AppCurrency.ils:
        return 2;
    }
  }

  AppCurrency get toolsSecondaryCurrency {
    return this == AppCurrency.eur ? AppCurrency.usd : this;
  }
}

AppCurrency appCurrencyFromCode(String? code) {
  final normalized = code?.trim().toLowerCase();

  for (final currency in AppCurrency.values) {
    if (currency.code == normalized) {
      return currency;
    }
  }

  return AppCurrency.eur;
}
