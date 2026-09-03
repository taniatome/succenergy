package com.succenergy.succenergy_ai_coach

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * FlutterFragmentActivity rather than FlutterActivity: BiometricPrompt is a
 * fragment, so local_auth cannot show the system sheet without a
 * FragmentActivity host.
 */
class MainActivity : FlutterFragmentActivity()
