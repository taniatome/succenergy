import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_response.dart';
import '../../data/models/exercise_step.dart';
import '../../data/models/goal.dart';
import '../../data/repositories/exercises_repository.dart';
import '../../data/repositories/goals_repository.dart';
import 'widgets/session_chrome.dart';
import 'widgets/session_complete_view.dart';
import 'widgets/session_step_view.dart';
import 'widgets/session_transition.dart';

/// A guided exercise, one prompt per screen.
///
/// Every screen is generated from the [Exercise] model, so no exercise is
/// ever written into a widget.
class ExerciseSessionScreen extends StatefulWidget {
  const ExerciseSessionScreen({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  State<ExerciseSessionScreen> createState() => _ExerciseSessionScreenState();
}

class _ExerciseSessionScreenState extends State<ExerciseSessionScreen> {
  final TextEditingController _reflection = TextEditingController();
  final Map<String, String> _answers = <String, String>{};

  Exercise? _exercise;
  Goal? _targetGoal;
  int _index = 0;
  bool _added = false;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ExercisesRepository exercises = context.read<ExercisesRepository>();
    final GoalsRepository goalsRepository = context.read<GoalsRepository>();
    final Exercise? exercise = await exercises.loadExercise(widget.exerciseId);
    final List<ExerciseResponse> saved = await exercises.loadResponses(
      widget.exerciseId,
    );
    final List<Goal> goals = await goalsRepository.loadGoals();
    if (!mounted) {
      return;
    }
    setState(() {
      _exercise = exercise;
      _targetGoal = goals.where((Goal g) => !g.isCompleted).firstOrNull;
      _restore(saved);
    });
  }

  /// Puts previous answers back into the session, so reopening a completed
  /// exercise reviews what was written rather than starting from blank. The
  /// closing reflection comes back with them.
  void _restore(List<ExerciseResponse> saved) {
    for (final ExerciseResponse response in saved) {
      if (response.stepId == ExerciseResponse.reflectionStepId) {
        _reflection.text = response.value;
      }
      _answers[response.stepId] = response.value;
    }
  }

  bool get _isClosing => _exercise != null && _index >= _exercise!.steps.length;

  double get _progress {
    if (_exercise == null) {
      return 0;
    }
    return (_index + 1) / _exercise!.totalScreens;
  }

  Future<void> _next() async {
    final Exercise exercise = _exercise!;
    if (!_isClosing) {
      setState(() {
        _forward = true;
        _index++;
      });
      return;
    }
    final DateTime now = DateTime.now();
    final String reflection = _reflection.text.trim();
    await context.read<ExercisesRepository>().completeExercise(
      exerciseId: exercise.id,
      responses: <ExerciseResponse>[
        for (final ExerciseStep step in exercise.steps)
          ExerciseResponse(
            exerciseId: exercise.id,
            stepId: step.id,
            value: _answers[step.id] ?? '',
            answeredAt: now,
          ),
        if (reflection.isNotEmpty)
          ExerciseResponse(
            exerciseId: exercise.id,
            stepId: ExerciseResponse.reflectionStepId,
            value: reflection,
            answeredAt: now,
          ),
      ],
    );
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _addToGoal() async {
    final Goal? goal = _targetGoal;
    final Exercise? exercise = _exercise;
    if (goal == null || exercise == null) {
      return;
    }
    await context.read<GoalsRepository>().addActionItem(
      goalId: goal.id,
      title: exercise.suggestedActionFor(context.localeCode),
    );
    if (mounted) {
      setState(() => _added = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Exercise? exercise = _exercise;

    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.9),
        child: SafeArea(
          child:
              exercise == null
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: Column(
                        children: <Widget>[
                          _header(context, exercise),
                          Expanded(child: _body(context, exercise)),
                          _footer(context),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Exercise exercise) {
    return SessionChrome.header(
      progress: _progress,
      stepLabel: context.tr(
        'exercises.session.step',
        params: <String, String>{
          'current': '${_index + 1}',
          'total': '${exercise.totalScreens}',
        },
      ),
      onClose: () => context.pop(),
    );
  }

  Widget _body(BuildContext context, Exercise exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xl,
        AppSpacing.screenH,
        AppSpacing.lg,
      ),
      child: SessionTransition(
        stepIndex: _index,
        forward: _forward,
        child: _isClosing ? _closing(context, exercise) : _step(exercise),
      ),
    );
  }

  Widget _step(Exercise exercise) {
    final ExerciseStep step = exercise.steps[_index];
    return SessionStepView(
      step: step,
      value: _answers[step.id] ?? '',
      onChanged: (String v) => _answers[step.id] = v,
    );
  }

  Widget _closing(BuildContext context, Exercise exercise) {
    final Goal? goal = _targetGoal;
    return SessionCompleteView(
      reflection: _reflection,
      onReflectionChanged:
          (String v) => _answers[ExerciseResponse.reflectionStepId] = v,
      suggestedAction: exercise.suggestedActionFor(context.localeCode),
      addLabel: context.tr(
        'exercises.done.addToGoal',
        params: <String, String>{
          'goal': goal?.titleFor(context.localeCode) ?? '',
        },
      ),
      onAddToGoal: _addToGoal,
      added: _added || goal == null,
    );
  }

  Widget _footer(BuildContext context) {
    return SessionChrome.footer(
      advanceLabel:
          _isClosing
              ? context.tr('exercises.done.finish')
              : context.tr('common.continue'),
      onAdvance: _next,
      onBack:
          _index == 0
              ? null
              : () => setState(() {
                _forward = false;
                _index--;
              }),
    );
  }
}
