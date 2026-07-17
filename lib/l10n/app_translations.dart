class AppTranslations {
  AppTranslations._();

  static const Set<String> supportedLanguageCodes = <String>{'fr', 'en', 'es'};

  static String _languageCode = 'fr';

  static String get languageCode => _languageCode;
  static bool get isFrench => _languageCode == 'fr';
  static bool get isEnglish => _languageCode == 'en';
  static bool get isSpanish => _languageCode == 'es';

  static final Map<String, String> _normalizedEnglish = <String, String>{
    for (final entry in _english.entries)
      _translationKey(entry.key): entry.value,
  };

  static final Map<String, String> _normalizedSpanish = <String, String>{
    for (final entry in _spanish.entries)
      _translationKey(entry.key): entry.value,
  };

  static String _translationKey(String source) {
    return source.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  static String normalizeLanguage(String? languageCode) {
    final normalized = languageCode?.trim().toLowerCase();

    if (normalized != null && supportedLanguageCodes.contains(normalized)) {
      return normalized;
    }

    return 'fr';
  }

  static void setLanguage(String languageCode) {
    _languageCode = normalizeLanguage(languageCode);
  }

  static String productName(String productId, String fallback) {
    if (isFrench) {
      return fallback;
    }

    final names =
        isSpanish ? _officialProductSpanishNames : _officialProductEnglishNames;

    return names[productId] ?? tr(fallback);
  }

  static String tr(String source) {
    if (isFrench || source.isEmpty) {
      return source;
    }

    final translations = isSpanish ? _spanish : _english;
    final normalizedTranslations =
        isSpanish ? _normalizedSpanish : _normalizedEnglish;

    final exact =
        translations[source] ??
        translations[source.trim()] ??
        normalizedTranslations[_translationKey(source)];

    if (exact != null) {
      return exact;
    }

    return isSpanish
        ? _translateDynamicSpanish(source)
        : _translateDynamicEnglish(source);
  }

  static String _translateDynamicEnglish(String source) {
    var match = RegExp(r'^Emplacement (\d+) sur (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Slot ${match.group(1)} of ${match.group(2)}';
    }

    match = RegExp(r'^Produit personnel (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Personal product ${match.group(1)}';
    }

    match = RegExp(r'^Ajouter le produit (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Add product ${match.group(1)}';
    }

    match = RegExp(r'^Modifier le produit (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Edit product ${match.group(1)}';
    }

    match = RegExp(
      r'^Adaptez (\d+) produits aux prix que vous payez réellement\.$',
    ).firstMatch(source);
    if (match != null) {
      return 'Adjust ${match.group(1)} products to the prices you actually pay.';
    }

    match = RegExp(
      r'^Créez jusqu’à (\d+) produits personnels\.',
    ).firstMatch(source);
    if (match != null) {
      if (source.contains('Ils apparaîtront en bas de l’accueil')) {
        return 'Create up to ${match.group(1)} personal products. '
            'They will appear at the bottom of the home screen, in the '
            'Tools page and in Android widgets.\n\n'
            'The price is stored in its original currency and automatically '
            'converted into the display currency.';
      }

      return source.replaceFirst(
        match.group(0)!,
        'Create up to ${match.group(1)} personal products.',
      );
    }

    match = RegExp(
      r'^Ajoutez jusqu’à (\d+) produits personnels\.$',
    ).firstMatch(source);
    if (match != null) {
      return 'Add up to ${match.group(1)} personal products.';
    }

    match = RegExp(r'^Prix personnel en ([A-Z]{3})$').firstMatch(source);
    if (match != null) {
      return 'Personal price in ${match.group(1)}';
    }

    match = RegExp(r'^Cours mis à jour à (.+)$').firstMatch(source);
    if (match != null) {
      return 'Rates updated at ${match.group(1)}';
    }

    match = RegExp(
      r'^Cours hors ligne mis en cache à (.+)$',
    ).firstMatch(source);
    if (match != null) {
      return 'Offline cached rates from ${match.group(1)}';
    }

    match = RegExp(r'^Taux croisé : 1 € = (.+)$').firstMatch(source);
    if (match != null) {
      return 'Cross rate: 1 € = ${match.group(1)}';
    }

    match = RegExp(r'^(.+) a été enregistré\.$').firstMatch(source);
    if (match != null) {
      return '${match.group(1)} was saved.';
    }

    match = RegExp(
      r'^(.+) disparaîtra de l’accueil, des outils et de la liste des widgets\.$',
    ).firstMatch(source);
    if (match != null) {
      return '${match.group(1)} will disappear from the home screen, tools and widget list.';
    }

    match = RegExp(
      r'^(.+) prix personnalisés enregistrés\.$',
    ).firstMatch(source);
    if (match != null) {
      return '${match.group(1)} custom prices saved.';
    }

    match = RegExp(r'^Prix de référence : (.+)$').firstMatch(source);
    if (match != null) {
      return 'Reference price: ${match.group(1)}';
    }

    match = RegExp(r'^Dernière mise à jour : (.+)$').firstMatch(source);
    if (match != null) {
      return 'Last updated: ${match.group(1)}';
    }

    match = RegExp(
      r'^Erreur lors du téléchargement : (.+)$',
    ).firstMatch(source);
    if (match != null) {
      return 'Download error: ${match.group(1)}';
    }

    match = RegExp(r'^Erreur CoinGecko HTTP (.+)$').firstMatch(source);
    if (match != null) {
      return 'CoinGecko HTTP error ${match.group(1)}';
    }

    match = RegExp(r'^Cours CoinGecko invalide pour (.+)$').firstMatch(source);
    if (match != null) {
      return 'Invalid CoinGecko rate for ${match.group(1)}';
    }

    if (source.contains('\nConcerne l’accueil, les outils et les widgets.')) {
      return source.replaceAll(
        '\nConcerne l’accueil, les outils et les widgets.',
        '\nUsed on the home screen, in tools and widgets.',
      );
    }

    if (source.startsWith('Indique le prix que tu paies réellement. ')) {
      return 'Enter the price you actually pay. These values are stored in '
          'euros and used on the home screen, in tools and widgets. '
          'Historical pages and charts remain unchanged.\n\n'
          'Leave a field blank to use the latest quarterly reference price.';
    }

    final localizedProduct = _replaceOfficialProductSuffix(
      source,
      _officialProductEnglishNames,
    );
    if (localizedProduct != null) {
      return localizedProduct;
    }

    if (source.startsWith('Saisis un montant dans une case : ')) {
      return source
          .replaceFirst(
            'Saisis un montant dans une case : ',
            'Enter an amount in one field: ',
          )
          .replaceAll(
            'les trois autres se calculent immédiatement.',
            'the other three are calculated instantly.',
          );
    }

    return source;
  }

  static String _translateDynamicSpanish(String source) {
    var match = RegExp(r'^Emplacement (\d+) sur (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Espacio ${match.group(1)} de ${match.group(2)}';
    }

    match = RegExp(r'^Produit personnel (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Producto personal ${match.group(1)}';
    }

    match = RegExp(r'^Ajouter le produit (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Añadir producto ${match.group(1)}';
    }

    match = RegExp(r'^Modifier le produit (\d+)$').firstMatch(source);
    if (match != null) {
      return 'Editar producto ${match.group(1)}';
    }

    match = RegExp(
      r'^Adaptez (\d+) produits aux prix que vous payez réellement\.$',
    ).firstMatch(source);
    if (match != null) {
      return 'Ajusta ${match.group(1)} productos a los precios que pagas realmente.';
    }

    match = RegExp(
      r'^Créez jusqu’à (\d+) produits personnels\.',
    ).firstMatch(source);
    if (match != null) {
      if (source.contains('Ils apparaîtront en bas de l’accueil')) {
        return 'Crea hasta ${match.group(1)} productos personales. '
            'Aparecerán al final de la pantalla de inicio, en la página '
            'Herramientas y en los widgets de Android.\n\n'
            'El precio se guarda en su moneda de origen y se convierte '
            'automáticamente a la moneda de visualización.';
      }

      return source.replaceFirst(
        match.group(0)!,
        'Crea hasta ${match.group(1)} productos personales.',
      );
    }

    match = RegExp(
      r'^Ajoutez jusqu’à (\d+) produits personnels\.$',
    ).firstMatch(source);
    if (match != null) {
      return 'Añade hasta ${match.group(1)} productos personales.';
    }

    match = RegExp(r'^Prix personnel en ([A-Z]{3})$').firstMatch(source);
    if (match != null) {
      return 'Precio personal en ${match.group(1)}';
    }

    match = RegExp(r'^Cours mis à jour à (.+)$').firstMatch(source);
    if (match != null) {
      return 'Cotizaciones actualizadas a las ${match.group(1)}';
    }

    match = RegExp(
      r'^Cours hors ligne mis en cache à (.+)$',
    ).firstMatch(source);
    if (match != null) {
      return 'Cotizaciones sin conexión almacenadas a las ${match.group(1)}';
    }

    match = RegExp(r'^Taux croisé : 1 € = (.+)$').firstMatch(source);
    if (match != null) {
      return 'Tipo de cambio cruzado: 1 € = ${match.group(1)}';
    }

    match = RegExp(r'^(.+) a été enregistré\.$').firstMatch(source);
    if (match != null) {
      return 'Guardado: ${match.group(1)}.';
    }

    match = RegExp(
      r'^(.+) disparaîtra de l’accueil, des outils et de la liste des widgets\.$',
    ).firstMatch(source);
    if (match != null) {
      return '${match.group(1)} desaparecerá de la pantalla de inicio, las herramientas y la lista de widgets.';
    }

    match = RegExp(
      r'^(.+) prix personnalisés enregistrés\.$',
    ).firstMatch(source);
    if (match != null) {
      return '${match.group(1)} precios personalizados guardados.';
    }

    match = RegExp(r'^Prix de référence : (.+)$').firstMatch(source);
    if (match != null) {
      return 'Precio de referencia: ${match.group(1)}';
    }

    match = RegExp(r'^Dernière mise à jour : (.+)$').firstMatch(source);
    if (match != null) {
      return 'Última actualización: ${match.group(1)}';
    }

    match = RegExp(
      r'^Erreur lors du téléchargement : (.+)$',
    ).firstMatch(source);
    if (match != null) {
      return 'Error de descarga: ${match.group(1)}';
    }

    match = RegExp(r'^Erreur CoinGecko HTTP (.+)$').firstMatch(source);
    if (match != null) {
      return 'Error HTTP de CoinGecko ${match.group(1)}';
    }

    match = RegExp(r'^Cours CoinGecko invalide pour (.+)$').firstMatch(source);
    if (match != null) {
      return 'Cotización de CoinGecko no válida para ${match.group(1)}';
    }

    if (source.contains('\nConcerne l’accueil, les outils et les widgets.')) {
      return source.replaceAll(
        '\nConcerne l’accueil, les outils et les widgets.',
        '\nSe utiliza en la pantalla de inicio, las herramientas y los widgets.',
      );
    }

    if (source.startsWith('Indique le prix que tu paies réellement. ')) {
      return 'Indica el precio que pagas realmente. Estos valores se guardan '
          'en euros y se utilizan en la pantalla de inicio, las herramientas '
          'y los widgets. Las fichas y los gráficos históricos no cambian.\n\n'
          'Deja un campo vacío para utilizar el último precio trimestral de referencia.';
    }

    final localizedProduct = _replaceOfficialProductSuffix(
      source,
      _officialProductSpanishNames,
    );
    if (localizedProduct != null) {
      return localizedProduct;
    }

    if (source.startsWith('Saisis un montant dans une case : ')) {
      return source
          .replaceFirst(
            'Saisis un montant dans une case : ',
            'Introduce un importe en un campo: ',
          )
          .replaceAll(
            'les trois autres se calculent immédiatement.',
            'los otros tres se calculan inmediatamente.',
          );
    }

    return source;
  }

  static String? _replaceOfficialProductSuffix(
    String source,
    Map<String, String> localizedNames,
  ) {
    for (final entry in localizedNames.entries) {
      final frenchName = _officialProductFrenchNames[entry.key];
      if (frenchName != null && source.endsWith(frenchName)) {
        return source.substring(0, source.length - frenchName.length) +
            entry.value;
      }
    }

    return null;
  }

  static const Map<String, String> _english = {
    'Satoshi Index': 'Satoshi Index',
    'Paramètres': 'Settings',
    'Mode sombre': 'Dark mode',
    'Afficher les prix en sats': 'Display prices in sats',
    'Remplace 0.00 00X XXX ₿ par X XXX sats':
        'Replaces 0.00 00X XXX ₿ with X XXX sats',
    'Devise d’affichage': 'Display currency',
    'Concerne l’accueil, les outils et les widgets.':
        'Used on the home screen, in tools and widgets.',
    'Prix personnalisés': 'Custom prices',
    'Mes produits': 'My products',
    'Langue': 'Language',
    'Français': 'French',
    'English': 'English',
    'Español': 'Spanish',
    'Tip me in Bitcoin': 'Tip me in Bitcoin',
    'Impossible de charger le cours du Bitcoin.':
        'Unable to load the Bitcoin price.',
    'Réessayer': 'Try again',
    'Outils': 'Tools',
    'Sat ⇄ BTC': 'Sat ⇄ BTC',
    'Ajouter un produit personnel': 'Add a personal product',
    ' · personnalisé': ' · custom price',
    ' · personnel': ' · personal',
    'personnalisé': 'custom price',
    'personnel': 'personal',

    'Euro': 'Euro',
    'Dollar américain': 'US Dollar',
    'Livre sterling': 'British Pound',
    'Franc suisse': 'Swiss Franc',
    'Dollar canadien': 'Canadian Dollar',
    'Dollar australien': 'Australian Dollar',
    'Yen japonais': 'Japanese Yen',
    'Yuan chinois': 'Chinese Yuan',
    'Dollar de Hong Kong': 'Hong Kong Dollar',
    'Dollar de Singapour': 'Singapore Dollar',
    'Rouble russe': 'Russian Ruble',
    'Nouveau shekel israélien': 'Israeli New Shekel',
    'Rechercher une devise': 'Search for a currency',
    'Aucune devise ne correspond.': 'No matching currency.',
    'Effacer': 'Clear',

    'Baguette': 'Baguette',
    'Essence SP95 (l)': 'SP95 Gasoline (L)',
    'Paquet de Cigarette': 'Pack of Cigarettes',
    'Paquet de cigarettes': 'Pack of Cigarettes',
    'Bière (50cl)': 'Beer (50 cl)',
    'Café': 'Coffee',
    'Boeuf (kg)': 'Beef (kg)',
    'Bœuf (kg)': 'Beef (kg)',
    'Pizza': 'Pizza',
    'Big Mac (zone euro)': 'Big Mac (euro area)',
    'Or (1 g)': 'Gold (1 g)',
    'Ethereum (1 ETH)': 'Ethereum (1 ETH)',
    'Immobilier (m2)': 'Real Estate (m²)',
    'Immobilier (m²)': 'Real Estate (m²)',

    'Convertisseur universel': 'Universal converter',
    'Satoshis': 'Satoshis',
    'Bitcoin': 'Bitcoin',
    'Euros': 'Euros',
    'Comparer avec :': 'Compare with:',
    'Pouvoir d’achat équivalent': 'Equivalent purchasing power',
    'Prix unitaire de référence': 'Reference unit price',
    'Prix unitaire personnalisé': 'Custom unit price',
    'Prix unitaire en direct': 'Live unit price',
    'immédiatement.': 'instantly.',
    'les trois autres se calculent ': 'the other three are calculated ',

    'Prix de référence : ': 'Reference price: ',
    'Votre prix habituel': 'Your usual price',
    'Laisser vide pour la référence': 'Leave blank to use the reference price',
    'Utiliser le prix de référence': 'Use the reference price',
    'Tout réinitialiser': 'Reset all',
    'Réinitialiser les prix ?': 'Reset prices?',
    'Tous les produits utiliseront de nouveau leur dernier prix trimestriel de référence.':
        'All products will use their latest quarterly reference price again.',
    'Annuler': 'Cancel',
    'Réinitialiser': 'Reset',
    'Tous les prix personnalisés ont été supprimés.':
        'All custom prices were removed.',
    'Entre un prix supérieur à zéro.': 'Enter a price greater than zero.',
    'Enregistrement…': 'Saving…',
    'Enregistrer les prix': 'Save prices',
    'Indique le prix que tu paies réellement. Laisse un champ vide pour utiliser le dernier prix trimestriel de référence.':
        'Enter the price you actually pay. Leave a field blank to use the latest quarterly reference price.',
    'Ces valeurs sont enregistrées en euros et seront utilisées sur l’accueil, dans les outils et dans les widgets. Les fiches et graphiques historiques restent inchangés.':
        'These values are stored in euros and used on the home screen, in tools and widgets. Historical pages and charts remain unchanged.',

    'Emplacement vide · Ajouter un nom, un emoji et un prix':
        'Empty slot · Add a name, emoji and price',
    'Modifier': 'Edit',
    'Supprimer': 'Delete',
    'Supprimer ce produit ?': 'Delete this product?',
    'Le produit personnel a été supprimé.': 'The personal product was deleted.',
    'Nom du produit': 'Product name',
    'Exemple : Croissant': 'Example: Croissant',
    'Emoji ou symbole': 'Emoji or symbol',
    'Exemple : 🥐': 'Example: 🥐',
    'Prix habituel': 'Usual price',
    'Exemple : 1,60': 'Example: 1.60',
    'Devise du prix': 'Price currency',
    'Enregistrer le produit': 'Save product',
    'Le nom est obligatoire.': 'A name is required.',
    'Ajoutez un emoji ou un symbole.': 'Add an emoji or symbol.',
    'Entrez un prix supérieur à zéro.': 'Enter a price greater than zero.',
    'Le prix est conservé dans sa devise d’origine puis converti automatiquement dans la devise d’affichage.':
        'The price is stored in its original currency and automatically converted into the display currency.',
    'Ils apparaîtront en bas de l’accueil, dans la page Outils et dans les widgets Android.':
        'They will appear at the bottom of the home screen, in the Tools page and in Android widgets.',

    'Acheter du Bitcoin': 'Buy Bitcoin',
    'Bull Bitcoin est un service non-custodial pour acheter et vendre du Bitcoin.':
        'Bull Bitcoin is a non-custodial service for buying and selling Bitcoin.',
    'Contrairement aux plateformes centralisées comme Binance ou Coinbase, Bull Bitcoin ne garde jamais vos bitcoins.\nVous les recevez directement dans votre portefeuille personnel.\nVous gardez ainsi le contrôle total de vos clés privées.':
        'Unlike centralized platforms such as Binance or Coinbase, Bull Bitcoin never holds your bitcoin.\nYou receive it directly in your personal wallet.\nYou therefore retain full control of your private keys.',
    'Vous pouvez acheter du bitcoin en quelques minutes par virement bancaire.':
        'You can buy bitcoin in a few minutes by bank transfer.',
    'Aller sur Bull Bitcoin': 'Go to Bull Bitcoin',

    'Comprendre le satoshi': 'Understanding the satoshi',
    'Le satoshi (ou sat) est la plus petite unité de Bitcoin, comme le centime pour l’euro.\nComprendre cette échelle permet de mieux saisir les prix en satoshis affichés dans l’application.':
        'The satoshi, or sat, is the smallest unit of Bitcoin, similar to a cent for the euro.\nUnderstanding this scale makes the prices displayed in satoshis easier to grasp.',
    "Pour apprendre sur la meilleure plateforme d'éducation gratuite sur Bitcoin c'est sur planb.network":
        'Learn about Bitcoin for free on planb.network.',
    'Lire le Whitepaper de Bitcoin': 'Read the Bitcoin White Paper',
    'Satoshi to Bitcoin': 'Satoshi to Bitcoin',

    'Whitepaper de Bitcoin': 'Bitcoin White Paper',
    'Télécharger le PDF': 'Download PDF',
    'PDF téléchargé avec succès ✅': 'PDF downloaded successfully ✅',
    'Utilisez le bouton de téléchargement du lecteur PDF.':
        'Use the PDF viewer download button.',
    'Dossier de téléchargement indisponible': 'Download folder unavailable',

    'Merci pour votre soutien ': 'Thank you for your support ',
    'Adresse copiée dans le presse-papiers !':
        'Address copied to the clipboard!',
    'Scan pour envoyer un tip en Bitcoin': 'Scan to send a Bitcoin tip',

    "Satoshi Index est une application pédagogique qui permet de visualiser l'évolution des prix des produits du quotidien en euros (€) et en bitcoins (₿), exprimés en satoshis.\nElle propose des graphiques interactifs, un tableau de données trimestrielles, et permet de mieux comprendre l’impact de l’inflation ainsi que le pouvoir d’achat à travers le prisme du Bitcoin.":
        'Satoshi Index is an educational application for visualizing how everyday prices evolve in euros (€) and bitcoin (₿), expressed in satoshis.\nIt offers interactive charts and a quarterly data table, helping users understand inflation and purchasing power through the lens of Bitcoin.',

    'Prix du produit en BTC': 'Product price in BTC',
    'Prix du produit en €': 'Product price in €',
    'Données détaillées': 'Detailed data',
    'Année': 'Year',
    'Prix en BTC (log)': 'Price in BTC (log)',
    'Prix en €': 'Price in €',
    'Prix du BTC': 'BTC price',
    'Prix en Sats': 'Price in sats',
    'Les données affichées sont mises à jour chaque trimestre et proviennent de sources publiques comme l’INSEE pour les prix à la consommation, ou CoinGecko pour le cours du bitcoin. ':
        'The displayed data is updated quarterly and comes from public sources such as INSEE for consumer prices and CoinGecko for the bitcoin price. ',
    'Dans certains cas, les données brutes sont ajustées pour correspondre à une unité plus parlante. ':
        'In some cases, raw data is adjusted to match a more meaningful unit. ',
    'Par exemple, le prix du pain est calculé à partir d’un tarif au kilo, ramené au prix moyen d’une baguette de 250g. ':
        'For example, the bread price is calculated from a price per kilogram and converted to the average price of a 250 g baguette. ',
    'De même, le prix de la bière correspond à une pinte (50cl), alors que la source INSEE indique le prix pour un demi (25cl). ':
        'Likewise, the beer price represents a pint (50 cl), while the INSEE source reports the price for 25 cl. ',
    'Voir la ': 'View the ',
    'source': 'source',
    ' pour plus de détails.': ' for more details.',

    'Réponse CoinGecko invalide': 'Invalid CoinGecko response',
    'Prix de marché absents': 'Market prices are missing',
    'Impossible de récupérer les cours BTC/ETH et aucun cache n’est disponible':
        'Unable to retrieve BTC/ETH prices and no cache is available',
    'Graphique Bitcoin': 'Bitcoin chart',
    'Cours du Bitcoin': 'Bitcoin price',
    'Actualiser': 'Refresh',
    'Chargement…': 'Loading…',
    'Chargement...': 'Loading...',
    'Aucune donnée disponible.': 'No data available.',
    'Retour': 'Back',
    'Fermer': 'Close',
    'Copier': 'Copy',
    'Ouvrir': 'Open',
    'Télécharger': 'Download',
    'Partager': 'Share',
    'Source': 'Source',
    'Trimestre': 'Quarter',
    'Prix': 'Price',
    'Cours du BTC (€)': 'BTC price (€)',
    'Prix du produit (€)': 'Product price (€)',
    'Prix du produit (BTC)': 'Product price (BTC)',
    'Afficher en échelle logarithmique': 'Use logarithmic scale',
    'Échelle logarithmique': 'Logarithmic scale',
    'Échelle linéaire': 'Linear scale',
    'À propos': 'About',
    'Ressources': 'Resources',
    'Acheter': 'Buy',
    'Comprendre': 'Learn',
    'Faire un don': 'Donate',
    'Page précédente': 'Previous page',
    'Page suivante': 'Next page',
    'Configuration nécessaire': 'Configuration required',
    'Actualisation nécessaire': 'Refresh required',
    'Touchez le widget': 'Tap the widget',
    'Actualisation…': 'Refreshing…',
    'En attente du premier cours': 'Waiting for the first rate',
    'Produit supprimé': 'Product deleted',
    'Touchez pour choisir': 'Tap to choose',
    'un autre produit': 'another product',
    'Hors ligne': 'Offline',
    'Aucun produit disponible.': 'No product available.',
    'Configurer le widget': 'Configure widget',
    'Item affiché': 'Displayed item',
    'Apparence': 'Appearance',
    'Classique · fond plein': 'Classic · solid background',
    'Transparent · texte blanc': 'Transparent · white text',
    'Transparent · texte noir': 'Transparent · black text',
    'Enregistrer le widget': 'Save widget',
    'Choisis l’item puis le style adapté à ton fond d’écran.':
        'Choose the item and the style that suits your wallpaper.',
    'Écriture du diagnostic widget impossible : ':
        'Unable to write widget diagnostics: ',
  };

  static const Map<String, String> _spanish = {
    'Satoshi Index': 'Satoshi Index',
    'Paramètres': 'Ajustes',
    'Mode sombre': 'Modo oscuro',
    'Afficher les prix en sats': 'Mostrar precios en sats',
    'Remplace 0.00 00X XXX ₿ par X XXX sats':
        'Sustituye 0.00 00X XXX ₿ por X XXX sats',
    'Devise d’affichage': 'Moneda de visualización',
    'Concerne l’accueil, les outils et les widgets.':
        'Se utiliza en la pantalla de inicio, las herramientas y los widgets.',
    'Prix personnalisés': 'Precios personalizados',
    'Mes produits': 'Mis productos',
    'Langue': 'Idioma',
    'Français': 'Francés',
    'English': 'Inglés',
    'Tip me in Bitcoin': 'Dame una propina en Bitcoin',
    'Impossible de charger le cours du Bitcoin.':
        'No se ha podido cargar el precio de Bitcoin.',
    'Réessayer': 'Reintentar',
    'Outils': 'Herramientas',
    'Sat ⇄ BTC': 'Sat ⇄ BTC',
    'Ajouter un produit personnel': 'Añadir un producto personal',
    ' · personnalisé': ' · precio personalizado',
    ' · personnel': ' · personal',
    'personnalisé': 'precio personalizado',
    'personnel': 'personal',
    'Euro': 'Euro',
    'Dollar américain': 'Dólar estadounidense',
    'Livre sterling': 'Libra esterlina',
    'Franc suisse': 'Franco suizo',
    'Dollar canadien': 'Dólar canadiense',
    'Dollar australien': 'Dólar australiano',
    'Yen japonais': 'Yen japonés',
    'Yuan chinois': 'Yuan chino',
    'Dollar de Hong Kong': 'Dólar de Hong Kong',
    'Dollar de Singapour': 'Dólar de Singapur',
    'Rouble russe': 'Rublo ruso',
    'Nouveau shekel israélien': 'Nuevo séquel israelí',
    'Rechercher une devise': 'Buscar una moneda',
    'Aucune devise ne correspond.': 'No se encontró ninguna moneda.',
    'Effacer': 'Borrar',
    'Baguette': 'Baguette',
    'Essence SP95 (l)': 'Gasolina SP95 (L)',
    'Paquet de Cigarette': 'Paquete de cigarrillos',
    'Paquet de cigarettes': 'Paquete de cigarrillos',
    'Bière (50cl)': 'Cerveza (50 cl)',
    'Café': 'Café',
    'Boeuf (kg)': 'Carne de vacuno (kg)',
    'Bœuf (kg)': 'Carne de vacuno (kg)',
    'Pizza': 'Pizza',
    'Big Mac (zone euro)': 'Big Mac (zona euro)',
    'Or (1 g)': 'Oro (1 g)',
    'Ethereum (1 ETH)': 'Ethereum (1 ETH)',
    'Immobilier (m2)': 'Inmuebles (m²)',
    'Immobilier (m²)': 'Inmuebles (m²)',
    'Convertisseur universel': 'Convertidor universal',
    'Satoshis': 'Satoshis',
    'Bitcoin': 'Bitcoin',
    'Euros': 'Euros',
    'Comparer avec :': 'Comparar con:',
    'Pouvoir d’achat équivalent': 'Poder adquisitivo equivalente',
    'Prix unitaire de référence': 'Precio unitario de referencia',
    'Prix unitaire personnalisé': 'Precio unitario personalizado',
    'Prix unitaire en direct': 'Precio unitario en tiempo real',
    'immédiatement.': 'inmediatamente.',
    'les trois autres se calculent ': 'los otros tres se calculan ',
    'Prix de référence : ': 'Precio de referencia: ',
    'Votre prix habituel': 'Tu precio habitual',
    'Laisser vide pour la référence':
        'Déjalo vacío para usar el precio de referencia',
    'Utiliser le prix de référence': 'Usar el precio de referencia',
    'Tout réinitialiser': 'Restablecer todo',
    'Réinitialiser les prix ?': '¿Restablecer los precios?',
    'Tous les produits utiliseront de nouveau leur dernier prix trimestriel de référence.':
        'Todos los productos volverán a utilizar su último precio trimestral de referencia.',
    'Annuler': 'Cancelar',
    'Réinitialiser': 'Restablecer',
    'Tous les prix personnalisés ont été supprimés.':
        'Se han eliminado todos los precios personalizados.',
    'Entre un prix supérieur à zéro.': 'Introduce un precio superior a cero.',
    'Enregistrement…': 'Guardando…',
    'Enregistrer les prix': 'Guardar precios',
    'Indique le prix que tu paies réellement. Laisse un champ vide pour utiliser le dernier prix trimestriel de référence.':
        'Indica el precio que pagas realmente. Deja un campo vacío para utilizar el último precio trimestral de referencia.',
    'Ces valeurs sont enregistrées en euros et seront utilisées sur l’accueil, dans les outils et dans les widgets. Les fiches et graphiques historiques restent inchangés.':
        'Estos valores se guardan en euros y se utilizan en la pantalla de inicio, las herramientas y los widgets. Las fichas y los gráficos históricos no cambian.',
    'Emplacement vide · Ajouter un nom, un emoji et un prix':
        'Espacio vacío · Añade un nombre, un emoji y un precio',
    'Modifier': 'Editar',
    'Supprimer': 'Eliminar',
    'Supprimer ce produit ?': '¿Eliminar este producto?',
    'Le produit personnel a été supprimé.':
        'Se ha eliminado el producto personal.',
    'Nom du produit': 'Nombre del producto',
    'Exemple : Croissant': 'Ejemplo: Cruasán',
    'Emoji ou symbole': 'Emoji o símbolo',
    'Exemple : 🥐': 'Ejemplo: 🥐',
    'Prix habituel': 'Precio habitual',
    'Exemple : 1,60': 'Ejemplo: 1,60',
    'Devise du prix': 'Moneda del precio',
    'Enregistrer le produit': 'Guardar producto',
    'Le nom est obligatoire.': 'El nombre es obligatorio.',
    'Ajoutez un emoji ou un symbole.': 'Añade un emoji o un símbolo.',
    'Entrez un prix supérieur à zéro.': 'Introduce un precio superior a cero.',
    'Le prix est conservé dans sa devise d’origine puis converti automatiquement dans la devise d’affichage.':
        'El precio se guarda en su moneda de origen y se convierte automáticamente a la moneda de visualización.',
    'Ils apparaîtront en bas de l’accueil, dans la page Outils et dans les widgets Android.':
        'Aparecerán al final de la pantalla de inicio, en la página Herramientas y en los widgets de Android.',
    'Acheter du Bitcoin': 'Comprar Bitcoin',
    'Bull Bitcoin est un service non-custodial pour acheter et vendre du Bitcoin.':
        'Bull Bitcoin es un servicio sin custodia para comprar y vender Bitcoin.',
    'Contrairement aux plateformes centralisées comme Binance ou Coinbase, Bull Bitcoin ne garde jamais vos bitcoins.\nVous les recevez directement dans votre portefeuille personnel.\nVous gardez ainsi le contrôle total de vos clés privées.':
        'A diferencia de plataformas centralizadas como Binance o Coinbase, Bull Bitcoin nunca custodia tus bitcoins.\nLos recibes directamente en tu monedero personal.\nAsí mantienes el control total de tus claves privadas.',
    'Vous pouvez acheter du bitcoin en quelques minutes par virement bancaire.':
        'Puedes comprar bitcoin en pocos minutos mediante transferencia bancaria.',
    'Aller sur Bull Bitcoin': 'Ir a Bull Bitcoin',
    'Comprendre le satoshi': 'Comprender el satoshi',
    'Le satoshi (ou sat) est la plus petite unité de Bitcoin, comme le centime pour l’euro.\nComprendre cette échelle permet de mieux saisir les prix en satoshis affichés dans l’application.':
        'El satoshi, o sat, es la unidad más pequeña de Bitcoin, como el céntimo para el euro.\nComprender esta escala ayuda a interpretar mejor los precios en satoshis que muestra la aplicación.',
    'Pour apprendre sur la meilleure plateforme d\'éducation gratuite sur Bitcoin c\'est sur planb.network':
        'Aprende sobre Bitcoin gratis en planb.network.',
    'Lire le Whitepaper de Bitcoin': 'Leer el libro blanco de Bitcoin',
    'Satoshi to Bitcoin': 'Satoshi a Bitcoin',
    'Whitepaper de Bitcoin': 'Libro blanco de Bitcoin',
    'Télécharger le PDF': 'Descargar PDF',
    'PDF téléchargé avec succès ✅': 'PDF descargado correctamente ✅',
    'Utilisez le bouton de téléchargement du lecteur PDF.':
        'Utiliza el botón de descarga del lector de PDF.',
    'Dossier de téléchargement indisponible':
        'Carpeta de descargas no disponible',
    'Merci pour votre soutien ': 'Gracias por tu apoyo ',
    'Adresse copiée dans le presse-papiers !':
        '¡Dirección copiada al portapapeles!',
    'Scan pour envoyer un tip en Bitcoin':
        'Escanea para enviar una propina en Bitcoin',
    'Satoshi Index est une application pédagogique qui permet de visualiser l\'évolution des prix des produits du quotidien en euros (€) et en bitcoins (₿), exprimés en satoshis.\nElle propose des graphiques interactifs, un tableau de données trimestrielles, et permet de mieux comprendre l’impact de l’inflation ainsi que le pouvoir d’achat à travers le prisme du Bitcoin.':
        'Satoshi Index es una aplicación educativa que permite visualizar la evolución de los precios de productos cotidianos en euros (€) y en bitcoin (₿), expresados en satoshis.\nOfrece gráficos interactivos y una tabla de datos trimestrales para comprender mejor la inflación y el poder adquisitivo desde la perspectiva de Bitcoin.',
    'Prix du produit en BTC': 'Precio del producto en BTC',
    'Prix du produit en €': 'Precio del producto en €',
    'Données détaillées': 'Datos detallados',
    'Année': 'Año',
    'Prix en BTC (log)': 'Precio en BTC (log)',
    'Prix en €': 'Precio en €',
    'Prix du BTC': 'Precio de BTC',
    'Prix en Sats': 'Precio en sats',
    'Les données affichées sont mises à jour chaque trimestre et proviennent de sources publiques comme l’INSEE pour les prix à la consommation, ou CoinGecko pour le cours du bitcoin. ':
        'Los datos mostrados se actualizan cada trimestre y proceden de fuentes públicas como el INSEE para los precios de consumo o CoinGecko para el precio de bitcoin. ',
    'Dans certains cas, les données brutes sont ajustées pour correspondre à une unité plus parlante. ':
        'En algunos casos, los datos brutos se ajustan para corresponder a una unidad más fácil de interpretar. ',
    'Par exemple, le prix du pain est calculé à partir d’un tarif au kilo, ramené au prix moyen d’une baguette de 250g. ':
        'Por ejemplo, el precio del pan se calcula a partir de un precio por kilogramo y se convierte al precio medio de una baguette de 250 g. ',
    'De même, le prix de la bière correspond à une pinte (50cl), alors que la source INSEE indique le prix pour un demi (25cl). ':
        'Del mismo modo, el precio de la cerveza corresponde a una pinta de 50 cl, mientras que la fuente del INSEE indica el precio para 25 cl. ',
    'Voir la ': 'Ver la ',
    'source': 'fuente',
    ' pour plus de détails.': ' para más detalles.',
    'Réponse CoinGecko invalide': 'Respuesta de CoinGecko no válida',
    'Prix de marché absents': 'Faltan los precios de mercado',
    'Impossible de récupérer les cours BTC/ETH et aucun cache n’est disponible':
        'No se han podido obtener los precios de BTC/ETH y no hay datos en caché disponibles',
    'Graphique Bitcoin': 'Gráfico de Bitcoin',
    'Cours du Bitcoin': 'Precio de Bitcoin',
    'Actualiser': 'Actualizar',
    'Chargement…': 'Cargando…',
    'Chargement...': 'Cargando...',
    'Aucune donnée disponible.': 'No hay datos disponibles.',
    'Retour': 'Volver',
    'Fermer': 'Cerrar',
    'Copier': 'Copiar',
    'Ouvrir': 'Abrir',
    'Télécharger': 'Descargar',
    'Partager': 'Compartir',
    'Source': 'Fuente',
    'Trimestre': 'Trimestre',
    'Prix': 'Precio',
    'Cours du BTC (€)': 'Precio de BTC (€)',
    'Prix du produit (€)': 'Precio del producto (€)',
    'Prix du produit (BTC)': 'Precio del producto (BTC)',
    'Afficher en échelle logarithmique': 'Mostrar en escala logarítmica',
    'Échelle logarithmique': 'Escala logarítmica',
    'Échelle linéaire': 'Escala lineal',
    'À propos': 'Acerca de',
    'Ressources': 'Recursos',
    'Acheter': 'Comprar',
    'Comprendre': 'Aprender',
    'Faire un don': 'Donar',
    'Page précédente': 'Página anterior',
    'Page suivante': 'Página siguiente',
    'Configuration nécessaire': 'Configuración necesaria',
    'Actualisation nécessaire': 'Actualización necesaria',
    'Touchez le widget': 'Toca el widget',
    'Actualisation…': 'Actualizando…',
    'En attente du premier cours': 'Esperando el primer precio',
    'Produit supprimé': 'Producto eliminado',
    'Touchez pour choisir': 'Toca para elegir',
    'un autre produit': 'otro producto',
    'Hors ligne': 'Sin conexión',
    'Aucun produit disponible.': 'No hay productos disponibles.',
    'Configurer le widget': 'Configurar widget',
    'Item affiché': 'Elemento mostrado',
    'Apparence': 'Apariencia',
    'Classique · fond plein': 'Clásico · fondo sólido',
    'Transparent · texte blanc': 'Transparente · texto blanco',
    'Transparent · texte noir': 'Transparente · texto negro',
    'Enregistrer le widget': 'Guardar widget',
    'Choisis l’item puis le style adapté à ton fond d’écran.':
        'Elige el elemento y el estilo que mejor se adapte a tu fondo de pantalla.',
    'Écriture du diagnostic widget impossible : ':
        'No se ha podido escribir el diagnóstico del widget: ',
  };

  static const Map<String, String> _officialProductEnglishNames = {
    'baguette': 'Baguette',
    'essence': 'SP95 Gasoline (L)',
    'cigarette': 'Pack of Cigarettes',
    'bière': 'Beer (50 cl)',
    'café': 'Coffee',
    'boeuf': 'Beef (kg)',
    'pizza': 'Pizza',
    'big_mac': 'Big Mac (euro area)',
    'or': 'Gold (1 g)',
    'ethereum': 'Ethereum (1 ETH)',
    'immobilier': 'Real Estate (m²)',
  };

  static const Map<String, String> _officialProductSpanishNames = {
    'baguette': 'Baguette',
    'essence': 'Gasolina SP95 (L)',
    'cigarette': 'Paquete de cigarrillos',
    'bière': 'Cerveza (50 cl)',
    'café': 'Café',
    'boeuf': 'Carne de vacuno (kg)',
    'pizza': 'Pizza',
    'big_mac': 'Big Mac (zona euro)',
    'or': 'Oro (1 g)',
    'ethereum': 'Ethereum (1 ETH)',
    'immobilier': 'Inmuebles (m²)',
  };

  static const Map<String, String> _officialProductFrenchNames = {
    'baguette': 'Baguette',
    'essence': 'Essence SP95 (l)',
    'cigarette': 'Paquet de Cigarette',
    'bière': 'Bière (50cl)',
    'café': 'Café',
    'boeuf': 'Boeuf (kg)',
    'pizza': 'Pizza',
    'big_mac': 'Big Mac (zone euro)',
    'or': 'Or (1 g)',
    'ethereum': 'Ethereum (1 ETH)',
    'immobilier': 'Immobilier (m2)',
  };
}

String tr(String source) => AppTranslations.tr(source);
