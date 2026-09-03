import 'package:flutter/foundation.dart';

import '../../../data/models/user.dart';

/// What registration has collected so far.
///
/// Created once above the three step routes and read by all of them, which is
/// what lets step three submit everything in one call rather than writing a
/// partial account at each step.
///
/// The password is held in memory here between step one and step three,
/// because the Firebase account is not created until the user has agreed to
/// the terms — signing someone up before they consent, then deleting the
/// account if they back out, is worse. It is never written to disk, and the
/// draft is discarded with the route.
class RegistrationDraft extends ChangeNotifier {
  // --- Step one: the account ----------------------------------------------

  String email = '';
  String password = '';

  // --- Step two: about you -------------------------------------------------

  String name = '';
  DateTime? dateOfBirth;
  String? countryCode;
  UserActivity? activity;

  // --- Step three: consent -------------------------------------------------

  bool acceptedTerms = false;
  bool confirmedTruth = false;

  /// Carried back to step one when the address turns out to be taken.
  ///
  /// Step one validates the email at the time it is typed, but the account is
  /// not created until step three, so the address can be claimed in between.
  /// The message travels on the draft rather than as a route parameter,
  /// because an email address has no business being in a URL.
  String? accountErrorKey;

  /// True once step one has enough to move on. The step itself validates the
  /// shape; this only asks whether anything is there at all.
  ///
  /// It is also what tells step three which call to make. A draft with no
  /// credential can only have been entered at step two, which is what the
  /// router does when a signed-in account has no profile — so there is nothing
  /// to create and only the profile to write. No screen has to read the
  /// session to work that out.
  bool get hasAccount => email.isNotEmpty && password.isNotEmpty;

  /// True once step two has every answer it asks for.
  bool get hasAboutYou =>
      name.isNotEmpty &&
      dateOfBirth != null &&
      countryCode != null &&
      activity != null;

  /// Both boxes ticked. Step three blocks submission until this holds.
  bool get hasConsent => acceptedTerms && confirmedTruth;

  /// What the monthly rate after the trial will follow from. Defaults to the
  /// standard rate until the choice is made.
  UserActivity get chosenActivity => activity ?? UserActivity.professional;

  void setAccount({required String email, required String password}) {
    this.email = email;
    this.password = password;
    accountErrorKey = null;
    notifyListeners();
  }

  void setAboutYou({
    required String name,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
  }) {
    this.name = name;
    this.dateOfBirth = dateOfBirth;
    this.countryCode = countryCode;
    this.activity = activity;
    notifyListeners();
  }

  void setDateOfBirth(DateTime value) {
    dateOfBirth = value;
    notifyListeners();
  }

  void setCountry(String code) {
    countryCode = code;
    notifyListeners();
  }

  void setActivity(UserActivity value) {
    activity = value;
    notifyListeners();
  }

  void setConsent({bool? terms, bool? truth}) {
    acceptedTerms = terms ?? acceptedTerms;
    confirmedTruth = truth ?? confirmedTruth;
    notifyListeners();
  }

  /// Marks the address as taken and clears the password, so step one asks for
  /// both again rather than resubmitting a credential that will fail.
  void rejectAccount(String errorKey) {
    accountErrorKey = errorKey;
    password = '';
    notifyListeners();
  }

  /// Forgets the password once the credential exists.
  ///
  /// Called when the sign-up succeeded but the profile write behind it did
  /// not. [hasAccount] then reads false, which is what makes the retry write
  /// the profile instead of trying to create the account a second time — and
  /// it takes the password out of memory at the first moment it is no longer
  /// needed.
  void markAccountCreated() {
    password = '';
    notifyListeners();
  }

  void clearAccountError() {
    if (accountErrorKey == null) {
      return;
    }
    accountErrorKey = null;
    notifyListeners();
  }
}
