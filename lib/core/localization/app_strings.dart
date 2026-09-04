/// English and Portuguese copy for every user-facing string in the app.
///
/// Widgets never hold literal display text; they resolve keys through
/// `context.tr(...)`. Succenergy terminology - the product name, Praxis and
/// the seven principle names - stays in its canonical form in both languages.
class AppStrings {
  const AppStrings._();

  /// Locale code to key/value map. Lookups fall back to English.
  static const Map<String, Map<String, String>> values =
      <String, Map<String, String>>{'en': _en, 'pt': _pt};

  static const String fallbackLocale = 'en';

  static const Map<String, String> _en = <String, String>{
    // --- Common ------------------------------------------------------------
    'common.appName': 'Succenergy AI Coach',
    'common.continue': 'Continue',
    'common.back': 'Back',
    'common.next': 'Next',
    'common.skip': 'Skip',
    'common.save': 'Save',
    'common.saveChanges': 'Save changes',
    'common.cancel': 'Cancel',
    'common.done': 'Done',
    'common.edit': 'Edit',
    'common.delete': 'Delete',
    'common.close': 'Close',
    'common.search': 'Search',
    'common.seeAll': 'See all',
    'common.finish': 'Finish',
    'common.start': 'Start',
    'common.resume': 'Resume',
    'common.minutes': 'min',
    'common.of': 'of',
    'common.today': 'Today',
    'common.yesterday': 'Yesterday',
    'common.complete': 'Complete',
    'common.completed': 'Completed',
    'common.active': 'Active',
    'common.inProgress': 'In progress',
    'common.notStarted': 'Not started',
    'common.offline': 'Offline. Showing what was last saved.',

    // --- Principles --------------------------------------------------------
    'principle.purpose': 'Purpose',
    'principle.passion': 'Passion',
    'principle.planning': 'Planning',
    'principle.praxis': 'Praxis',
    'principle.persistence': 'Persistence',
    'principle.progress': 'Progress',
    'principle.perfection': 'Perfection',
    'principle.purpose.desc': 'Know why you are moving before you move.',
    'principle.passion.desc':
        'Find the energy that makes the work sustainable.',
    'principle.planning.desc': 'Turn intention into a sequence you can follow.',
    'principle.praxis.desc': 'Put the plan into practice, today, at real size.',
    'principle.persistence.desc': 'Keep going when the first energy fades.',
    'principle.progress.desc': 'Measure what moved so you can steer.',
    'principle.perfection.desc': 'Refine, close the cycle, and open the next.',
    'principle.eyebrow': 'Principle',

    // --- Welcome -----------------------------------------------------------
    'welcome.taglineLead': 'Activate your ',
    'welcome.taglineEnergy': 'Energy',
    'welcome.taglineMid': ' and discover all your ',
    'welcome.taglineSuccess': 'success within you',
    'welcome.taglineEnd': '.',
    'welcome.by': 'by',
    'welcome.author': 'Dr. Leadership Tânia Tomé',
    'welcome.official': 'OFFICIAL',
    'welcome.cta': 'Start your Journey within.',
    'welcome.ctaEmphasis': 'Journey',
    'welcome.login': 'I already have an account',

    // --- Language ----------------------------------------------------------
    'language.eyebrow': 'Language',
    'language.title': 'Choose your language',
    'language.subtitle':
        'You can change this at any time in Settings. Your coach will speak the language you pick.',
    'language.english': 'English',
    'language.englishNative': 'English',
    'language.portuguese': 'Portuguese',
    'language.portugueseNative': 'Português',
    'language.confirm': 'Continue',

    // --- Auth --------------------------------------------------------------
    'auth.login.eyebrow': 'Welcome back',
    'auth.login.title': 'Continue your cycle',
    'auth.login.subtitle':
        'Your goals, your plan and your coach are where you left them.',
    'auth.login.signingIn': 'Signing you in...',
    'auth.login.toRegister': 'Don\'t have an account? Start your journey.',
    'auth.login.toRegisterLink': 'Start your journey.',
    'auth.register.eyebrow': 'Create account',
    'auth.register.title': 'Begin the first cycle',
    'auth.register.subtitle':
        'Seven questions and your AI Succenergy Coach will know how to work '
        'with you.',
    'auth.register.step': 'Step {current} of {total}',
    'auth.register.step1.title': 'Your account',
    'auth.register.step1.subtitle':
        'An email and a password. Nothing is created until you have seen what '
        'you are signing up for.',
    'auth.register.step2.title': 'About you',
    'auth.register.step2.subtitle':
        'Four answers your coach works from, and the one that sets your rate '
        'after the trial.',
    'auth.register.step3.title': 'Almost there',
    'auth.register.step3.subtitle':
        'Two confirmations and your first cycle begins.',
    'auth.field.name': 'Full name',
    'auth.field.email': 'Email',
    'auth.field.dob': 'Date of birth',
    'auth.field.country': 'Country',
    'auth.field.activity': 'Activity',
    'auth.field.password': 'Password',
    'auth.field.confirmPassword': 'Confirm password',
    'auth.hint.name': 'Your full name',
    'auth.hint.email': 'taniatome@succenergy.com',
    'auth.hint.newPassword': 'At least 8 characters',
    'auth.activity.student': 'Student | Minorities',
    'auth.activity.student.detail':
        'The reduced monthly rate, for students and minorities.',
    'auth.activity.professional': 'Professional',
    'auth.activity.professional.detail':
        'The standard monthly rate, for everyone else.',
    'auth.dob.placeholder': 'Select your date of birth',
    'auth.dob.day': 'Day',
    'auth.dob.month': 'Month',
    'auth.dob.year': 'Year',
    'auth.country.placeholder': 'Select your country',
    'auth.country.search': 'Search countries',
    'auth.country.empty': 'No country matches that.',
    'auth.consent.terms': 'I accept the Terms and Conditions.',
    'auth.consent.termsLink': 'Terms and Conditions',
    'auth.consent.truth':
        'I confirm that all the information I have given is true and accurate.',
    'auth.summary.eyebrow': 'What you are signing up for',
    'auth.summary.trialLabel': 'Your first {days} days',
    'auth.summary.trialValue': '{price}',
    'auth.summary.monthlyLabel': 'Every month after that',
    'auth.summary.monthlyValue': '{price}',
    'auth.summary.cancel': 'Cancel any time before the trial ends.',
    'auth.action.login': 'Sign in',
    'auth.action.createAccount': 'Create my account',
    'auth.action.forgot': 'Forgot password?',
    'auth.toLogin': 'I already have an account',
    'auth.error.nameRequired': 'Tell us what to call you.',
    'auth.error.nameShort': 'That looks too short to be a name.',
    'auth.error.emailRequired': 'Enter your email address.',
    'auth.error.emailInvalid': 'That does not look like an email address.',
    'auth.error.emailInUse': 'That address already has an account.',
    'auth.error.passwordRequired': 'Enter your password.',
    'auth.error.passwordWeak':
        'Use at least 8 characters, with a letter and a number.',
    'auth.error.confirmRequired': 'Enter your password again.',
    'auth.error.passwordMatch': 'The two passwords do not match.',
    'auth.error.dobRequired': 'Enter your date of birth.',
    'auth.error.dobTooYoung': 'You have to be at least 16 to register.',
    'auth.error.countryRequired': 'Choose your country.',
    'auth.error.activityRequired': 'Choose which describes you.',
    'auth.error.signInFailed': 'Incorrect email or password.',
    'auth.error.accountDisabled':
        'This account has been disabled. Please contact support.',
    'auth.error.tooManyAttempts':
        'Too many sign-in attempts. Please wait a few minutes.',
    'auth.error.network': 'No connection. Check your network and try again.',
    'auth.error.unavailable':
        'Sign-in is unavailable on this build. Please try again later.',
    'auth.error.generic': 'Something went wrong. Please try again.',
    'auth.forgot.title': 'Reset your password',
    'auth.forgot.subtitle':
        'Enter the email on your account and we will send a reset link.',
    'auth.forgot.action': 'Send reset link',
    'auth.forgot.sentTitle': 'Check your inbox',
    'auth.forgot.sentBody':
        'If an account exists for {email}, we have sent a reset link.',
    'auth.forgot.spam': 'Check your spam folder if you do not see it.',
    'auth.forgot.backToLogin': 'Back to sign in',
    'auth.biometric.title': 'Sign in faster next time',
    'auth.biometric.bodyFace':
        'Use Face ID to unlock your account without typing your password.',
    'auth.biometric.bodyFingerprint':
        'Use your fingerprint to unlock your account without typing your '
        'password.',
    'auth.biometric.bodyGeneric':
        'Use biometrics to unlock your account without typing your password.',
    'auth.biometric.enable': 'Enable',
    'auth.biometric.later': 'Maybe later',
    'auth.biometric.reason': 'Sign in to your Succenergy AI Coach account',

    // --- Onboarding --------------------------------------------------------
    'onboarding.eyebrow': 'Assessment',
    'onboarding.progress': 'Question {current} of {total}',
    'onboarding.q1.title': 'What do you want to achieve?',
    'onboarding.q1.help':
        'Write it the way you would say it out loud. Specific beats impressive.',
    'onboarding.q1.hint': 'In the next six months I want to...',
    'onboarding.q2.title': 'Which area of your life needs the most energy?',
    'onboarding.q2.help': 'Choose up to two.',
    'onboarding.q3.title': 'What is challenging you right now?',
    'onboarding.q3.help': 'Name the obstacle honestly. Your coach starts here.',
    'onboarding.q3.hint': 'What keeps getting in the way is...',
    'onboarding.q4.title': 'What are your priorities?',
    'onboarding.q4.help': 'Choose the three that matter most this cycle.',
    'onboarding.q5.title': 'What are your main goals?',
    'onboarding.q5.help': 'One or two, in your own words.',
    'onboarding.q5.hint': 'My main goal is...',
    'onboarding.q6.title': 'What motivates you?',
    'onboarding.q6.help':
        'Slide toward the source that pulls you hardest on a difficult day.',
    'onboarding.q6.scaleMin': 'Inner drive',
    'onboarding.q6.scaleMax': 'People I carry',
    'onboarding.q7.title': 'What does success look like for you?',
    'onboarding.q7.help':
        'Describe the day, not the trophy. Your coach will hold you to it.',
    'onboarding.q7.hint': 'I will know it worked when...',
    'onboarding.summary.eyebrow': 'Your profile',
    'onboarding.summary.title': 'This is what your coach heard',
    'onboarding.summary.wants': 'What you want',
    'onboarding.summary.focus': 'Where your energy goes',
    'onboarding.summary.challenge': 'What is in the way',
    'onboarding.summary.priorities': 'Your priorities',
    'onboarding.summary.success': 'What success looks like',
    'onboarding.summary.mainGoals': 'Your main goals',
    'onboarding.summary.motivation': 'Your motivation',
    'onboarding.summary.closing':
        'You start at Purpose. Your first cycle is already drafted, and you can change any of it later.',
    'onboarding.summary.cta': 'Enter the app',
    'onboarding.option.career': 'Career and leadership',
    'onboarding.option.business': 'Business and income',
    'onboarding.option.health': 'Health and energy',
    'onboarding.option.relationships': 'Relationships',
    'onboarding.option.learning': 'Learning and mastery',
    'onboarding.option.finances': 'Finances',
    'onboarding.option.purposeArea': 'Purpose and meaning',
    'onboarding.option.confidence': 'Confidence in the room',
    'onboarding.option.focus': 'Deep focus',
    'onboarding.option.discipline': 'Daily discipline',
    'onboarding.option.visibility': 'Visibility and voice',
    'onboarding.option.balance': 'Balance and recovery',
    'onboarding.option.income': 'Growing income',
    'onboarding.option.team': 'Building a team',
    'onboarding.option.procrastination': 'Stop Procrastination',
    'onboarding.option.stress': 'Eliminate Stress',
    'onboarding.option.balancedLife': 'Balanced Life',

    // --- Entry quiz --------------------------------------------------------
    'quiz.cta': 'Create your account',

    // --- Trial -------------------------------------------------------------
    'trial.eyebrow': 'Before you begin',
    'trial.title': 'Seven days, one dollar',
    'trial.subtitle':
        'The app is free to download. The coach, your goals and your progress '
        'open the moment the trial starts.',
    'trial.after.label': 'After the trial',
    'trial.after.value': '{price} a month',
    'trial.after.student':
        'The Student | Minorities rate, from what you chose at registration.',
    'trial.after.professional':
        'The Professional rate, from what you chose at registration.',
    'trial.unlock.title': 'What the trial opens',
    'trial.unlock.coach': 'The AI Coach, with no message limit',
    'trial.unlock.exercises': 'The Purpose exercises, to open the cycle',
    'trial.unlock.goals': 'Goals, actions and milestones',
    'trial.unlock.progress': 'Your full progress and cycle history',
    'trial.unlock.library': 'Recharge with Succenergy and the library',
    'trial.cta': 'Start 7-day trial',
    'trial.billing.student':
        'After the trial, the Students & Minorities rate of {price} per month '
        'will be charged automatically; you can cancel anytime before the next '
        'billing date, although we encourage you to try the AI Succenergy '
        'Coach for one month and see how it works for you.',
    'trial.billing.professional':
        'After the trial, the Professional rate of {price} per month will be '
        'charged automatically; you can cancel anytime before the next billing '
        'date, although we encourage you to try the AI Succenergy Coach for '
        'one month and see how it works for you.',
    'trialWelcome.eyebrow': 'Welcome',
    'trialWelcome.message':
        'Congratulations, you are on the path to becoming a Succenergy '
        'winner.',

    // --- Recharge ----------------------------------------------------------
    'recharge.title': 'Recharge with Succenergy',
    'recharge.eyebrow': 'Coming soon',
    'recharge.body':
        'A short reset to take between cycles, built on the same seven '
        'principles. It is being prepared and will open here.',

    // --- Dashboard ---------------------------------------------------------
    'dashboard.greeting.morning': 'Good morning, {name}',
    'dashboard.greeting.afternoon': 'Good afternoon, {name}',
    'dashboard.greeting.evening': 'Good evening, {name}',
    'dashboard.greeting.sub': 'Day {day} of your cycle',
    'dashboard.cycle.eyebrow': 'Your cycle',
    'dashboard.cycle.active': 'You are in {principle}',
    'dashboard.action.eyebrow': 'Today',
    'dashboard.action.title': 'Your one action',
    'dashboard.action.markDone': 'Mark as done',
    'dashboard.action.doneToday': 'Done for today',
    'dashboard.goal.eyebrow': 'Active goal',
    'dashboard.goal.next': 'Next milestone',
    'dashboard.coach.eyebrow': 'AI COACH',
    'dashboard.coach.title': 'Talk it through',
    'dashboard.coach.body':
        'Your coach has read this week. Ask it what to do about {goal}.',
    'dashboard.coach.cta': 'Open coach',
    'dashboard.stats.dayStreak': 'DAY STREAK',
    'dashboard.stats.goalsActive': 'GOALS ACTIVE',
    'dashboard.stats.exercises': 'EXERCISES',
    'dashboard.quick.goals': 'Goals',
    'dashboard.quick.exercises': 'Exercises',
    'dashboard.quick.purpose': 'Purpose',
    'dashboard.quick.progress': 'Progress',

    // --- Navigation --------------------------------------------------------
    'nav.home': 'HOME',
    'nav.goals': 'GOALS',
    'nav.coach': 'COACH',
    'nav.exercises': 'PRACTICE',
    'nav.progress': 'PROGRESS',

    // --- Purpose -----------------------------------------------------------
    'purpose.eyebrow': 'Principle One',
    'purpose.title': 'Purpose',
    'purpose.intro':
        'Purpose is not a sentence you find once. It is the answer you keep sharpening. Work through these five prompts and return to them whenever the cycle turns.',
    'purpose.prompt.talents': 'Your talents',
    'purpose.prompt.talents.q':
        'What comes easily to you that other people find hard?',
    'purpose.prompt.strengths': 'Your strengths',
    'purpose.prompt.strengths.q':
        'When you have done your best work, what were you doing?',
    'purpose.prompt.values': 'Your values',
    'purpose.prompt.values.q':
        'What would you refuse to trade, even for a result you want?',
    'purpose.prompt.direction': 'Your direction',
    'purpose.prompt.direction.q':
        'If nothing changed for three years, what would you regret?',
    'purpose.prompt.aspirations': 'Your aspirations',
    'purpose.prompt.aspirations.q': 'Who do you want to be useful to, and how?',
    'purpose.answered': 'Answered',
    'purpose.unanswered': 'Not yet answered',
    'purpose.saveAnswer': 'Save answer',
    'purpose.statement.eyebrow': 'Purpose statement',
    'purpose.statement.title': 'Where this points',

    // --- Goals -------------------------------------------------------------
    'goals.title': 'Goals',
    'goals.tab.active': 'Active',
    'goals.tab.completed': 'Completed',
    'goals.card.next': 'Next',
    'goals.card.due': 'Target',
    'goals.empty.title': 'Your first goal is one sentence away',
    'goals.empty.body':
        'Name what you want, pick the principle it belongs to, and your coach will build the plan around it.',
    'goals.empty.cta': 'Create a goal',
    'goals.emptyCompleted.title': 'Nothing closed yet',
    'goals.emptyCompleted.body':
        'Finished goals collect here with the date you closed them.',
    'goals.create.title': 'New goal',
    'goals.create.name': 'What do you want to achieve?',
    'goals.create.nameHint': 'Name it the way you would say it',
    'goals.create.why': 'Why does it matter?',
    'goals.create.whyHint': 'The reason you will come back to on a hard week',
    'goals.create.principle': 'Which principle leads it?',
    'goals.create.submit': 'Create goal',
    'goals.detail.why': 'Why it matters',
    'goals.detail.milestones': 'Milestones',
    'goals.detail.actions': 'Action items',
    'goals.detail.discuss': 'Discuss with Coach',
    'goals.detail.progress': 'Progress',
    'goals.detail.targetDate': 'Target date',
    'goals.detail.completedOn': 'Closed on',
    'goals.detail.actionsDone': '{done} of {total} done',
    'goals.edit.title': 'Edit goal',
    'goals.edit.submit': 'Save goal',
    'goals.menu.tooltip': 'Goal options',
    'goals.delete.title': 'Delete this goal?',
    'goals.delete.body':
        'Its milestones and its action plan go with it, and the coach stops working from it. It cannot be undone.',
    'goals.delete.confirm': 'Delete goal',
    'goals.delete.done': 'Goal deleted',
    'goals.detail.markComplete': 'Mark complete',
    'goals.detail.reopen': 'Reopen this goal',

    // --- Exercises ---------------------------------------------------------
    'exercises.title': 'Practice',
    'exercises.subtitle':
        'Short guided work, organised by the principle it serves.',
    'exercises.all': 'All',
    'exercises.card.duration': '{minutes} min',
    'exercises.card.completed': 'Completed',
    'exercises.card.start': 'Start',
    'exercises.card.review': 'Review',
    'exercises.locked.badge': 'Locked',
    'exercises.locked.card': 'Open with a subscription',
    'exercises.locked.note':
        'Your trial opens Purpose. A subscription opens the other six '
        'principles.',
    'exercises.empty.title': 'Nothing here for this principle yet',
    'exercises.empty.body':
        'Pick another principle above, or start with Purpose to open the cycle.',
    'exercises.session.step': 'Step {current} of {total}',
    'exercises.session.reflection': 'Closing reflection',
    'exercises.session.reflectionHint': 'What changed while you did this?',
    'exercises.session.answerHint': 'Write it in your own words',
    'exercises.session.exit': 'Leave exercise',
    'exercises.session.exitBody':
        'Your answers so far will not be kept. Leave anyway?',
    'exercises.done.eyebrow': 'Complete',
    'exercises.done.title': 'That is the work done',
    'exercises.done.suggested': 'Suggested next action',
    'exercises.done.addToGoal': 'Add to {goal}',
    'exercises.done.added': 'Added to your action plan',
    'exercises.done.finish': 'Back to practice',
    'exercises.scaleLow': 'Not at all',
    'exercises.scaleHigh': 'Completely',

    // --- AI Coach ----------------------------------------------------------
    'coach.title': 'AI COACH',
    'coach.subtitle': 'Built on the Succenergy methodology',
    'coach.inputHint': 'Say what is actually going on',
    'coach.send': 'Send',
    'coach.thinking': 'Thinking',
    'coach.suggested.eyebrow': 'Try asking',
    'coach.suggestion.stuck': 'I am stuck on this week',
    'coach.suggestion.plan': 'Break my next milestone down',
    'coach.suggestion.energy': 'My energy is low',
    'coach.suggestion.review': 'Review my cycle so far',
    'coach.history': 'History',
    'coach.newSession': 'New session',

    // --- Coaching history --------------------------------------------------
    'history.title': 'Coaching history',
    'history.subtitle': 'Every session, with what came out of it.',
    'history.duration': '{minutes} min',
    'history.messages': '{count} messages',
    'history.transcript': 'Transcript',
    'history.speaker.you': 'YOU',
    'history.empty.title': 'No sessions yet',
    'history.empty.body':
        'When you talk with your coach, each conversation is summarised here.',

    // --- Progress ----------------------------------------------------------
    'progress.title': 'Progress',
    'progress.subtitle': 'Three weeks of evidence.',
    'progress.chart.completion': 'Goal progress over time',
    'progress.chart.byPrinciple': 'Practice by principle',
    'progress.chart.activity': 'Activity',
    'progress.cycle.eyebrow': 'Methodology',
    'progress.cycle.title': 'Where you are in the cycle',
    'progress.milestones.title': 'Milestones reached',
    'progress.stat.completionRate': 'RATE',
    'progress.stat.streak': 'STREAK',
    'progress.stat.sessions': 'SESSIONS',
    'progress.stat.actions': 'ACTIONS',
    'progress.weekLabel': 'Week {number}',

    // --- Notifications -----------------------------------------------------
    'notifications.title': 'Notifications',
    'notifications.tab.inbox': 'Inbox',
    'notifications.tab.preferences': 'Preferences',
    'notifications.markAllRead': 'Mark all read',
    'notifications.empty.title': 'Nothing waiting',
    'notifications.empty.body':
        'Nudges, principle prompts and exercise reminders land here.',
    'notifications.pref.goalNudges': 'Goal nudges',
    'notifications.pref.goalNudges.desc':
        'A prompt when an action item has been open too long.',
    'notifications.pref.principleOfDay': 'Principle of the day',
    'notifications.pref.principleOfDay.desc':
        'One idea each morning from the principle you are in.',
    'notifications.pref.reengagement': 'Re-engagement',
    'notifications.pref.reengagement.desc':
        'A note if you have been away for more than three days.',
    'notifications.pref.exerciseReminders': 'Exercise reminders',
    'notifications.pref.exerciseReminders.desc':
        'A reminder for practice you scheduled but have not started.',
    'notifications.pref.quietHours': 'Quiet hours',
    'notifications.pref.quietHours.desc':
        'Nothing arrives between 21:00 and 07:00.',

    // --- Subscription ------------------------------------------------------
    'subscription.title': 'Plans',
    'subscription.subtitle':
        'One trial, then the rate that matches what you do.',
    'subscription.plan.trial': '7-day trial',
    'subscription.plan.student': 'Student | Minorities',
    'subscription.plan.professional': 'Professional',
    'subscription.perMonth': 'per month',
    'subscription.perTrial': 'for 7 days',
    'subscription.recommended': 'YOUR TIER',
    'subscription.current': 'Your plan',
    'subscription.cta.choose': 'Choose this plan',
    'subscription.cta.current': 'Current plan',
    'subscription.compare.trial': 'What a subscription opens',
    'subscription.compare.included': 'Included in your plan',
    'subscription.premiumColumn': 'Included',
    'subscription.lockedColumn': 'Locked',
    'subscription.feature.coaching': 'AI coaching',
    'subscription.feature.coaching.premium': 'Unlimited',
    'subscription.feature.memory': 'Coach memory',
    'subscription.feature.memory.premium': 'Full history',
    'subscription.feature.exercises': 'Exercise library',
    'subscription.feature.exercises.trial': 'Purpose only',
    'subscription.feature.exercises.premium': 'All seven principles',
    'subscription.feature.goals': 'Active goals',
    'subscription.feature.goals.premium': 'Unlimited',
    'subscription.feature.personalisation': 'Personalisation',
    'subscription.feature.personalisation.premium': 'Adaptive to your profile',
    'subscription.feature.progress': 'Progress reports',
    'subscription.feature.progress.premium': 'Full analytics',
    'subscription.note':
        'Plans are shown for review. Payment is not enabled in this build.',

    // --- Profile -----------------------------------------------------------
    'profile.title': 'Profile',
    'profile.section.account': 'Account',
    'profile.section.coaching': 'Your coaching profile',
    'profile.section.preferences': 'Coaching preferences',
    'profile.field.name': 'Name',
    'profile.field.email': 'Email',
    'profile.field.language': 'Language',
    'profile.pref.tone': 'Coaching tone',
    'profile.pref.tone.direct': 'Direct',
    'profile.pref.tone.warm': 'Warm',
    'profile.pref.tone.challenging': 'Challenging',
    'profile.pref.checkIn': 'Check-in rhythm',
    'profile.pref.checkIn.daily': 'Daily',
    'profile.pref.checkIn.everyOther': 'Every other day',
    'profile.pref.checkIn.weekly': 'Weekly',
    'profile.pref.reminders': 'Practice reminders',
    'profile.memberSince': 'With Succenergy since {date}',
    'profile.saved': 'Profile updated',

    // --- Settings ----------------------------------------------------------
    'settings.title': 'Settings',
    'settings.section.general': 'General',
    'settings.section.account': 'Account',
    'settings.section.security': 'Security',
    'settings.section.subscription': 'Subscription',
    'settings.section.about': 'About',
    'settings.item.language': 'Language',
    'settings.item.notifications': 'Notifications',
    'settings.item.profile': 'Profile',
    'settings.item.changePassword': 'Change password',
    'settings.item.biometric': 'Unlock with biometrics',
    'settings.biometric.on': 'On',
    'settings.biometric.atSignIn': 'Offered at sign-in',
    'settings.biometric.disable':
        'Your saved credentials will be removed from this device. You can turn '
        'it back on the next time you sign in.',
    'settings.biometric.turnOff': 'Turn off',
    'settings.item.plan': 'Your plan',
    'settings.item.managePlan': 'Manage plan',
    'settings.section.succenergy': 'Succenergy',
    'settings.item.recharge': 'Recharge with Succenergy',
    'settings.item.library': 'Succenergy Library',
    'settings.item.booking': 'Book Tânia Tomé',
    'settings.item.connect': 'Connect with Us',
    'settings.connect.instagram': 'Instagram',
    'settings.connect.facebook': 'Facebook',
    'settings.connect.linkedin': 'LinkedIn',
    'settings.connect.youtube': 'YouTube',
    'settings.external': 'Opens in your browser',
    'settings.item.help': 'Help and about',
    'settings.item.terms': 'Terms and conditions',
    'settings.item.privacy': 'Privacy policy',
    'settings.item.admin': 'Management console',
    'settings.item.logout': 'Log out',
    'settings.item.deleteAccount': 'Delete account',
    'settings.logout.title': 'Log out',
    'settings.logout.body': 'You can sign back in at any time.',
    'settings.delete.title': 'Delete your account',
    'settings.delete.body':
        'This removes your goals, your practice history and everything your coach knows about you. It cannot be undone.',
    'settings.delete.confirm': 'Delete permanently',

    // --- Help and about ----------------------------------------------------
    'help.title': 'Help and about',
    'help.about.eyebrow': 'About',
    'help.about.body':
        'Succenergy AI Coach applies the Succenergy methodology developed by Dr. Leadership Tânia Tomé. The coach is built on her method. It is not her, and it will tell you so if you ask.',
    'help.about.attribution':
        'Succenergy is a registered methodology of Dr. Leadership Tânia Tomé.',
    'help.version': 'Version {version}',
    'help.faq.eyebrow': 'Questions',
    'help.faq.q1': 'What are the Seven Principles?',
    'help.faq.a1':
        'Purpose, Passion, Planning, Praxis, Persistence, Progress and Perfection. They are a cycle, not a ladder. You move through all seven, close the loop, and start the next round on firmer ground.',
    'help.faq.q2': 'Is the coach really Tânia Tomé?',
    'help.faq.a2':
        'No. The coach is an AI built on her methodology, trained to work the way the method works. Everything it says follows from the Seven Principles.',
    'help.faq.q3': 'How much does the coach remember?',
    'help.faq.a3':
        'On a Premium plan it holds your full history: your onboarding answers, every goal, and what you have said before. On Free it works from the current session only.',
    'help.faq.q4': 'Can I change my language later?',
    'help.faq.a4':
        'Yes. Settings, then Language. The whole app and your coach switch immediately.',
    'help.faq.q5': 'What happens when I finish a cycle?',
    'help.faq.a5':
        'You close it at Perfection, and your coach opens a new Purpose with what you learned carried forward.',
    'help.contact.eyebrow': 'Contact',
    'help.contact.email': 'Email support',
    'help.contact.emailValue': 'support@succenergy.com',
    'help.legal.terms': 'Terms of use',
    'help.legal.privacy': 'Privacy policy',

    // --- Admin -------------------------------------------------------------
    'admin.gate.eyebrow': 'Restricted',
    'admin.gate.title': 'Management console',
    'admin.gate.body': 'Enter the access code issued to your account.',
    'admin.gate.field': 'Access code',
    'admin.gate.action': 'Unlock',
    'admin.gate.error': 'That code was not recognised.',
    'admin.title': 'Management',
    'admin.tab.users': 'Users',
    'admin.tab.content': 'Content',
    'admin.tab.notify': 'Notify',
    'admin.stat.users': 'USERS',
    'admin.stat.active': 'ACTIVE 7D',
    'admin.stat.premium': 'PREMIUM',
    'admin.stat.sessions': 'SESSIONS 7D',
    'admin.users.search': 'Search users',
    'admin.users.plan': 'Plan',
    'admin.users.planTrial': 'Trial',
    'admin.users.planStudent': 'Student',
    'admin.users.planProfessional': 'Professional',
    'admin.users.lastSeen': 'Last seen',
    'admin.content.exercises': 'Exercise library',
    'admin.content.published': 'Published',
    'admin.content.draft': 'Draft',
    'admin.notify.title': 'Compose notification',
    'admin.notify.audience': 'Audience',
    'admin.notify.audience.all': 'All users',
    'admin.notify.audience.free': 'Free plan',
    'admin.notify.audience.premium': 'Premium',
    'admin.notify.heading': 'Heading',
    'admin.notify.body': 'Message',
    'admin.notify.send': 'Queue for delivery',
    'admin.notify.queued': 'Queued for {audience}',
  };

