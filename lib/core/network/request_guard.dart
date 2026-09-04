import 'package:flutter/foundation.dart';

import 'request_failure.dart';

/// The loading and failure state every provider that reaches the network
/// keeps.
///
/// A mixin rather than a base class so a provider still extends
/// [ChangeNotifier] and can hold whatever else it needs. It exists so that
/// each provider's error handling is one call rather than a try/catch per
/// method — and so no provider can forget the part that matters: **clearing
/// the loading flag on the way out.** A provider that lets an exception
/// escape leaves its screen on a loader that never resolves, which is the one
/// outcome worse than a wrong message.
mixin RequestGuard on ChangeNotifier {
  bool _busy = false;
  RequestFailure? _failure;

  /// True while a request is in flight.
  bool get isBusy => _busy;

  /// Why the last request failed, or null if it did not.
  RequestFailure? get failure => _failure;

  bool get hasFailed => _failure != null;

  /// Runs [work], holding [isBusy] and catching whatever it throws.
  ///
  /// [showLoading] is false for an action taken from a button that shows its
  /// own progress — the branded loader belongs to an initial load, not to
  /// every tap, so a screen already on the page should not blank itself out
  /// to tick a checkbox.
  ///
  /// Returns true when [work] completed, so a caller can decide whether to
  /// carry on. Everything is caught: a `Future` that escapes a
  /// [ChangeNotifier] becomes an unhandled async error with no screen
  /// attached to it, and the user sees a spinner rather than a reason.
  @protected
  Future<bool> guard(
    Future<void> Function() work, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _busy = true;
    }
    _failure = null;
    notifyListeners();

    try {
      await work();
      return true;
    } on Object catch (error) {
      _failure = RequestFailure.from(error);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Forgets the last failure, so a retry starts from a clean state.
  @protected
  void clearFailure() {
    if (_failure == null) {
      return;
    }
    _failure = null;
    notifyListeners();
  }
}
