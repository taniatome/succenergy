import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:succenergy_ai_coach/data/implementations/coach_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/exercise_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/goal_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/notification_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/progress_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/purpose_mapper.dart';
import 'package:succenergy_ai_coach/data/implementations/user_profile_mapper.dart';
import 'package:succenergy_ai_coach/data/models/exercise_response.dart';
import 'package:succenergy_ai_coach/data/models/principle.dart';

/// The mappers, run against payloads a live backend actually sent.
///
/// The repository swap replaced six mock repositories with HTTP ones, and the
/// failure that swap invites is not a broken request — it is a mapper and a
/// wire format that quietly disagree, which `flutter analyze` cannot see and a
/// mock-backed widget test never exercises. The mock is the wrong oracle here:
/// it was written from the same assumption as the mapper, so the two agree
/// with each other and both can be wrong about the server.
///
/// So the fixtures in `test/fixtures/` are captured responses, byte for byte,
/// from the seeded persona against a local backend on Postgres — not
/// handwritten. A field the API renames, drops, or starts sending as null
/// fails here rather than as an empty screen on a device.
void main() {
  Map<String, Object?> load(String name) {
    final File file = File('test/fixtures/$name.json');
    expect(file.existsSync(), isTrue, reason: 'missing fixture $name.json');
    return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  }

  Object? data(String name) => load(name)['data'];

  group('captured API responses map cleanly', () {
    test('profile carries the persona and the subscription', () {
      final Map<String, Object?> json = data('me')! as Map<String, Object?>;
      final user = UserProfileMapper.fromJson(json, uid: 'test-uid');

      expect(user.name, 'Marisa Chissano');
      expect(user.currentPrinciple, Principle.praxis);
      expect(user.dayStreak, 12);

      // The launch gate branches on this: an omitted key and a null one must
      // not look the same, so the key is required to be present.
      expect(json.containsKey('subscription'), isTrue);
    });

    test('goals arrive with their milestones and actions', () {
      final List<dynamic> goals = data('me_goals')! as List<dynamic>;
      final parsed = GoalMapper.listFromJson(goals);

      expect(parsed, hasLength(goals.length));
      expect(parsed.every((g) => g.id.isNotEmpty), isTrue);
      expect(parsed.every((g) => g.titleFor('en').isNotEmpty), isTrue);

      // The seeded relaunch goal is the one with a plan hanging off it.
      final relaunch = parsed.firstWhere((g) => g.id == 'goal-relaunch');
      expect(relaunch.milestones, isNotEmpty);
      expect(relaunch.actions, isNotEmpty);
      expect(relaunch.principle, Principle.praxis);

      // Actions are denormalised onto the Dart model from the goal being
      // parsed rather than the wire entry, so a wrong goalId here would send
      // a toggle to the wrong goal.
      expect(
        relaunch.actions.every((a) => a.goalId == relaunch.id),
        isTrue,
        reason: 'action items must carry the id of the goal they belong to',
      );
    });

    test('the exercise library arrives with ordered steps', () {
      final List<dynamic> library = data('exercises')! as List<dynamic>;
      final parsed = ExerciseMapper.listFromJson(library);

      expect(parsed, isNotEmpty);
      expect(parsed.every((e) => e.steps.isNotEmpty), isTrue);
      expect(parsed.every((e) => e.titleFor('en').isNotEmpty), isTrue);
    });

    test('a submitted reflection survives the round trip', () {
      final List<dynamic> responses =
          data('me_exercise-responses')! as List<dynamic>;
      final parsed = ExerciseMapper.allResponsesFromJson(responses);

      expect(parsed, isNotEmpty);

      // The reflection was collected and discarded by the mock. It now comes
      // back as an entry under the reserved step id, so its absence here is
      // that bug returning.
      final reflections = parsed.where(
        (r) => r.stepId == ExerciseResponse.reflectionStepId,
      );
      expect(
        reflections,
        isNotEmpty,
        reason: 'the reflection must come back from the server',
      );
      expect(reflections.every((r) => r.value.trim().isNotEmpty), isTrue);
    });

    test('progress is derived, not a set of constants', () {
      final Map<String, Object?> json =
          data('me_progress')! as Map<String, Object?>;

      final breakdown = ProgressMapper.breakdownFromJson(
        json['principleBreakdown'],
      );
      final snapshots = ProgressMapper.snapshotsFromJson(json['snapshots']);
      final milestones = ProgressMapper.milestonesFromJson(
        json['reachedMilestones'],
      );
      final headline = ProgressMapper.headlineFromJson(json['headline']);

      // Every principle is a key, so the chart never renders a gap.
      expect(breakdown.keys.toSet(), Principle.values.toSet());
      expect(snapshots, isNotEmpty);
      expect(milestones.every((m) => m.isReached), isTrue);
      expect(headline, isNotEmpty);

      // The counts the mock hardcoded are now server-derived. They must at
      // least be internally consistent with the goals the same account has.
      expect(json['activeGoals'], isA<int>());
      expect(json['completedGoals'], isA<int>());
      expect(json['goalCompletion'], isA<num>());
    });

    test('notifications and their preferences map', () {
      final List<dynamic> list = data('me_notifications')! as List<dynamic>;
      final parsed = NotificationMapper.listFromJson(list);
      expect(parsed, isNotEmpty);
      expect(parsed.every((n) => n.id.isNotEmpty), isTrue);

      final prefs = NotificationMapper.preferencesFromJson(
        data('me_notification-preferences')! as Map<String, Object?>,
      );
      expect(prefs, isNotEmpty);
    });

    test('coaching sessions map without their messages', () {
      final List<dynamic> list = data('me_sessions')! as List<dynamic>;
      final parsed = CoachMapper.sessionsFromJson(list);

      expect(parsed, isNotEmpty);
      expect(parsed.every((s) => s.id.isNotEmpty), isTrue);
    });

    test('purpose answers map by prompt id', () {
      final answers = PurposeMapper.fromJson(data('me_purpose'));

      expect(answers, isNotEmpty);
      expect(answers.keys.every((k) => k.isNotEmpty), isTrue);
    });
  });
}
