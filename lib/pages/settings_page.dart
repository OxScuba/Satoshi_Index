import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool showSats = false;
  String selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      showSats = prefs.getBool('showSats') ?? false;
      selectedLanguage = prefs.getString('language') ?? 'fr';
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() => isDarkMode = value);
    _updateSetting('darkMode', value);
    widget.onThemeChanged(value); // callback vers main
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          SwitchListTile(
            title: const Text('Afficher les prix en sats'),
            subtitle: const Text('Remplace 0.00 00X XXX ₿ par X XXX sats'),
            value: showSats,
            onChanged: (value) {
              setState(() => showSats = value);
              _updateSetting('showSats', value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedLanguage = value);
                  _updateSetting('language', value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
