<div align="center">

<img src="lib/assets/images/logo.png" alt="Satoshi Index logo" width="120">

# Satoshi Index

### Everyday prices viewed through Bitcoin

[![MIT License](https://img.shields.io/badge/license-MIT-f7931a.svg)](LICENSE.md)
[![Flutter](https://img.shields.io/badge/Flutter-application-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-APK-3DDC84?logo=android&logoColor=white)](https://github.com/OxScuba/Satoshi_Index/releases/latest)
[![Latest release](https://img.shields.io/github/v/release/OxScuba/Satoshi_Index?color=f7931a&label=release)](https://github.com/OxScuba/Satoshi_Index/releases/latest)

[Français](README.md) · **English**

**Satoshi Index** is an open-source application that compares the changing prices of everyday products in fiat currencies, bitcoins, and satoshis.

It offers another way to look at inflation: not only by asking how much a coffee, baguette, or square metre of real estate costs in euros, but also how many satoshis are required to buy it over time.

[📱 Download the APK](https://github.com/OxScuba/Satoshi_Index/releases/latest)
·
[🌐 Open the web version](https://oxscuba.github.io/Satoshi_Index/)
·
[🐛 Report an issue](https://github.com/OxScuba/Satoshi_Index/issues)

</div>

---

<p align="center">
  <img src="lib/assets/images/001.png" alt="Satoshi Index home screen" width="760">
</p>

## Why Satoshi Index?

Traditional statistics usually show how prices change in a currency whose own value is also changing.

Satoshi Index adds another unit of measurement: **Bitcoin**.

The application can help answer questions such as:

- How many satoshis were needed to buy a baguette several years ago?
- How has the price of a coffee changed in euros and in Bitcoin?
- How many everyday goods can be purchased with a given amount of BTC?
- Is the price I actually pay different from the statistical reference price?
- How many satoshis is a product from my own daily life worth?
- How do products appear in my own currency?

> **1 bitcoin = 100,000,000 satoshis**

---

## Features

### Prices and purchasing power

- Display products in **BTC** or directly in **satoshis**.
- Convert fiat prices into the selected currency.
- Highlight the significant digits of Bitcoin prices in orange.
- Regularly update Bitcoin and Ethereum market prices through CoinGecko.
- Keep the latest available market prices in a local cache for offline use.

### Quarterly history

Each official product page includes:

- price history in euros;
- price history in Bitcoin and satoshis;
- linear and logarithmic charts;
- a detailed quarter-by-quarter table;
- the historical Bitcoin price used for each calculation;
- the source of the series when available.

Historical data remain displayed in their reference currency so that the past is not rewritten according to the currency selected today.

### Custom prices

Users can replace the latest statistical price of an official product with the price they actually pay:

- coffee from their usual café;
- a baguette from their local bakery;
- beer, pizza, or fuel;
- the price of gold offered by their dealer.

The custom price is used on:

- the home screen;
- the Tools page;
- Android widgets.

Charts and historical tables always retain the official quarterly data.

Custom prices are stored **locally in euros** and never leave the device.

### Personal products

In addition to the historical products included in the application, users can create up to **three personal products** based on their own habits.

Each personal product includes:

- a name;
- an emoji;
- a current price;
- an original currency selected from the twelve supported currencies.

Examples include:

- 🥐 a croissant;
- 🍜 a bowl of noodles;
- 🚇 a metro ticket;
- 🥙 a kebab;
- 🎟️ a cinema ticket.

Personal products appear:

- at the bottom of the home screen;
- in the comparisons available on the Tools page;
- in the product list available to Android widgets.

Their price is automatically converted into BTC, satoshis, and the selected display currency. The original currency remains stored so that a product entered in HKD, USD, or RUB is not artificially frozen into euros.

Unlike official products, personal products do not have a historical page, chart, or quarterly series. They represent only a current price chosen by the user.

Personal products are stored locally and can be edited or deleted at any time.

### Three interface languages

Satoshi Index is available in:

- 🇫🇷 French;
- 🇬🇧 English;
- 🇪🇸 Spanish.

The selected language is applied to the application interface, official product names, currencies, educational pages, Bitcoin white papers, and Android widgets.

Names entered by users for their personal products are never translated automatically.

### Twelve currencies

Satoshi Index supports:

| Code | Currency | Symbol |
|:---:|---|:---:|
| EUR | Euro | € |
| USD | US Dollar | $ |
| GBP | British Pound | £ |
| CHF | Swiss Franc | CHF |
| CAD | Canadian Dollar | CA$ |
| AUD | Australian Dollar | A$ |
| JPY | Japanese Yen | ¥ |
| CNY | Chinese Yuan | CN¥ |
| HKD | Hong Kong Dollar | HK$ |
| SGD | Singapore Dollar | S$ |
| RUB | Russian Ruble | ₽ |
| ILS | Israeli New Shekel | ₪ |

The Bitcoin price, home-screen cards, custom prices, personal products, Ethereum, converter, and widgets all use the selected currency automatically.

### Universal converter

The **Tools** page provides instant conversion between:

1. satoshis;
2. bitcoins;
3. euros;
4. a selected secondary currency.

When the euro is selected, the fourth line displays the US dollar. For any other selected currency, the fourth line becomes that currency.

The same page also calculates the corresponding purchasing power:

```text
100,000 sats
≈ X coffees
≈ X baguettes
≈ X grams of gold
```

### Configurable Android widgets

Satoshi Index provides native Android home-screen widgets with:

- a separate product choice for each widget;
- support for multiple widgets;
- BTC or sats display;
- currency synchronised with the application;
- support for custom prices;
- support for personal products;
- autonomous periodic refresh;
- manual refresh by tapping the widget;
- an initial compact `2 × 1` format;
- horizontal resizing;
- text and content adapted to the available width.

Three appearances are available:

- **Classic**, with a solid background;
- **Transparent**, with white text;
- **Transparent**, with black text.

The significant digits of Bitcoin prices remain orange in every theme.

### Bitcoin resources

The application also includes:

- an educational explanation of the satoshi;
- a BTC-to-sats conversion table;
- an integrated Bitcoin chart through TradingView;
- the Bitcoin white paper in French, English, and Spanish;
- a resource page for buying and understanding Bitcoin;
- a Bitcoin donation page.

---

## Products and data

The data are organised quarterly and are currently updated through **Q2 2026**.

| Product | Displayed unit | Main source or method | Custom price |
|---|---|---|:---:|
| 🥖 Baguette | One baguette | INSEE bread series, adjusted to one baguette | ✅ |
| ⛽ SP95 Gasoline | One litre | INSEE series | ✅ |
| 🚬 Cigarettes | One pack | INSEE series | ✅ |
| 🍺 Beer | 50 cl | INSEE series, adjusted from 25 cl | ✅ |
| ☕ Coffee | One cup | INSEE price per kilogram, adjusted per cup | ✅ |
| 🥩 Beef | One kilogram | INSEE series | ✅ |
| 🍕 Pizza | One pizza | Project historical series | ✅ |
| 🍔 Big Mac | One Big Mac, euro area | *The Economist* Big Mac Index | ✅ |
| 🪙 Gold | One gram | Reference series converted into grams | ✅ |
| 💩 Ethereum | One ETH | CoinGecko historical and live market price | No, live price |
| 🏠 Real estate | One square metre | Real-estate index and reference base | No |

> Adjustments convert statistical series into concrete, understandable units. They are documented in the files under [`lib/data`](lib/data).

In addition to these eleven official products, users can create up to **three personal products** stored locally. These products do not have a historical series, but they use the same current BTC, sats, and fiat currency conversions.

---

## Usage

### Install the Android application

1. Open the [Releases](https://github.com/OxScuba/Satoshi_Index/releases/latest) page.
2. Download the latest `.apk` file.
3. Temporarily allow installation from that source if Android requests it.
4. Install and open Satoshi Index.

### Change the language

1. Open **Settings**.
2. Select **Language**.
3. Choose French, English, or Spanish.
4. Return to the application.

The choice is saved locally and remains active after the application is closed.

### Add an Android widget

1. Open Satoshi Index once to synchronise market prices.
2. Long-press the Android home screen.
3. Open the **Widgets** section.
4. Select **Satoshi Index · Product**.
5. Choose the product and appearance.
6. Resize the widget horizontally according to the available space.

### Configure custom prices

1. Open **Settings**.
2. Select **Custom prices**.
3. Enter the price actually paid.
4. Leave a field empty to return to the latest quarterly reference price.
5. Save.

### Add personal products

1. Open **Settings**.
2. Select **My products**.
3. Choose one of the three available slots.
4. Enter a name, emoji, price, and original currency.
5. Save.

The product then appears at the bottom of the home screen, on the Tools page, and in the Android widget selector.

A personal product can be renamed, repriced, or deleted at any time. When a personal product used by a widget is deleted, the widget simply asks the user to select another product.

### Change the display currency

1. Open **Settings**.
2. Select **Display currency**.
3. Search for or choose a currency.
4. Return to the home screen.

The change is applied to the home screen, Tools page, and widgets. Historical series remain displayed in euros.

---

## Screenshots

<p align="center">
  <img src="lib/assets/images/002.png" alt="Satoshi Index screenshot 2" width="30%">
  <img src="lib/assets/images/003.png" alt="Satoshi Index screenshot 3" width="30%">
  <img src="lib/assets/images/004.png" alt="Satoshi Index screenshot 4" width="30%">
</p>

<p align="center">
  <img src="lib/assets/images/005.png" alt="Satoshi Index screenshot 5" width="30%">
  <img src="lib/assets/images/006.png" alt="Satoshi Index screenshot 6" width="30%">
</p>

> Some screenshots may show an earlier version of the interface.

---

## Install from source

### Requirements

- A stable Flutter release with a Dart version compatible with `^3.7.0`;
- Android Studio, Visual Studio Code, or another Flutter development environment;
- an Android device or emulator for APK testing.

### Clone and run

```bash
git clone https://github.com/OxScuba/Satoshi_Index.git
cd Satoshi_Index

flutter pub get
flutter run
```

### Check and build

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --release
```

The generated APK is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Build the web version

```bash
flutter build web --release --base-href "/Satoshi_Index/"
```

The files to publish are generated under:

```text
build/web
```

---

## Simplified architecture

```text
lib/
├── data/          Quarterly historical series
├── models/        Official and personal products, currencies, and market prices
├── pages/         Application screens
├── services/      CoinGecko, cache, customisation, and widgets
└── assets/        Images, logos, and documents

android/app/src/main/kotlin/
└── .../widgets/   Native Android widgets and autonomous refresh
```

Historical data are separated from display logic. Custom prices, the three personal products, language, currency, and other preferences are stored locally with `SharedPreferences`.

---

## Main sources

- [INSEE](https://www.insee.fr/fr/statistiques) for several French price series;
- [CoinGecko](https://www.coingecko.com/) for Bitcoin and Ethereum market prices;
- [Big Mac Index](https://www.economist.com/big-mac-index) by *The Economist*;
- [Bitcoin.org](https://bitcoin.org/bitcoin.pdf) for the Bitcoin white paper;
- [TradingView](https://www.tradingview.com/) for the integrated market chart.

External data and services remain subject to their own terms of use and may experience delays or interruptions.

---

## Privacy

Satoshi Index is designed without user accounts or personal-data collection.

- No account is required.
- Custom prices remain on the device.
- Personal products remain on the device.
- Preferences and cache are stored locally.
- The application does not access contacts, microphone, or camera.
- Internet access is used to retrieve market prices and open selected external resources.
- Widgets use a local application snapshot and refresh the required market prices.

---

## Limitations and disclaimer

Satoshi Index is an educational and informational tool.

- Historical prices may rely on averages, indices, or adjustments.
- Custom prices depend on values entered by the user.
- Personal products do not have historical data or a statistical source.
- Fiat conversions use cross rates calculated from Bitcoin market prices.
- Live prices depend on external services.
- The application does not provide financial advice or an investment recommendation.

---

## Contributing

Contributions are welcome.

Possible areas include:

- adding new products;
- improving or documenting historical series;
- integrating additional countries and international sources;
- adding more currencies;
- improving accessibility and translations;
- optimising Android widgets;
- preparing or improving F-Droid distribution.

Suggested workflow:

```bash
git checkout -b feature/my-feature
git commit -m "feat: describe the feature"
git push origin feature/my-feature
```

Then open a Pull Request or an [issue](https://github.com/OxScuba/Satoshi_Index/issues).

---

## Roadmap

- Publication on F-Droid;
- additional interface languages;
- new price series;
- international sources;
- continued widget improvements;
- more customisation and local-backup options.

---

## License

This project is distributed under the [MIT License](LICENSE.md).

You may use, modify, and redistribute it under the terms of that license.

---

## Support the project

Bitcoin donations can be sent to:

```text
Scuba_Wizard@getalby.com
```

<p align="center">
  <img src="lib/assets/images/donation_qr.png" alt="Bitcoin donation QR code" width="230">
</p>

<div align="center">

**Measuring the world in satoshis can sometimes change the shape of the world.**

</div>
