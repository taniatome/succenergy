/// One country offered by the registration selector.
///
/// The name is carried per language rather than through the string tables:
/// the list is data, not interface copy, and holding two hundred entries in
/// `app_strings.dart` would bury the copy that is actually written.
class Country {
  /// Positional on purpose: the table below it runs to two hundred rows, and
  /// one row per line is what makes it readable.
  const Country(this.code, this.en, this.pt);

  /// ISO 3166-1 alpha-2 code, which is what gets stored on the account.
  final String code;

  final String en;
  final String pt;

  /// The name in the active language, falling back to English.
  String nameFor(String localeCode) => localeCode == 'pt' ? pt : en;
}
