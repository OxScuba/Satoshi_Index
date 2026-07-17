class AppTranslations {
  AppTranslations._();

  static String _languageCode = 'fr';

  static String get languageCode => _languageCode;
  static bool get isEnglish => _languageCode == 'en';

  static final Map<String, String> _normalizedEnglish = <String, String>{
    for (final entry in _english.entries)
      _translationKey(entry.key): entry.value,
  };

  static String _translationKey(String source) {
    return source.replaceAll(RegExp(r'\\s+'), ' ').trim().toLowerCase();
  }

  static String productName(String productId, String fallback) {
    if (!isEnglish) {
      return fallback;
    }

    return _officialProductNames[productId] ?? tr(fallback);
  }

  static void setLanguage(String languageCode) {
    _languageCode = languageCode.toLowerCase() == 'en' ? 'en' : 'fr';
  }

  static String tr(String source) {
    if (!isEnglish || source.isEmpty) {
      return source;
    }

    final exact =
        _english[source] ??
        _english[source.trim()] ??
        _normalizedEnglish[_translationKey(source)];

    if (exact != null) {
      return exact;
    }

    return _translateDynamic(source);
  }

  static String _translateDynamic(String source) {
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

    for (final entry in _officialProductNames.entries) {
      final frenchName = _officialProductFrenchNames[entry.key];
      if (frenchName != null && source.endsWith(frenchName)) {
        return source.substring(0, source.length - frenchName.length) +
            entry.value;
      }
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

  static const Map<String, String> _officialProductNames = {
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
