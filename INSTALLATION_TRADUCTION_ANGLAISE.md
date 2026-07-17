# Installation du patch français / anglais

Ce patch transforme le sélecteur de langue déjà présent en véritable
internationalisation complète de Satoshi Index.

Il ne crée pas une seconde copie des pages. Les mêmes fichiers Dart sont
utilisés en français et en anglais grâce à un dictionnaire central hors ligne.

## Fonctionnalités couvertes

- changement de langue immédiat depuis Paramètres ;
- mémorisation du choix après fermeture de l'application ;
- langue du téléphone utilisée à la première ouverture si elle est française
  ou anglaise ;
- français utilisé comme langue de secours ;
- traduction de l'accueil et de toutes les pages ;
- traduction des noms des produits officiels ;
- traduction des douze devises ;
- traduction du convertisseur et des comparaisons ;
- traduction des prix personnalisés ;
- traduction de la gestion des trois produits personnels ;
- conservation exacte des noms saisis par l'utilisateur ;
- traduction des fiches produit, graphiques, tableaux et sources ;
- traduction de la page Bull Bitcoin ;
- white paper original anglais fourni localement ;
- synchronisation de la langue avec les widgets Android ;
- traduction de l'écran natif de configuration des widgets ;
- traduction des états du widget, y compris hors ligne et produit supprimé.

Aucun service de traduction en ligne et aucune clé API ne sont utilisés.

---

## 1. Sauvegarde préalable

```bash
cd ~/Documents/Satoshi_Index

git status --short
```

Le plus sûr est d'effectuer un commit avant l'installation :

```bash
git add -A
git commit -m "chore: save project before English localization"
```

---

## 2. Copier le patch

```bash
rm -rf /tmp/satoshi_index_english_patch
mkdir -p /tmp/satoshi_index_english_patch

unzip ~/Téléchargements/satoshi_index_full_english_patch.zip \
  -d /tmp/satoshi_index_english_patch
```

Adaptez le chemin si votre navigateur utilise `Downloads`.

Copiez ensuite les fichiers en conservant leur arborescence :

```bash
cp -a /tmp/satoshi_index_english_patch/. \
  ~/Documents/Satoshi_Index/
```

---

## 3. Relier les pages existantes à la traduction

```bash
cd ~/Documents/Satoshi_Index

python3 tool/apply_full_english_localization.py
```

Le script :

1. relie automatiquement les pages Flutter existantes à la couche de
   traduction, sans modifier leur logique ;
2. ajoute `flutter_localizations` dans `pubspec.yaml` ;
3. déclare le PDF anglais dans les assets.

Il peut être relancé sans créer de doublons.

---

## 4. Formater et vérifier

```bash
cd ~/Documents/Satoshi_Index

dart format lib test

flutter clean
flutter pub get

flutter analyze
flutter test
flutter build apk --debug
```

L'APK de test se trouvera normalement ici :

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Installation sur un appareil connecté :

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 5. Vérifier la version web

```bash
flutter build web \
  --release \
  --base-href "/Satoshi_Index/"
```

---

## 6. Parcours de test conseillé

### Application

1. Ouvrir Paramètres.
2. Choisir English.
3. Vérifier que Paramètres change immédiatement.
4. Revenir à l'accueil.
5. Vérifier les noms des produits officiels.
6. Ouvrir toutes les pages :
   - fiche produit ;
   - Tools ;
   - Custom prices ;
   - My products ;
   - sélection de devise ;
   - Bull Bitcoin ;
   - page satoshi ;
   - Bitcoin White Paper ;
   - donation ;
   - page de présentation ;
   - TradingView.
7. Fermer complètement l'application.
8. La rouvrir et vérifier que l'anglais est conservé.
9. Repasser en français.

### Produits personnels

1. Créer un produit avec un nom libre.
2. Passer en anglais.
3. Vérifier que ce nom n'est ni traduit ni modifié.
4. Vérifier que les libellés autour de lui sont en anglais.

### Widgets Android

1. Choisir English dans l'application.
2. Revenir à l'accueil pour synchroniser le snapshot.
3. Ajouter ou reconfigurer un widget.
4. Vérifier l'écran natif de configuration en anglais.
5. Vérifier les noms anglais des produits officiels.
6. Vérifier qu'un produit personnel conserve son nom.
7. Toucher le widget pour tester `Refreshing…`.
8. Supprimer un produit personnel utilisé par un widget.
9. Vérifier l'affichage `Product deleted`.

---

## 7. Fichiers principaux ajoutés

```text
lib/l10n/app_translations.dart
lib/l10n/localized_widgets.dart

lib/assets/pdf/bitcoin-whitepaper-en.pdf

android/app/src/main/kotlin/com/example/satoshi_index/widgets/
  WidgetTranslations.kt

android/app/src/main/res/values-en/widget_strings.xml

test/app_translations_test.dart
test/settings_localization_test.dart

tool/apply_full_english_localization.py
```

## 8. Fichiers principaux remplacés

```text
lib/main.dart
lib/models/app_currency.dart
lib/models/user_product.dart

lib/pages/bullbitcoin_page.dart
lib/pages/currency_selection_page.dart
lib/pages/custom_prices_page.dart
lib/pages/outils_page.dart
lib/pages/settings_page.dart
lib/pages/user_products_page.dart
lib/pages/whitepaper_page.dart

lib/services/product_export_service.dart
lib/services/user_product_service.dart

android/app/src/main/kotlin/com/example/satoshi_index/widgets/
  ProductWidgetCatalog.kt
  ProductWidgetConfigureActivity.kt
  ProductWidgetModels.kt
  ProductWidgetProvider.kt
  ProductWidgetRepository.kt
  ProductWidgetUpdateWorker.kt
```

Le script ajuste aussi les imports des autres pages de `lib/pages`, notamment
la fiche produit, la donation, le logo, la page satoshi et TradingView.

---

## 9. Comportement de la langue

```text
Première ouverture :
- téléphone français -> français
- téléphone anglais  -> anglais
- autre langue       -> français

Après un choix manuel :
- le choix enregistré reste prioritaire
```

Les noms des trois produits personnels restent toujours tels que l'utilisateur
les a saisis.

---

## 10. Annuler le patch

Avant commit :

```bash
cd ~/Documents/Satoshi_Index

git status --short
git restore .
git clean -fd
```

Attention : `git clean -fd` supprime les nouveaux fichiers non suivis.

---

## 11. Commit suggéré

```bash
git add -A

git commit -m "feat: add complete French and English localization"
```
