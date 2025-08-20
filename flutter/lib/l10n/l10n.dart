import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'index.dart';

class AppLocalizations {
  AppLocalizations(this.localeName);

  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null || locale.countryCode!.isEmpty
            ? locale.languageCode
            : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final String localeName;

  String get appName {
    return Intl.message('Outfit',
        name: 'appName', desc: '', locale: localeName);
  }

  String get username {
    return Intl.message('UserName',
        name: 'username', desc: '', locale: localeName);
  }

  String get usernameInputTip {
    return Intl.message('Please input your username',
        name: 'usernameInputTip', desc: '', locale: localeName);
  }

  String get email {
    return Intl.message('Email', name: 'email', desc: '', locale: localeName);
  }

  String get emailInputTip {
    return Intl.message('Please input your email',
        name: 'emailInputTip', desc: '', locale: localeName);
  }

  String get emailInvalidTip {
    return Intl.message('Please enter a valid email',
        name: 'emailInvalidTip', desc: '', locale: localeName);
  }

  String get password {
    return Intl.message('Password',
        name: 'password', desc: '', locale: localeName);
  }

  String get passwordInputTip {
    return Intl.message('The password cannot be less than 6 characters',
        name: 'passwordInputTip', desc: '', locale: localeName);
  }

  String get login {
    return Intl.message('Log in', name: 'login', desc: '', locale: localeName);
  }

  String get toRegister {
    return Intl.message('Don\'t have an account? Register',
        name: 'toRegister', desc: '', locale: localeName);
  }

  String get register {
    return Intl.message('Register',
        name: 'register', desc: '', locale: localeName);
  }

  String get toLogin {
    return Intl.message('Already have an account? Log in',
        name: 'toLogin', desc: '', locale: localeName);
  }

  String get registerFailed {
    return Intl.message('Register failed!',
        name: 'registerFailed', desc: '', locale: localeName);
  }

  String get home {
    return Intl.message('Home', name: 'home', desc: '', locale: localeName);
  }


  String get profile {
    return Intl.message('Profile',
        name: 'profile', desc: '', locale: localeName);
  }

  String get chart {
    return Intl.message('Chart',
        name: 'chart', desc: '', locale: localeName);
  }

  String get device {
    return Intl.message('Device',
        name: 'device', desc: '', locale: localeName);
  }


  String get searchInputTip {
    return Intl.message('Please input key to search',
        name: 'searchInputTip', desc: '', locale: localeName);
  }

  String get searchFor {
    return Intl.message('Search For',
        name: 'searchFor', desc: '', locale: localeName);
  }

  String get recommendation {
    return Intl.message('Recommendation',
        name: 'recommendation', desc: '', locale: localeName);
  }



  String get favorites {
    return Intl.message('Favorites',
        name: 'favorites', desc: '', locale: localeName);
  }

  String get edit {
    return Intl.message('edit', name: 'edit', desc: '', locale: localeName);
  }

  String get complete {
    return Intl.message('complete',
        name: 'complete', desc: '', locale: localeName);
  }

  String get clearAll {
    return Intl.message('Clear All',
        name: 'clearAll', desc: '', locale: localeName);
  }

  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', locale: localeName);
  }

  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', locale: localeName);
  }

  String get records {
    return Intl.message('Records',
        name: 'records', desc: '', locale: localeName);
  }

  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', locale: localeName);
  }

  String get titleTip {
    return Intl.message('Kind tips',
        name: 'titleTip', desc: '', locale: localeName);
  }

  String get saveOutfit {
    return Intl.message('Save Outfits',
        name: 'saveOutfit', desc: '', locale: localeName);
  }

  String get album {
    return Intl.message('Album', name: 'album', desc: '', locale: localeName);
  }

  String get flip {
    return Intl.message('Flip', name: 'flip', desc: '', locale: localeName);
  }

  String get emptyTip {
    return Intl.message('It\'s empty!',
        name: 'emptyTip', desc: '', locale: localeName);
  }

  String get recorderTitle {
    return Intl.message('Edit outfit info',
        name: 'recorderTitle', desc: '', locale: localeName);
  }

  String get recorderInputTip {
    return Intl.message('Please input content',
        name: 'recorderInputTip', desc: '', locale: localeName);
  }

  String get recorderName {
    return Intl.message('Name',
        name: 'recorderName', desc: '', locale: localeName);
  }

  String get recorderDescription {
    return Intl.message('Description',
        name: 'recorderDescription', desc: '', locale: localeName);
  }

  String get recorderCategory {
    return Intl.message('Category',
        name: 'recorderCategory', desc: '', locale: localeName);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
