import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _sourcePath = 'lib/assets/images/logo.png';

Future<void> main() async {
  final sourceFile = File(_sourcePath);

  if (!sourceFile.existsSync()) {
    stderr.writeln(
      'Logo introuvable : $_sourcePath\n'
      'Vérifie que le fichier existe avant de relancer.',
    );
    exitCode = 1;
    return;
  }

  final sourceBytes = await sourceFile.readAsBytes();
  final source = img.decodeImage(sourceBytes);

  if (source == null) {
    stderr.writeln(
      'Le fichier $_sourcePath ne peut pas être décodé.',
    );
    exitCode = 1;
    return;
  }

  final iconsDirectory = Directory('web/icons');
  await iconsDirectory.create(recursive: true);

  await _writeIcon(
    source: source,
    path: 'web/satoshi-index-favicon.png',
    size: 64,
    logoScale: 0.90,
    orangeBackground: false,
  );

  await _writeIcon(
    source: source,
    path: 'web/icons/satoshi-index-192.png',
    size: 192,
    logoScale: 0.90,
    orangeBackground: false,
  );

  await _writeIcon(
    source: source,
    path: 'web/icons/satoshi-index-512.png',
    size: 512,
    logoScale: 0.90,
    orangeBackground: false,
  );

  // Une icône maskable peut être rognée par Android.
  // Le logo est donc légèrement réduit et centré sur un fond orange.
  await _writeIcon(
    source: source,
    path: 'web/icons/satoshi-index-maskable-192.png',
    size: 192,
    logoScale: 0.66,
    orangeBackground: true,
  );

  await _writeIcon(
    source: source,
    path: 'web/icons/satoshi-index-maskable-512.png',
    size: 512,
    logoScale: 0.66,
    orangeBackground: true,
  );

  stdout.writeln(
    'Icônes web Satoshi Index générées avec succès.',
  );
}

Future<void> _writeIcon({
  required img.Image source,
  required String path,
  required int size,
  required double logoScale,
  required bool orangeBackground,
}) async {
  final canvas = img.Image(
    width: size,
    height: size,
    numChannels: 4,
  );

  img.fill(
    canvas,
    color: orangeBackground
        ? img.ColorRgba8(247, 147, 26, 255)
        : img.ColorRgba8(0, 0, 0, 0),
  );

  final maximumLogoSize = (size * logoScale).round();
  final ratio = math.min(
    maximumLogoSize / source.width,
    maximumLogoSize / source.height,
  );

  final resized = img.copyResize(
    source,
    width: math.max(1, (source.width * ratio).round()),
    height: math.max(1, (source.height * ratio).round()),
    interpolation: img.Interpolation.cubic,
  );

  img.compositeImage(
    canvas,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );

  await File(path).writeAsBytes(
    img.encodePng(canvas),
    flush: true,
  );
}
