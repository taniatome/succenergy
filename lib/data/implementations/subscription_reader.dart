import '../../core/auth/secure_session_store.dart';

/// Reads whether an account may open the app past the paywall.
///
/// The subscription lives in Postgres and is written only by verified
/// RevenueCat webhooks, but `GET /v1/me` does not yet return it: the column
/// and the repository join exist, and the response mapper leaves it out. So
/// this reads the field when it is there and falls back to what the device
/// recorded when the trial was taken.
///
/// The fallback is deliberately the weaker source and loses to the server the
/// moment the server has an answer. When the API starts carrying the
/// subscription, deleting the fallback branch is the whole change.
class SubscriptionReader {
  const SubscriptionReader._();

  /// Statuses that open the app, matching `isSubscriptionActive` in the API.
  static const Set<String> _openStatuses = <String>{'trialing', 'active'};

  static Future<bool> hasAccess({
    required Map<String, Object?> profile,
    required String uid,
    required SecureSessionStore store,
  }) async {
    final bool? reported = fromProfile(profile);
    if (reported != null) {
      return reported;
    }
    return store.hasTakenTrial(uid);
  }

  /// What the server said, or null when it said nothing.
  static bool? fromProfile(Map<String, Object?> profile) {
    final Object? subscription = profile['subscription'];
    if (subscription is! Map<String, Object?>) {
      return null;
    }
    final Object? active = subscription['isActive'];
    if (active is bool) {
      return active;
    }
    final Object? status = subscription['status'];
    return status is String ? _openStatuses.contains(status) : null;
  }
}
