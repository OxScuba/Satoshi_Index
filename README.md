# 🧮 Satoshi Index

[![Licence : MIT](https://img.shields.io/badge/Licence-MIT-orange.svg)](LICENSE)
[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue)](https://flutter.dev)

**Satoshi Index** est une application mobile Flutter qui permet de suivre l’évolution des prix des produits du quotidien en euros (€) et en bitcoins (₿), exprimés en **satoshis**. C’est une nouvelle manière de comprendre l’inflation et le pouvoir d’achat à travers le prisme du Bitcoin.

---

![001](lib/assets/images/001.png)

## 📲 Fonctionnalités principales

- 🟠 **Prix du Bitcoin** mis à jour toutes les 2 minutes (API CoinGecko)
- 📈 **Graphiques interactifs** affichant l’évolution des prix en € et en ₿ (logarithmique)
- 📊 **Tableau des données historiques** avec les prix détaillés par trimestre
- 🌗 **Mode sombre** disponible
- ⚙️ **Page paramètres** : choix d’affichage, langue, etc.
- 📚 **Explication du satoshi** (l’unité minimale du bitcoin)
- 🤝 **Page de donation** en bitcoin via QR code
- 🔗 **Sources officielles INSEE** pour les prix des produits
- ✅ **APK prêt à l’emploi** dans les releases GitHub

---

## 🛍️ Produits suivis

Voici la liste complète des produits actuellement disponibles dans l’application :

| Produit         | Emoji | Donnée INSEE                                             | Ajustement                |
|----------------|-------|----------------------------------------------------------|---------------------------|
| 🥖 Baguette     | 🥖    | Prix au kilo de pain                                     | Moyenne de 250g           |
| ⛽ Essence SP95 | ⛽    | Prix au litre (donnée directe)                           | Aucun                     |
| ☕ Café         | ☕    | Prix au kilo                                             | Environ 7g par tasse      |
| 🍺 Bière        | 🍺    | Prix d’un demi (25cl)                                    | Multiplié par 2 (pinte)   |
| 🚬 Cigarette    | 🚬    | Prix du paquet de 20 cigarettes                          | Aucun                     |
| 🥩 Côte de bœuf | 🥩    | Prix au kilo de côte de bœuf                             | Aucun                     |
| 🏠 Immobilier   | 🏠    | Indice des prix immobiliers (référence 2015 = 100)       | Base de 2300 €/m² en 2015 |

---

## 📦 Distribution

- ▶️ [Dernière APK (recommandé)](https://github.com/OxScuba/Satoshi_Index/releases/latest)
- 🏬 [F-Droid (à venir)](https://f-droid.org/fr/)
- 🛒 Google Play Store (à venir)

---

## 🧭 Comment utiliser l’application

1. **Page d’accueil** : Affiche les produits avec leur prix en satoshis (BTC) et en euros.
2. **Page produit** :
   - Deux graphiques :
     - Évolution du prix du produit en BTC (logarithmique)
     - Évolution du prix en euros (linéaire)
   - Tableau complet avec prix du produit, prix du BTC, prix en satoshis pour chaque trimestre.
   - Source cliquable vers les données officielles.
3. **Page "Satoshi to Bitcoin"** :
   - Tableau pédagogique expliquant la correspondance entre les satoshis et les bitcoins.
4. **Page "Tip me in Bitcoin"** :
   - QR code et adresse pour envoyer un soutien en BTC.

---

## 📸 Aperçu visuel

![002](lib/assets/images/002.png)  
![003](lib/assets/images/003.png) 

---

## ⚙️ Installation depuis le code source

### Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) **3.7+**
- Android Studio **ou** Visual Studio Code
- Un appareil ou émulateur Android

### Étapes

```bash
git clone https://github.com/OxScuba/Satoshi_Index.git
cd Satoshi_Index
flutter pub get
flutter run

```
---
## 🔧 Dépendances principales

L’application utilise les packages Flutter suivants :

- [`fl_chart`](https://pub.dev/packages/fl_chart) : affichage des graphiques
- [`http`](https://pub.dev/packages/http) : récupération des prix sur internet (CoinGecko, INSEE…)
- [`xml`](https://pub.dev/packages/xml) : parsing XML (pour les données INSEE)
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) : stockage local des préférences utilisateur
- [`webview_flutter`](https://pub.dev/packages/webview_flutter) : affichage d’un graphique interactif via TradingView
- [`path_provider`](https://pub.dev/packages/path_provider) : accès fichiers (cache local)
- [`flutter_pdfview`](https://pub.dev/packages/flutter_pdfview) & [`syncfusion_flutter_pdfviewer`](https://pub.dev/packages/syncfusion_flutter_pdfviewer) : lecture de PDF (whitepaper Bitcoin)

Pour la liste complète et leurs versions, voir [pubspec.yaml](pubspec.yaml).

---

## 🔒 Confidentialité & Permissions

- L’application **ne collecte aucune donnée personnelle**.
- Toutes les données sont issues de sources publiques et sont stockées localement.
- **Permissions demandées** :  
  - Accès internet (*obligatoire pour récupérer les prix en temps réel*)
  - Aucun accès aux contacts, fichiers utilisateurs, caméra, micro, etc.

---

## 🔗 Sources et licences

- **INSEE** : [insee.fr/statistiques](https://www.insee.fr/fr/statistiques)
- **CoinGecko API** : [coingecko.com](https://www.coingecko.com/)
- **Whitepaper Bitcoin** : [bitcoin.org/bitcoin.pdf](https://bitcoin.org/bitcoin.pdf)

---

## 👨‍💻 Contribuer

Les contributions sont les bienvenues !  
Quelques pistes :

- ✅ Ajouter de nouveaux produits
- 🌍 Intégrer des sources internationales
- 🎨 Améliorer l’UI ou le code Flutter
- 📱 Développer des widgets Android natifs
- 🏬 Préparer la publication sur F-Droid

N’hésitez pas à ouvrir une issue ou à proposer une Pull Request !

---

## 📄 Licence

Ce projet est publié sous licence **MIT**.  
Vous êtes libres de le modifier, distribuer, et le réutiliser dans vos projets.

---

## 🧡 Soutien

Vous aimez ce projet ?  
Vous pouvez soutenir son développement avec un don en **Bitcoin** :

**Scuba_Wizard@getalby.com**  
![logo](lib/assets/images/donation_qr.png)

---