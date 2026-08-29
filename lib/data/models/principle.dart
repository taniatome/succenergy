/// The seven Succenergy principles, in cycle order.
///
/// The cycle repeats: Purpose leads to a goal, a plan, action, tracking,
/// progress and completion, then opens the next Purpose.
enum Principle {
  purpose,
  passion,
  planning,
  praxis,
  persistence,
  progress,
  perfection;

  /// Position in the cycle, one-based, as shown to the user.
  int get position => index + 1;

  /// Localisation key for the principle name. The names themselves stay in
  /// their canonical form in both languages.
  String get labelKey => 'principle.$name';

  /// Localisation key for the one-line description of the principle.
  String get descriptionKey => 'principle.$name.desc';

  /// The principle that follows this one, wrapping at the end of the cycle.
  Principle get next => Principle.values[(index + 1) % Principle.values.length];
}
