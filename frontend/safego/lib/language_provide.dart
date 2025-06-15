import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('en', ''); // Default locale is English

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLocale();
  }

  // Load the saved locale from SharedPreferences
  _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    String? countryCode = prefs.getString('countryCode');
    if (languageCode != null && countryCode != null) {
      _locale = Locale(languageCode, countryCode);
    }
    notifyListeners();
  }

  // Change language and save it to SharedPreferences
  void changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', locale.languageCode);
    prefs.setString('countryCode', locale.countryCode ?? '');
    _locale = locale;
    notifyListeners();
  }
}