  static const Map<String, String> _pt = <String, String>{
    // --- Common ------------------------------------------------------------
    'common.appName': 'Succenergy AI Coach',
    'common.continue': 'Continuar',
    'common.back': 'Voltar',
    'common.next': 'Seguinte',
    'common.skip': 'Saltar',
    'common.save': 'Guardar',
    'common.saveChanges': 'Guardar alterações',
    'common.cancel': 'Cancelar',
    'common.done': 'Concluído',
    'common.edit': 'Editar',
    'common.delete': 'Eliminar',
    'common.close': 'Fechar',
    'common.search': 'Pesquisar',
    'common.seeAll': 'Ver tudo',
    'common.finish': 'Terminar',
    'common.start': 'Começar',
    'common.resume': 'Retomar',
    'common.minutes': 'min',
    'common.of': 'de',
    'common.today': 'Hoje',
    'common.yesterday': 'Ontem',
    'common.complete': 'Concluir',
    'common.completed': 'Concluído',
    'common.active': 'Ativo',
    'common.inProgress': 'Em curso',
    'common.notStarted': 'Por começar',
    'common.offline': 'Sem ligação. A mostrar o último estado guardado.',

    // --- Principles --------------------------------------------------------
    'principle.purpose': 'Purpose',
    'principle.passion': 'Passion',
    'principle.planning': 'Planning',
    'principle.praxis': 'Praxis',
    'principle.persistence': 'Persistence',
    'principle.progress': 'Progress',
    'principle.perfection': 'Perfection',
    'principle.purpose.desc': 'Saiba porque avança antes de avançar.',
    'principle.passion.desc':
        'Encontre a energia que torna o trabalho sustentável.',
    'principle.planning.desc':
        'Transforme a intenção numa sequência que consegue seguir.',
    'principle.praxis.desc': 'Ponha o plano em prática, hoje, em tamanho real.',
    'principle.persistence.desc':
        'Continue quando a primeira energia se desvanece.',
    'principle.progress.desc':
        'Meça o que se moveu para poder corrigir o rumo.',
    'principle.perfection.desc': 'Refine, feche o ciclo e abra o seguinte.',
    'principle.eyebrow': 'Princípio',

    // --- Welcome -----------------------------------------------------------
    'welcome.taglineLead': 'Ative a sua ',
    'welcome.taglineEnergy': 'Energia',
    'welcome.taglineMid': ' e descubra todo o ',
    'welcome.taglineSuccess': 'sucesso dentro de si',
    'welcome.taglineEnd': '.',
    'welcome.by': 'por',
    'welcome.author': 'Dr. Leadership Tânia Tomé',
    'welcome.official': 'OFICIAL',
    'welcome.cta': 'Comece a sua Jornada interior.',
    'welcome.ctaEmphasis': 'Jornada',
    'welcome.login': 'Já tenho conta',

    // --- Language ----------------------------------------------------------
    'language.eyebrow': 'Idioma',
    'language.title': 'Escolha o seu idioma',
    'language.subtitle':
        'Pode alterar quando quiser nas Definições. O seu coach vai falar o idioma que escolher.',
    'language.english': 'Inglês',
    'language.englishNative': 'English',
    'language.portuguese': 'Português',
    'language.portugueseNative': 'Português',
    'language.confirm': 'Continuar',

    // --- Auth --------------------------------------------------------------
    'auth.login.eyebrow': 'Bem-vindo de volta',
    'auth.login.title': 'Continue o seu ciclo',
    'auth.login.subtitle':
        'Os seus objetivos, o seu plano e o seu coach estão onde os deixou.',
    'auth.login.signingIn': 'A entrar...',
    'auth.login.toRegister': 'Ainda não tem conta? Comece a sua jornada.',
    'auth.login.toRegisterLink': 'Comece a sua jornada.',
    'auth.register.eyebrow': 'Criar conta',
    'auth.register.title': 'Comece o primeiro ciclo',
    'auth.register.subtitle':
        'Sete perguntas e o seu AI Succenergy Coach saberá como trabalhar '
        'consigo.',
    'auth.register.step': 'Passo {current} de {total}',
    'auth.register.step1.title': 'A sua conta',
    'auth.register.step1.subtitle':
        'Um email e uma palavra-passe. Nada é criado antes de ver o que está '
        'a subscrever.',
    'auth.register.step2.title': 'Sobre si',
    'auth.register.step2.subtitle':
        'Quatro respostas com que o seu coach trabalha, e a que define o seu '
        'valor depois do período de teste.',
    'auth.register.step3.title': 'Falta pouco',
    'auth.register.step3.subtitle':
        'Duas confirmações e o seu primeiro ciclo começa.',
    'auth.field.name': 'Nome completo',
    'auth.field.email': 'Email',
    'auth.field.dob': 'Data de nascimento',
    'auth.field.country': 'País',
    'auth.field.activity': 'Atividade',
    'auth.field.password': 'Palavra-passe',
    'auth.field.confirmPassword': 'Confirmar palavra-passe',
    'auth.hint.name': 'O seu nome completo',
    'auth.hint.email': 'taniatome@succenergy.com',
    'auth.hint.newPassword': 'Pelo menos 8 caracteres',
    'auth.activity.student': 'Estudante | Minorias',
    'auth.activity.student.detail':
        'O valor mensal reduzido, para estudantes e minorias.',
    'auth.activity.professional': 'Profissional',
    'auth.activity.professional.detail':
        'O valor mensal normal, para todos os outros.',
    'auth.dob.placeholder': 'Escolha a sua data de nascimento',
    'auth.dob.day': 'Dia',
    'auth.dob.month': 'Mês',
    'auth.dob.year': 'Ano',
    'auth.country.placeholder': 'Escolha o seu país',
    'auth.country.search': 'Procurar países',
    'auth.country.empty': 'Nenhum país corresponde a isso.',
    'auth.consent.terms': 'Aceito os Termos e Condições.',
    'auth.consent.termsLink': 'Termos e Condições',
    'auth.consent.truth':
        'Confirmo que toda a informação que indiquei é verdadeira e exata.',
    'auth.summary.eyebrow': 'O que está a subscrever',
    'auth.summary.trialLabel': 'Os seus primeiros {days} dias',
    'auth.summary.trialValue': '{price}',
    'auth.summary.monthlyLabel': 'Todos os meses seguintes',
    'auth.summary.monthlyValue': '{price}',
    'auth.summary.cancel':
        'Cancele quando quiser antes do fim do período de teste.',
    'auth.action.login': 'Entrar',
    'auth.action.createAccount': 'Criar a minha conta',
    'auth.action.forgot': 'Esqueceu a palavra-passe?',
    'auth.toLogin': 'Já tenho conta',
    'auth.error.nameRequired': 'Diga-nos como o devemos tratar.',
    'auth.error.nameShort': 'Isso parece demasiado curto para ser um nome.',
    'auth.error.emailRequired': 'Introduza o seu email.',
    'auth.error.emailInvalid': 'Isto não parece um endereço de email.',
    'auth.error.emailInUse': 'Esse endereço já tem uma conta.',
    'auth.error.passwordRequired': 'Introduza a sua palavra-passe.',
    'auth.error.passwordWeak':
        'Use pelo menos 8 caracteres, com uma letra e um número.',
    'auth.error.confirmRequired': 'Introduza a palavra-passe outra vez.',
    'auth.error.passwordMatch': 'As duas palavras-passe não coincidem.',
    'auth.error.dobRequired': 'Introduza a sua data de nascimento.',
    'auth.error.dobTooYoung':
        'É preciso ter pelo menos 16 anos para se registar.',
    'auth.error.countryRequired': 'Escolha o seu país.',
    'auth.error.activityRequired': 'Escolha o que o descreve.',
    'auth.error.signInFailed': 'Email ou palavra-passe incorretos.',
    'auth.error.accountDisabled':
        'Esta conta foi desativada. Contacte o suporte.',
    'auth.error.tooManyAttempts':
        'Demasiadas tentativas. Aguarde alguns minutos.',
    'auth.error.network': 'Sem ligação. Verifique a rede e tente novamente.',
    'auth.error.unavailable':
        'A entrada não está disponível nesta versão. Tente mais tarde.',
    'auth.error.generic': 'Algo não correu bem. Tente novamente.',
    'auth.forgot.title': 'Repor a palavra-passe',
    'auth.forgot.subtitle':
        'Introduza o email da sua conta e enviamos um link de reposição.',
    'auth.forgot.action': 'Enviar link',
    'auth.forgot.sentTitle': 'Verifique o seu email',
    'auth.forgot.sentBody':
        'Se existir uma conta para {email}, enviámos um link de reposição.',
    'auth.forgot.spam': 'Veja a pasta de spam se não o encontrar.',
    'auth.forgot.backToLogin': 'Voltar à entrada',
    'auth.biometric.title': 'Entre mais depressa na próxima vez',
    'auth.biometric.bodyFace':
        'Use o Face ID para desbloquear a sua conta sem escrever a '
        'palavra-passe.',
    'auth.biometric.bodyFingerprint':
        'Use a impressão digital para desbloquear a sua conta sem escrever a '
        'palavra-passe.',
    'auth.biometric.bodyGeneric':
        'Use a biometria para desbloquear a sua conta sem escrever a '
        'palavra-passe.',
    'auth.biometric.enable': 'Ativar',
    'auth.biometric.later': 'Talvez mais tarde',
    'auth.biometric.reason': 'Entre na sua conta Succenergy AI Coach',

    // --- Onboarding --------------------------------------------------------
    'onboarding.eyebrow': 'Avaliação',
    'onboarding.progress': 'Pergunta {current} de {total}',
    'onboarding.q1.title': 'O que quer alcançar?',
    'onboarding.q1.help':
        'Escreva como o diria em voz alta. Concreto vale mais do que impressionante.',
    'onboarding.q1.hint': 'Nos próximos seis meses quero...',
    'onboarding.q2.title': 'Que área da sua vida precisa de mais energia?',
    'onboarding.q2.help': 'Escolha até duas.',
    'onboarding.q3.title': 'O que o está a desafiar neste momento?',
    'onboarding.q3.help':
        'Nomeie o obstáculo com honestidade. O seu coach começa aqui.',
    'onboarding.q3.hint': 'O que continua a atrapalhar é...',
    'onboarding.q4.title': 'Quais são as suas prioridades?',
    'onboarding.q4.help': 'Escolha as três que mais contam neste ciclo.',
    'onboarding.q5.title': 'Quais são os seus objetivos principais?',
    'onboarding.q5.help': 'Um ou dois, por palavras suas.',
    'onboarding.q5.hint': 'O meu objetivo principal é...',
    'onboarding.q6.title': 'O que o motiva?',
    'onboarding.q6.help':
        'Deslize para a fonte que mais o puxa num dia difícil.',
    'onboarding.q6.scaleMin': 'Força interior',
    'onboarding.q6.scaleMax': 'Quem levo comigo',
    'onboarding.q7.title': 'Como é o sucesso para si?',
    'onboarding.q7.help':
        'Descreva o dia, não o troféu. O seu coach vai cobrar-lhe isto.',
    'onboarding.q7.hint': 'Vou saber que resultou quando...',
    'onboarding.summary.eyebrow': 'O seu perfil',
    'onboarding.summary.title': 'Foi isto que o seu coach ouviu',
    'onboarding.summary.wants': 'O que quer',
    'onboarding.summary.focus': 'Para onde vai a sua energia',
    'onboarding.summary.challenge': 'O que está no caminho',
    'onboarding.summary.priorities': 'As suas prioridades',
    'onboarding.summary.success': 'Como é o sucesso',
    'onboarding.summary.mainGoals': 'Os seus objetivos principais',
    'onboarding.summary.motivation': 'A sua motivação',
    'onboarding.summary.closing':
        'Começa em Purpose. O seu primeiro ciclo já está esboçado e pode mudar tudo mais tarde.',
    'onboarding.summary.cta': 'Entrar na aplicação',
    'onboarding.option.career': 'Carreira e liderança',
    'onboarding.option.business': 'Negócio e rendimento',
    'onboarding.option.health': 'Saúde e energia',
    'onboarding.option.relationships': 'Relações',
    'onboarding.option.learning': 'Aprendizagem e mestria',
    'onboarding.option.finances': 'Finanças',
    'onboarding.option.purposeArea': 'Propósito e sentido',
    'onboarding.option.confidence': 'Confiança na sala',
    'onboarding.option.focus': 'Foco profundo',
    'onboarding.option.discipline': 'Disciplina diária',
    'onboarding.option.visibility': 'Visibilidade e voz',
    'onboarding.option.balance': 'Equilíbrio e recuperação',
    'onboarding.option.income': 'Crescer o rendimento',
    'onboarding.option.team': 'Construir uma equipa',
    'onboarding.option.procrastination': 'Parar de procrastinar',
    'onboarding.option.stress': 'Eliminar o stress',
    'onboarding.option.balancedLife': 'Vida equilibrada',

    // --- Entry quiz --------------------------------------------------------
    'quiz.cta': 'Criar a sua conta',

    // --- Trial -------------------------------------------------------------
    'trial.eyebrow': 'Antes de começar',
    'trial.title': 'Sete dias, um dólar',
    'trial.subtitle':
        'A aplicação é gratuita. O coach, os seus objetivos e a sua evolução '
        'abrem no momento em que o teste começa.',
    'trial.after.label': 'Depois do teste',
    'trial.after.value': '{price} por mês',
    'trial.after.student':
        'A mensalidade Estudante | Minorias, conforme escolheu no registo.',
    'trial.after.professional':
        'A mensalidade Profissional, conforme escolheu no registo.',
    'trial.unlock.title': 'O que o teste abre',
    'trial.unlock.coach': 'O Coach de IA, sem limite de mensagens',
    'trial.unlock.exercises': 'Os exercícios de Purpose, para abrir o ciclo',
    'trial.unlock.goals': 'Objetivos, ações e marcos',
    'trial.unlock.progress': 'Toda a sua evolução e o histórico de ciclos',
    'trial.unlock.library': 'Recarregue com a Succenergy e a biblioteca',
    'trial.cta': 'Começar o teste de 7 dias',
    'trial.billing.student':
        'Depois do teste, a mensalidade Estudantes & Minorias de {price} por '
        'mês será cobrada automaticamente; pode cancelar quando quiser antes '
        'da data da próxima cobrança, embora o encorajemos a experimentar o '
        'AI Succenergy Coach durante um mês e a ver como funciona para si.',
    'trial.billing.professional':
        'Depois do teste, a mensalidade Profissional de {price} por mês será '
        'cobrada automaticamente; pode cancelar quando quiser antes da data '
        'da próxima cobrança, embora o encorajemos a experimentar o AI '
        'Succenergy Coach durante um mês e a ver como funciona para si.',
    'trialWelcome.eyebrow': 'Bem-vindo',
    'trialWelcome.message':
        'Parabéns, está no caminho para se tornar um vencedor '
        'Succenergy.',

    // --- Recharge ----------------------------------------------------------
    'recharge.title': 'Recarregue com a Succenergy',
    'recharge.eyebrow': 'Em breve',
    'recharge.body':
        'Uma pausa curta para fazer entre ciclos, sobre os mesmos sete '
        'princípios. Está a ser preparada e vai abrir aqui.',

    // --- Dashboard ---------------------------------------------------------
    'dashboard.greeting.morning': 'Bom dia, {name}',
    'dashboard.greeting.afternoon': 'Boa tarde, {name}',
    'dashboard.greeting.evening': 'Boa noite, {name}',
    'dashboard.greeting.sub': 'Dia {day} do seu ciclo',
    'dashboard.cycle.eyebrow': 'O seu ciclo',
    'dashboard.cycle.active': 'Está em {principle}',
    'dashboard.action.eyebrow': 'Hoje',
    'dashboard.action.title': 'A sua única ação',
    'dashboard.action.markDone': 'Marcar como feita',
    'dashboard.action.doneToday': 'Feito por hoje',
    'dashboard.goal.eyebrow': 'Objetivo ativo',
    'dashboard.goal.next': 'Próximo marco',
    'dashboard.coach.eyebrow': 'AI COACH',
    'dashboard.coach.title': 'Fale sobre isso',
    'dashboard.coach.body':
        'O seu coach leu esta semana. Pergunte-lhe o que fazer com {goal}.',
    'dashboard.coach.cta': 'Abrir coach',
    'dashboard.stats.dayStreak': 'DIAS SEGUIDOS',
    'dashboard.stats.goalsActive': 'OBJETIVOS',
    'dashboard.stats.exercises': 'EXERCÍCIOS',
    'dashboard.quick.goals': 'Objetivos',
    'dashboard.quick.exercises': 'Exercícios',
    'dashboard.quick.purpose': 'Purpose',
    'dashboard.quick.progress': 'Evolução',

    // --- Navigation --------------------------------------------------------
    'nav.home': 'INÍCIO',
    'nav.goals': 'OBJETIVOS',
    'nav.coach': 'COACH',
    'nav.exercises': 'PRÁTICA',
    'nav.progress': 'EVOLUÇÃO',

    // --- Purpose -----------------------------------------------------------
    'purpose.eyebrow': 'Primeiro princípio',
    'purpose.title': 'Purpose',
    'purpose.intro':
        'O propósito não é uma frase que se encontra uma vez. É a resposta que se vai afiando. Trabalhe estes cinco temas e volte a eles sempre que o ciclo virar.',
    'purpose.prompt.talents': 'Os seus talentos',
    'purpose.prompt.talents.q':
        'O que lhe sai com facilidade e que os outros acham difícil?',
    'purpose.prompt.strengths': 'As suas forças',
    'purpose.prompt.strengths.q':
        'Quando fez o seu melhor trabalho, o que estava a fazer?',
    'purpose.prompt.values': 'Os seus valores',
    'purpose.prompt.values.q':
        'O que se recusaria a trocar, mesmo por um resultado que deseja?',
    'purpose.prompt.direction': 'A sua direção',
    'purpose.prompt.direction.q':
        'Se nada mudasse durante três anos, do que se arrependeria?',
    'purpose.prompt.aspirations': 'As suas aspirações',
    'purpose.prompt.aspirations.q': 'A quem quer ser útil, e como?',
    'purpose.answered': 'Respondido',
    'purpose.unanswered': 'Ainda sem resposta',
    'purpose.saveAnswer': 'Guardar resposta',
    'purpose.statement.eyebrow': 'Declaração de propósito',
    'purpose.statement.title': 'Para onde isto aponta',

    // --- Goals -------------------------------------------------------------
    'goals.title': 'Objetivos',
    'goals.tab.active': 'Ativos',
    'goals.tab.completed': 'Concluídos',
    'goals.card.next': 'Seguinte',
    'goals.card.due': 'Meta',
    'goals.empty.title':
        'O seu primeiro objetivo está a uma frase de distância',
    'goals.empty.body':
        'Diga o que quer, escolha o princípio a que pertence, e o seu coach constrói o plano à volta disso.',
    'goals.empty.cta': 'Criar objetivo',
    'goals.emptyCompleted.title': 'Ainda nada fechado',
    'goals.emptyCompleted.body':
        'Os objetivos terminados juntam-se aqui com a data em que os fechou.',
    'goals.create.title': 'Novo objetivo',
    'goals.create.name': 'O que quer alcançar?',
    'goals.create.nameHint': 'Diga-o como o diria em voz alta',
    'goals.create.why': 'Porque é que importa?',
    'goals.create.whyHint': 'A razão a que vai voltar numa semana difícil',
    'goals.create.principle': 'Que princípio o lidera?',
    'goals.create.submit': 'Criar objetivo',
    'goals.detail.why': 'Porque importa',
    'goals.detail.milestones': 'Marcos',
    'goals.detail.actions': 'Ações',
    'goals.detail.discuss': 'Falar com o Coach',
    'goals.detail.progress': 'Evolução',
    'goals.detail.targetDate': 'Data alvo',
    'goals.detail.completedOn': 'Fechado a',
    'goals.detail.actionsDone': '{done} de {total} feitas',
    'goals.edit.title': 'Editar objetivo',
    'goals.edit.submit': 'Guardar objetivo',
    'goals.menu.tooltip': 'Opções do objetivo',
    'goals.delete.title': 'Eliminar este objetivo?',
    'goals.delete.body':
        'Os marcos e o plano de ação vão com ele, e o coach deixa de trabalhar a partir dele. Não pode ser desfeito.',
    'goals.delete.confirm': 'Eliminar objetivo',
    'goals.delete.done': 'Objetivo eliminado',
    'goals.detail.markComplete': 'Marcar como concluído',
    'goals.detail.reopen': 'Reabrir este objetivo',

    // --- Exercises ---------------------------------------------------------
    'exercises.title': 'Prática',
    'exercises.subtitle':
        'Trabalho guiado e curto, organizado pelo princípio que serve.',
    'exercises.all': 'Todos',
    'exercises.card.duration': '{minutes} min',
    'exercises.card.completed': 'Concluído',
    'exercises.card.start': 'Começar',
    'exercises.card.review': 'Rever',
    'exercises.locked.badge': 'Bloqueado',
    'exercises.locked.card': 'Abrir com uma subscrição',
    'exercises.locked.note':
        'O seu teste abre o Purpose. Uma subscrição abre os outros seis '
        'princípios.',
    'exercises.empty.title': 'Ainda não há nada para este princípio',
    'exercises.empty.body':
        'Escolha outro princípio acima, ou comece por Purpose para abrir o ciclo.',
    'exercises.session.step': 'Passo {current} de {total}',
    'exercises.session.reflection': 'Reflexão final',
    'exercises.session.reflectionHint': 'O que mudou enquanto fazia isto?',
    'exercises.session.answerHint': 'Escreva por palavras suas',
    'exercises.session.exit': 'Sair do exercício',
    'exercises.session.exitBody':
        'As respostas até agora não serão guardadas. Sair mesmo assim?',
    'exercises.done.eyebrow': 'Concluído',
    'exercises.done.title': 'Trabalho feito',
    'exercises.done.suggested': 'Próxima ação sugerida',
    'exercises.done.addToGoal': 'Adicionar a {goal}',
    'exercises.done.added': 'Adicionado ao seu plano de ação',
    'exercises.done.finish': 'Voltar à prática',
    'exercises.scaleLow': 'Nada',
    'exercises.scaleHigh': 'Totalmente',

    // --- AI Coach ----------------------------------------------------------
    'coach.title': 'AI COACH',
    'coach.subtitle': 'Construído sobre a metodologia Succenergy',
    'coach.inputHint': 'Diga o que se passa mesmo',
    'coach.send': 'Enviar',
    'coach.thinking': 'A pensar',
    'coach.suggested.eyebrow': 'Experimente perguntar',
    'coach.suggestion.stuck': 'Estou encravado esta semana',
    'coach.suggestion.plan': 'Divida o meu próximo marco',
    'coach.suggestion.energy': 'A minha energia está em baixo',
    'coach.suggestion.review': 'Reveja o meu ciclo até agora',
    'coach.history': 'Histórico',
    'coach.newSession': 'Nova sessão',

    // --- Coaching history --------------------------------------------------
    'history.title': 'Histórico de coaching',
    'history.subtitle': 'Todas as sessões, com o que saiu de cada uma.',
    'history.duration': '{minutes} min',
    'history.messages': '{count} mensagens',
    'history.transcript': 'Transcrição',
    'history.speaker.you': 'VOCÊ',
    'history.empty.title': 'Ainda sem sessões',
    'history.empty.body':
        'Quando falar com o seu coach, cada conversa fica resumida aqui.',

    // --- Progress ----------------------------------------------------------
    'progress.title': 'Evolução',
    'progress.subtitle': 'Três semanas de provas.',
    'progress.chart.completion': 'Evolução dos objetivos',
    'progress.chart.byPrinciple': 'Prática por princípio',
    'progress.chart.activity': 'Atividade',
    'progress.cycle.eyebrow': 'Metodologia',
    'progress.cycle.title': 'Onde está no ciclo',
    'progress.milestones.title': 'Marcos alcançados',
    'progress.stat.completionRate': 'TAXA',
    'progress.stat.streak': 'SEQUÊNCIA',
    'progress.stat.sessions': 'SESSÕES',
    'progress.stat.actions': 'AÇÕES',
    'progress.weekLabel': 'Semana {number}',

    // --- Notifications -----------------------------------------------------
    'notifications.title': 'Notificações',
    'notifications.tab.inbox': 'Caixa',
    'notifications.tab.preferences': 'Preferências',
    'notifications.markAllRead': 'Marcar tudo como lido',
    'notifications.empty.title': 'Nada à espera',
    'notifications.empty.body':
        'Lembretes, princípios do dia e avisos de prática chegam aqui.',
    'notifications.pref.goalNudges': 'Lembretes de objetivos',
    'notifications.pref.goalNudges.desc':
        'Um aviso quando uma ação fica aberta tempo demais.',
    'notifications.pref.principleOfDay': 'Princípio do dia',
    'notifications.pref.principleOfDay.desc':
        'Uma ideia por manhã, do princípio em que está.',
    'notifications.pref.reengagement': 'Regresso',
    'notifications.pref.reengagement.desc':
        'Uma nota se estiver ausente há mais de três dias.',
    'notifications.pref.exerciseReminders': 'Lembretes de exercícios',
    'notifications.pref.exerciseReminders.desc':
        'Um lembrete da prática que agendou e ainda não começou.',
    'notifications.pref.quietHours': 'Horas de silêncio',
    'notifications.pref.quietHours.desc':
        'Nada chega entre as 21:00 e as 07:00.',

    // --- Subscription ------------------------------------------------------
    'subscription.title': 'Planos',
    'subscription.subtitle':
        'Um teste e, depois, a mensalidade que corresponde ao que faz.',
    'subscription.plan.trial': 'Teste de 7 dias',
    'subscription.plan.student': 'Estudante | Minorias',
    'subscription.plan.professional': 'Profissional',
    'subscription.perMonth': 'por mês',
    'subscription.perTrial': 'durante 7 dias',
    'subscription.recommended': 'O SEU PLANO',
    'subscription.current': 'O seu plano',
    'subscription.cta.choose': 'Escolher este plano',
    'subscription.cta.current': 'Plano atual',
    'subscription.compare.trial': 'O que a subscrição abre',
    'subscription.compare.included': 'Incluído no seu plano',
    'subscription.premiumColumn': 'Incluído',
    'subscription.lockedColumn': 'Bloqueado',
    'subscription.feature.coaching': 'Coaching por IA',
    'subscription.feature.coaching.premium': 'Sem limite',
    'subscription.feature.memory': 'Memória do coach',
    'subscription.feature.memory.premium': 'Histórico completo',
    'subscription.feature.exercises': 'Biblioteca de exercícios',
    'subscription.feature.exercises.trial': 'Apenas o Purpose',
    'subscription.feature.exercises.premium': 'Os sete princípios',
    'subscription.feature.goals': 'Objetivos ativos',
    'subscription.feature.goals.premium': 'Sem limite',
    'subscription.feature.personalisation': 'Personalização',
    'subscription.feature.personalisation.premium': 'Adaptada ao seu perfil',
    'subscription.feature.progress': 'Relatórios de evolução',
    'subscription.feature.progress.premium': 'Análise completa',
    'subscription.note':
        'Os planos são apresentados para revisão. O pagamento não está ativo nesta versão.',

    // --- Profile -----------------------------------------------------------
    'profile.title': 'Perfil',
    'profile.section.account': 'Conta',
    'profile.section.coaching': 'O seu perfil de coaching',
    'profile.section.preferences': 'Preferências de coaching',
    'profile.field.name': 'Nome',
    'profile.field.email': 'Email',
    'profile.field.language': 'Idioma',
    'profile.pref.tone': 'Tom do coach',
    'profile.pref.tone.direct': 'Direto',
    'profile.pref.tone.warm': 'Caloroso',
    'profile.pref.tone.challenging': 'Desafiante',
    'profile.pref.checkIn': 'Ritmo de contacto',
    'profile.pref.checkIn.daily': 'Diário',
    'profile.pref.checkIn.everyOther': 'Dia sim, dia não',
    'profile.pref.checkIn.weekly': 'Semanal',
    'profile.pref.reminders': 'Lembretes de prática',
    'profile.memberSince': 'Com a Succenergy desde {date}',
    'profile.saved': 'Perfil atualizado',

    // --- Settings ----------------------------------------------------------
    'settings.title': 'Definições',
    'settings.section.general': 'Geral',
    'settings.section.account': 'Conta',
    'settings.section.security': 'Segurança',
    'settings.section.subscription': 'Subscrição',
    'settings.section.about': 'Sobre',
    'settings.item.language': 'Idioma',
    'settings.item.notifications': 'Notificações',
    'settings.item.profile': 'Perfil',
    'settings.item.changePassword': 'Alterar palavra-passe',
    'settings.item.biometric': 'Desbloquear com biometria',
    'settings.biometric.on': 'Ativo',
    'settings.biometric.atSignIn': 'Oferecido ao entrar',
    'settings.biometric.disable':
        'As credenciais guardadas serão removidas deste dispositivo. Pode '
        'voltar a ativar na próxima vez que entrar.',
    'settings.biometric.turnOff': 'Desativar',
    'settings.item.plan': 'O seu plano',
    'settings.item.managePlan': 'Gerir plano',
    'settings.section.succenergy': 'Succenergy',
    'settings.item.recharge': 'Recarregue com a Succenergy',
    'settings.item.library': 'Biblioteca Succenergy',
    'settings.item.booking': 'Marcar com a Tânia Tomé',
    'settings.item.connect': 'Ligue-se a nós',
    'settings.connect.instagram': 'Instagram',
    'settings.connect.facebook': 'Facebook',
    'settings.connect.linkedin': 'LinkedIn',
    'settings.connect.youtube': 'YouTube',
    'settings.external': 'Abre no seu navegador',
    'settings.item.help': 'Ajuda e sobre',
    'settings.item.terms': 'Termos e condições',
    'settings.item.privacy': 'Política de privacidade',
    'settings.item.admin': 'Consola de gestão',
    'settings.item.logout': 'Terminar sessão',
    'settings.item.deleteAccount': 'Eliminar conta',
    'settings.logout.title': 'Terminar sessão',
    'settings.logout.body': 'Pode voltar a entrar quando quiser.',
    'settings.delete.title': 'Eliminar a sua conta',
    'settings.delete.body':
        'Isto remove os seus objetivos, o seu histórico de prática e tudo o que o seu coach sabe sobre si. Não pode ser desfeito.',
    'settings.delete.confirm': 'Eliminar definitivamente',

    // --- Help and about ----------------------------------------------------
    'help.title': 'Ajuda e sobre',
    'help.about.eyebrow': 'Sobre',
    'help.about.body':
        'O Succenergy AI Coach aplica a metodologia Succenergy desenvolvida pela Dr. Leadership Tânia Tomé. O coach assenta no método dela. Não é ela, e dirá isso mesmo se perguntar.',
    'help.about.attribution':
        'Succenergy é uma metodologia registada da Dr. Leadership Tânia Tomé.',
    'help.version': 'Versão {version}',
    'help.faq.eyebrow': 'Perguntas',
    'help.faq.q1': 'Quais são os Sete Princípios?',
    'help.faq.a1':
        'Purpose, Passion, Planning, Praxis, Persistence, Progress e Perfection. São um ciclo, não uma escada. Passa pelos sete, fecha a volta, e recomeça em terreno mais firme.',
    'help.faq.q2': 'O coach é mesmo a Tânia Tomé?',
    'help.faq.a2':
        'Não. O coach é uma IA construída sobre a metodologia dela, treinada para trabalhar como o método trabalha. Tudo o que diz decorre dos Sete Princípios.',
    'help.faq.q3': 'De quanto é que o coach se lembra?',
    'help.faq.a3':
        'Num plano Premium guarda o seu histórico completo: as respostas da avaliação, todos os objetivos e o que já disse antes. No plano gratuito trabalha apenas com a sessão atual.',
    'help.faq.q4': 'Posso mudar de idioma mais tarde?',
    'help.faq.a4':
        'Sim. Definições, depois Idioma. Toda a aplicação e o seu coach mudam de imediato.',
    'help.faq.q5': 'O que acontece quando termino um ciclo?',
    'help.faq.a5':
        'Fecha-o em Perfection, e o seu coach abre um novo Purpose levando consigo o que aprendeu.',
    'help.contact.eyebrow': 'Contacto',
    'help.contact.email': 'Apoio por email',
    'help.contact.emailValue': 'support@succenergy.com',
    'help.legal.terms': 'Termos de utilização',
    'help.legal.privacy': 'Política de privacidade',

    // --- Admin -------------------------------------------------------------
    'admin.gate.eyebrow': 'Restrito',
    'admin.gate.title': 'Consola de gestão',
    'admin.gate.body': 'Introduza o código de acesso emitido para a sua conta.',
    'admin.gate.field': 'Código de acesso',
    'admin.gate.action': 'Desbloquear',
    'admin.gate.error': 'Esse código não foi reconhecido.',
    'admin.title': 'Gestão',
    'admin.tab.users': 'Utilizadores',
    'admin.tab.content': 'Conteúdo',
    'admin.tab.notify': 'Notificar',
    'admin.stat.users': 'UTILIZADORES',
    'admin.stat.active': 'ATIVOS 7D',
    'admin.stat.premium': 'PREMIUM',
    'admin.stat.sessions': 'SESSÕES 7D',
    'admin.users.search': 'Pesquisar utilizadores',
    'admin.users.plan': 'Plano',
    'admin.users.planTrial': 'Teste',
    'admin.users.planStudent': 'Estudante',
    'admin.users.planProfessional': 'Profissional',
    'admin.users.lastSeen': 'Visto',
    'admin.content.exercises': 'Biblioteca de exercícios',
    'admin.content.published': 'Publicado',
    'admin.content.draft': 'Rascunho',
    'admin.notify.title': 'Compor notificação',
    'admin.notify.audience': 'Público',
    'admin.notify.audience.all': 'Todos',
    'admin.notify.audience.free': 'Plano gratuito',
    'admin.notify.audience.premium': 'Premium',
    'admin.notify.heading': 'Título',
    'admin.notify.body': 'Mensagem',
    'admin.notify.send': 'Colocar em fila',
    'admin.notify.queued': 'Em fila para {audience}',
  };
}
