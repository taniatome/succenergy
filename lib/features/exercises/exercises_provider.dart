import 'package:flutter/foundation.dart';

import '../../core/network/request_guard.dart';

import '../../data/models/exercise.dart';
import '../../data/models/principle.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/repositories/exercises_repository.dart';
import '../../data/repositories/subscription_repository.dart';

/// Backs the exercise library and the guided session that runs from it.
///
/// Locked principles are loaded and listed like any other: the library shows
/// what a subscription opens rather than pretending it is not there. Which
/// ones are locked comes from the subscription tier, read on every call so a
/// plan chosen on the Plans screen takes effect on the way back.
class ExercisesProvider extends ChangeNotifier with RequestGuard {
  ExercisesProvider(this._exercises, this._subscriptions);

  final ExercisesRepository _exercises;
  final SubscriptionRepository _subscriptions;

  List<Exercise> _all = const <Exercise>[];
  Principle? _filter;
  // Loading and failure state come from RequestGuard.

  bool get loading => isBusy;

  /// The principle currently selected, or null for the whole library.
  Principle? get filter => _filter;

  List<Exercise> get visible {
    if (_filter == null) {
      return _all;
    }
    return _all
        .where((Exercise e) => e.principle == _filter)
        .toList(growable: false);
  }

  int get completedCount => _all.where((Exercise e) => e.isCompleted).length;

  /// True when the current tier opens [principle].
  bool isUnlocked(Principle principle) =>
      _subscriptions.currentTier.opens(principle);

  /// True while any principle in the library is still behind a subscription.
  bool get hasLockedPrinciples => !_subscriptions.currentTier.opensWholeLibrary;

  Exercise? byId(String id) {
    for (final Exercise exercise in _all) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  /// Principles that actually have exercises, for the selector row.
  List<Principle> get availablePrinciples {
    final Set<Principle> found = <Principle>{
      for (final Exercise e in _all) e.principle,
    };
    return Principle.values.where(found.contains).toList(growable: false);
  }

  Future<void> load() async {
    await guard(() async {
      _all = await _exercises.loadExercises();
    });
  }

  void setFilter(Principle? principle) {
    _filter = principle;
    notifyListeners();
  }

  /// Re-reads without blanking the screen: the library is already on the
  /// page and only the completed marks change.
  Future<void> refresh() async {
    await guard(() async {
      _all = await _exercises.loadExercises();
    }, showLoading: false);
  }
}
