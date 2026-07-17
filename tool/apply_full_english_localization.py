#!/usr/bin/env python3
"""Finish the Satoshi Index French/English localization patch.

Run this script once from the repository root after copying the patch files.
It adds the translation-compatible Text layer to every existing Flutter page
and adds flutter_localizations to pubspec.yaml without replacing the rest of
that file.
"""

from pathlib import Path
import os
import sys

ROOT = Path.cwd()
LIB = ROOT / 'lib'
PUBSPEC = ROOT / 'pubspec.yaml'


def fail(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    raise SystemExit(1)


def patch_dart_file(path: Path) -> bool:
    if 'l10n' in path.parts:
        return False

    text = path.read_text(encoding='utf-8')
    original = text

    plain_import = "import 'package:flutter/material.dart';"
    hidden_import = (
        "import 'package:flutter/material.dart' "
        "hide RichText, Text, TextSpan;"
    )

    if plain_import in text:
        text = text.replace(plain_import, hidden_import, 1)
    elif hidden_import not in text:
        return False

    relative = os.path.relpath(
        LIB / 'l10n' / 'localized_widgets.dart',
        path.parent,
    ).replace(os.sep, '/')
    local_import = f"import '{relative}';"

    if local_import not in text:
        anchor = hidden_import
        text = text.replace(anchor, f'{anchor}\n\n{local_import}', 1)

    if text != original:
        path.write_text(text, encoding='utf-8')
        return True

    return False


def patch_pubspec() -> bool:
    if not PUBSPEC.exists():
        fail('pubspec.yaml not found. Run the script from the repository root.')

    text = PUBSPEC.read_text(encoding='utf-8')
    dependency_changed = 'flutter_localizations:' not in text

    anchor = '  flutter:\n    sdk: flutter\n'
    if anchor not in text:
        fail('Unable to locate the Flutter dependency block in pubspec.yaml.')

    if dependency_changed:
        replacement = (
            anchor
            + '  flutter_localizations:\n'
            + '    sdk: flutter\n'
        )
        text = text.replace(anchor, replacement, 1)

    english_pdf = '  - lib/assets/pdf/bitcoin-whitepaper-en.pdf\n'
    if english_pdf not in text:
        french_pdf = (
            '  - lib/assets/pdf/'
            'LivreBlanc_Verticale_31x21po_Blanc.pdf\n'
        )
        if french_pdf in text:
            text = text.replace(
                french_pdf,
                french_pdf + english_pdf,
                1,
            )
        else:
            raise SystemExit(
                'ERROR: Unable to locate the existing PDF asset in pubspec.yaml.'
            )

    PUBSPEC.write_text(text, encoding='utf-8')
    return dependency_changed


def main() -> None:
    if not LIB.exists():
        fail('lib/ not found. Run the script from the repository root.')

    required = [
        LIB / 'l10n' / 'app_translations.dart',
        LIB / 'l10n' / 'localized_widgets.dart',
        LIB / 'main.dart',
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        fail('Patch files missing: ' + ', '.join(missing))

    changed = []
    targets = [LIB / 'main.dart']
    targets.extend(sorted((LIB / 'pages').glob('*.dart')))

    for path in targets:
        if path.exists() and patch_dart_file(path):
            changed.append(path.relative_to(ROOT))

    pubspec_changed = patch_pubspec()

    print('Localization compatibility layer applied.')
    if changed:
        print('Updated Dart files:')
        for path in changed:
            print(f'  - {path}')
    else:
        print('Dart imports were already up to date.')

    print(
        'pubspec.yaml: '
        + ('flutter_localizations added' if pubspec_changed else 'already configured')
    )


if __name__ == '__main__':
    main()
