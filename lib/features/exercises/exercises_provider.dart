import 'package:flutter/foundation.dart';

import '../../data/models/exercise.dart';
import '../../data/models/principle.dart';
import '../../data/repositories/exercises_repository.dart';

/// Backs the exercise library and the guided session that runs from it.
class ExercisesProvider extends ChangeNotifier {
  ExercisesProvider(this._exercises);

  final ExercisesRepository _exercises;

  List<Exercise> _all = const <Exercise>[];
  Principle? _filter;
  bool _loading = true;

  bool get loading => _loading;

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
    _loading = true;
    notifyListeners();
    _all = await _exercises.loadExercises();
    _loading = false;
    notifyListeners();
  }

  void setFilter(Principle? principle) {
    _filter = principle;
    notifyListeners();
  }

  Future<void> refresh() async {
    _all = await _exercises.loadExercises();
    notifyListeners();
  }
}
