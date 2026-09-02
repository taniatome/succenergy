/**
 * Seeds the mock persona into the Firestore emulator.
 *
 *   npm run emulators     # in another terminal
 *   npm run seed
 *   npm run token         # signs in as the seeded persona
 *
 * The persona is Marisa Chissano, taken from lib/data/mock/mock_data.dart so
 * the seeded account reads as the same person the Flutter build demonstrates:
 * three weeks in, mid-cycle on Praxis, running a brand relaunch.
 *
 * Emulator only. The script refuses to run without both emulator hosts set,
 * because seeding a real project would write fabricated data into a live
 * account.
 *
 * The account is keyed to TEST_USER_EMAIL, so `npm run token` returns a token
 * for the uid seeded here and /v1/me returns the persona rather than an empty
 * profile.
 */

import { config as loadDotenv } from 'dotenv';

loadDotenv();

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    [
      '',
      'Refusing to seed: FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST',
      'must both be set. This script writes fabricated data and must never',
      'touch a real project.',
      '',
      'Start the emulators with `npm run emulators`, then use `npm run seed`,',
      'which sets both.',
      '',
    ].join('\n'),
  );
  process.exit(1);
}

const { Timestamp } = await import('firebase-admin/firestore');
const { auth, firestore } = await import('../src/config/firebase.js');
const { INITIAL_SUBSCRIPTION, TRIAL_DAYS } = await import(
  '../src/models/subscription.model.js'
);

const rawEmail = process.env.TEST_USER_EMAIL;
const rawPassword = process.env.TEST_USER_PASSWORD;

if (!rawEmail || !rawPassword) {
  console.error('\nTEST_USER_EMAIL and TEST_USER_PASSWORD must be set in .env.\n');
  process.exit(1);
}

// Re-declared as plain strings: narrowing from the check above does not reach
// inside the function bodies below, and both are read from them.
const email: string = rawEmail;
const password: string = rawPassword;

// --- Dates, relative to today so the persona never looks stale -------------

const startOfToday = new Date();
startOfToday.setHours(0, 0, 0, 0);

const daysAgo = (days: number): typeof Timestamp.prototype =>
  Timestamp.fromDate(new Date(startOfToday.getTime() - days * 86_400_000));

const daysAhead = (days: number): typeof Timestamp.prototype =>
  Timestamp.fromDate(new Date(startOfToday.getTime() + days * 86_400_000));

const hoursAgo = (hours: number): typeof Timestamp.prototype =>
  Timestamp.fromDate(new Date(Date.now() - hours * 3_600_000));

/**
 * Finds or creates the persona's Auth account.
 *
 * Reuses an existing account rather than recreating it, so the uid is stable
 * across runs and a re-seed refreshes data under the same account instead of
 * stranding the previous one.
 */
async function resolveUid(): Promise<{ uid: string; created: boolean }> {
  try {
    const existing = await auth.getUserByEmail(email);
    return { uid: existing.uid, created: false };
  } catch {
    const created = await auth.createUser({
      email,
      password,
      displayName: 'Marisa Chissano',
      emailVerified: true,
    });
    return { uid: created.uid, created: true };
  }
}

async function seed(): Promise<void> {
  const { uid, created } = await resolveUid();
  const userRef = firestore.collection('users').doc(uid);

  // A re-seed must not merge into whatever a previous run left behind, or a
  // removed goal would linger. The cascade in the repository is the same walk.
  const existingCollections = await userRef.listCollections();
  for (const collection of existingCollections) {
    const docs = await collection.listDocuments();
    for (const doc of docs) {
      for (const child of await doc.listCollections()) {
        const grandchildren = await child.listDocuments();
        await Promise.all(grandchildren.map((ref) => ref.delete()));
      }
      await doc.delete();
    }
  }

  const batch = firestore.batch();

  // --- The person ----------------------------------------------------------

  batch.set(userRef, {
    name: 'Marisa Chissano',
    email,
    preferredLanguage: 'en',
    activity: 'professional',
    dateOfBirth: Timestamp.fromDate(new Date(Date.UTC(1991, 3, 17))),
    countryCode: 'MZ',
    acceptedTerms: true,
    confirmedInfoTrue: true,
    currentPrinciple: 'praxis',
    cycleDay: 19,
    dayStreak: 12,
    coachingPreferences: {
      tone: 'direct',
      rhythm: 'daily',
      remindersEnabled: true,
    },
    createdAt: daysAgo(21),
    updatedAt: hoursAgo(3),
  });

  // --- Onboarding ----------------------------------------------------------

  batch.set(userRef.collection('onboarding').doc('response'), {
    ambition: {
      en: 'Run the Q4 relaunch myself, well enough that nobody has to check my work, and be given a team after it.',
      pt: 'Conduzir eu própria o relançamento do Q4, bem o suficiente para ninguém ter de rever o meu trabalho, e receber uma equipa depois disso.',
    },
    focusAreaKeys: ['onboarding.option.career', 'onboarding.option.confidence'],
    challenge: {
      en: 'I plan carefully and then hesitate before showing anything. The delay looks like thoroughness. It is not.',
      pt: 'Planeio com cuidado e depois hesito antes de mostrar seja o que for. O atraso parece rigor. Não é.',
    },
    priorityKeys: [
      'onboarding.option.visibility',
      'onboarding.option.focus',
      'onboarding.option.team',
    ],
    mainGoals: {
      en: 'Lead the relaunch end to end. Speak at the Leadership Forum in November. Stop losing my mornings.',
      pt: 'Liderar o relançamento do início ao fim. Falar no Fórum de Liderança em novembro. Parar de perder as minhas manhãs.',
    },
    motivationBalance: 0.35,
    successVision: {
      en: 'A Tuesday where the hard work happens before ten, the relaunch is on track without me holding it together, and I said the thing in the room instead of writing it down afterwards.',
      pt: 'Uma terça-feira em que o trabalho difícil acontece antes das dez, o relançamento avança sem eu ter de o segurar, e em que disse a coisa na sala em vez de a escrever depois.',
    },
    completedAt: daysAgo(20),
    updatedAt: daysAgo(20),
  });

  // --- Goals ---------------------------------------------------------------

  batch.set(userRef.collection('goals').doc('goal-relaunch'), {
    title: {
      en: 'Lead the Q4 brand relaunch end to end',
      pt: 'Liderar o relançamento da marca no Q4 do início ao fim',
    },
    why: {
      en: 'If I run this one well, the leadership conversation stops being hypothetical.',
      pt: 'Se eu conduzir bem este, a conversa sobre liderança deixa de ser hipotética.',
    },
    principle: 'praxis',
    targetDate: daysAhead(34),
    milestones: [
      {
        id: 'ms-relaunch-1',
        title: {
          en: 'Positioning brief signed off',
          pt: 'Briefing de posicionamento aprovado',
        },
        dueDate: daysAgo(16),
        reachedAt: daysAgo(15),
      },
      {
        id: 'ms-relaunch-2',
        title: {
          en: 'Creative route chosen with the agency',
          pt: 'Rota criativa escolhida com a agência',
        },
        dueDate: daysAgo(9),
        reachedAt: daysAgo(8),
      },
      {
        id: 'ms-relaunch-3',
        title: { en: 'Budget approved by finance', pt: 'Orçamento aprovado pelas finanças' },
        dueDate: daysAgo(3),
        reachedAt: daysAgo(2),
      },
      {
        id: 'ms-relaunch-4',
        title: {
          en: 'Internal preview delivered to the leadership team',
          pt: 'Apresentação interna feita à equipa de liderança',
        },
        dueDate: daysAhead(12),
        reachedAt: null,
      },
    ],
    actions: [
      {
        id: 'act-relaunch-1',
        goalId: 'goal-relaunch',
        title: {
          en: 'Send the revised launch timeline to Aleixo for sign-off',
          pt: 'Enviar o cronograma revisto ao Aleixo para aprovação',
        },
        isDone: false,
        isToday: true,
      },
      {
        id: 'act-relaunch-2',
        goalId: 'goal-relaunch',
        title: {
          en: 'Write the one-page story the sales team can repeat',
          pt: 'Escrever a página única que a equipa de vendas consegue repetir',
        },
        isDone: true,
        isToday: false,
      },
      {
        id: 'act-relaunch-3',
        goalId: 'goal-relaunch',
        title: {
          en: 'Cut the preview deck from twenty-two slides to nine',
          pt: 'Cortar a apresentação de vinte e dois para nove slides',
        },
        isDone: true,
        isToday: false,
      },
    ],
    completedAt: null,
    createdAt: daysAgo(19),
    updatedAt: daysAgo(2),
  });

  batch.set(userRef.collection('goals').doc('goal-forum'), {
    title: {
      en: 'Speak at the November Leadership Forum',
      pt: 'Falar no Fórum de Liderança de novembro',
    },
    why: {
      en: 'Saying it in a room is the part I keep avoiding.',
      pt: 'Dizê-lo numa sala é a parte que continuo a evitar.',
    },
    principle: 'passion',
    targetDate: daysAhead(61),
    milestones: [
      {
        id: 'ms-forum-1',
        title: { en: 'Abstract submitted', pt: 'Resumo submetido' },
        dueDate: daysAgo(5),
        reachedAt: daysAgo(6),
      },
      {
        id: 'ms-forum-2',
        title: { en: 'Talk outlined', pt: 'Palestra estruturada' },
        dueDate: daysAhead(20),
        reachedAt: null,
      },
    ],
    actions: [
      {
        id: 'act-forum-1',
        goalId: 'goal-forum',
        title: {
          en: 'Draft the opening ninety seconds and read it aloud once',
          pt: 'Escrever os primeiros noventa segundos e lê-los em voz alta uma vez',
        },
        isDone: false,
        isToday: false,
      },
    ],
    completedAt: null,
    createdAt: daysAgo(14),
    updatedAt: daysAgo(5),
  });

  // --- Exercise responses --------------------------------------------------

  batch.set(userRef.collection('exerciseResponses').doc('resp-sentence-test'), {
    exerciseId: 'ex-sentence-test',
    principle: 'purpose',
    stepResponses: {
      'st-1': 'I make complicated work understandable so that other people can act on it.',
      'st-2': 'Mine',
      'st-3': 'I name the thing a room is circling around, and then I make it possible to do.',
    },
    reflection: 'The second version is the one I would actually say out loud.',
    suggestedAction: {
      en: 'Say your sentence out loud to one person this week',
      pt: 'Diga a sua frase em voz alta a uma pessoa esta semana',
    },
    completedAt: daysAgo(16),
  });

  // --- Sessions, with messages in a subcollection --------------------------

  const sessionRef = userRef.collection('sessions').doc('ses-1');
  batch.set(sessionRef, {
    startedAt: daysAgo(5),
    endedAt: Timestamp.fromMillis(daysAgo(5).toMillis() + 18 * 60_000),
    summary: {
      en: 'Where the relaunch actually stands, once the optimism was removed.',
      pt: 'Onde o relançamento está mesmo, depois de retirado o otimismo.',
    },
    principle: 'praxis',
    messageCount: 4,
  });

  const messages = [
    {
      id: 'ses1-m1',
      author: 'coach',
      text: {
        en: 'Give me the relaunch status as you would give it to someone who cannot help you.',
        pt: 'Dê-me o estado do relançamento como o daria a alguém que não a pode ajudar.',
      },
    },
    {
      id: 'ses1-m2',
      author: 'user',
      text: {
        en: 'Positioning done, creative route chosen, budget still with finance.',
        pt: 'Posicionamento feito, rota criativa escolhida, orçamento ainda nas finanças.',
      },
    },
    {
      id: 'ses1-m3',
      author: 'coach',
      text: {
        en: 'Two of those are yours and one is not. Which of the two have you stopped moving while you wait for finance?',
        pt: 'Dois desses são seus e um não é. Qual dos dois deixou de mover enquanto espera pelas finanças?',
      },
    },
    {
      id: 'ses1-m4',
      author: 'user',
      text: {
        en: 'The preview deck. I have been calling it blocked when it is not.',
        pt: 'A apresentação. Tenho-lhe chamado bloqueada quando não está.',
      },
    },
  ];

  messages.forEach((message, index) => {
    batch.set(sessionRef.collection('messages').doc(message.id), {
      author: message.author,
      text: message.text,
      sentAt: Timestamp.fromMillis(daysAgo(5).toMillis() + index * 90_000),
    });
  });

  const secondSessionRef = userRef.collection('sessions').doc('ses-2');
  batch.set(secondSessionRef, {
    startedAt: daysAgo(2),
    endedAt: Timestamp.fromMillis(daysAgo(2).toMillis() + 11 * 60_000),
    summary: {
      en: 'What the hesitation before showing work is actually protecting.',
      pt: 'O que a hesitação antes de mostrar trabalho está mesmo a proteger.',
    },
    principle: 'praxis',
    messageCount: 2,
  });

  batch.set(secondSessionRef.collection('messages').doc('ses2-m1'), {
    author: 'coach',
    text: {
      en: 'You said the delay looks like thoroughness. What does it cost?',
      pt: 'Disse que o atraso parece rigor. Quanto custa?',
    },
    sentAt: daysAgo(2),
  });

  batch.set(secondSessionRef.collection('messages').doc('ses2-m2'), {
    author: 'user',
    text: {
      en: 'Two days per decision, and the decision is rarely different.',
      pt: 'Dois dias por decisão, e a decisão raramente é diferente.',
    },
    sentAt: Timestamp.fromMillis(daysAgo(2).toMillis() + 120_000),
  });

  // --- Notifications -------------------------------------------------------

  batch.set(userRef.collection('notifications').doc('not-1'), {
    type: 'goal_nudge',
    title: { en: 'The timeline is still unsent', pt: 'O cronograma continua por enviar' },
    body: {
      en: 'Sending it to Aleixo has been today’s action for two days. Praxis is contact, not readiness.',
      pt: 'Enviá-lo ao Aleixo é a ação do dia há dois dias. Praxis é contacto, não prontidão.',
    },
    receivedAt: hoursAgo(5),
    isRead: false,
  });

  batch.set(userRef.collection('notifications').doc('not-2'), {
    type: 'principle_of_day',
    title: { en: 'Praxis', pt: 'Praxis' },
    body: {
      en: 'A plan that has not met reality is still a draft. Show one unfinished thing to one person today.',
      pt: 'Um plano que não encontrou a realidade ainda é um rascunho. Mostre hoje uma coisa por acabar a uma pessoa.',
    },
    receivedAt: hoursAgo(9),
    isRead: true,
  });

  // --- Subscription --------------------------------------------------------

  batch.set(userRef.collection('subscription').doc('current'), {
    ...INITIAL_SUBSCRIPTION,
    tier: 'professional',
    status: 'active',
    trialStartedAt: daysAgo(21),
    trialEndsAt: daysAgo(21 - TRIAL_DAYS),
    currentPeriodEnd: daysAhead(9),
    provider: 'stripe',
    providerCustomerId: 'seed-customer-not-a-real-id',
    updatedAt: daysAgo(14),
  });

  // --- Progress snapshots, keyed by calendar date --------------------------

  for (let offset = 20; offset >= 0; offset -= 1) {
    const day = daysAgo(offset);
    const key = day.toDate().toISOString().slice(0, 10);
    const active = offset % 7 !== 3;

    batch.set(userRef.collection('progressSnapshots').doc(key), {
      date: day,
      goalCompletion: Math.min(1, 0.25 + (20 - offset) * 0.03),
      actionsCompleted: active ? ((offset % 3) + 1) : 0,
      exercisesCompleted: offset % 5 === 0 ? 1 : 0,
    });
  }

  // --- Purpose answers -----------------------------------------------------

  batch.set(userRef.collection('purposeAnswers').doc('talents'), {
    answer: {
      en: 'I can hear what a group is circling around and say it in one sentence. People relax when the thing is finally named.',
      pt: 'Consigo ouvir aquilo à volta do que um grupo anda a girar e dizê-lo numa frase. As pessoas descontraem quando a coisa é finalmente nomeada.',
    },
    updatedAt: daysAgo(11),
  });

  batch.set(userRef.collection('purposeAnswers').doc('values'), {
    answer: {
      en: 'I will not take credit that belongs to someone on my team, even when it would move me forward faster.',
      pt: 'Não fico com crédito que pertence a alguém da minha equipa, mesmo quando isso me faria avançar mais depressa.',
    },
    updatedAt: daysAgo(9),
  });

  // --- Shared exercise library, not per-user -------------------------------

  batch.set(firestore.collection('exercises').doc('ex-sentence-test'), {
    principle: 'purpose',
    title: { en: 'The Sentence Test', pt: 'O Teste da Frase' },
    summary: {
      en: 'Reduce what you are doing to one sentence you would defend.',
      pt: 'Reduza o que anda a fazer a uma frase que defenderia.',
    },
    durationMinutes: 8,
    steps: [
      {
        id: 'st-1',
        type: 'free_text',
        prompt: {
          en: 'Why are you doing the work you are doing right now?',
          pt: 'Porque está a fazer o trabalho que faz neste momento?',
        },
        help: {
          en: 'One sentence. If it needs a comma, it needs cutting.',
          pt: 'Uma frase. Se precisa de vírgula, precisa de corte.',
        },
        options: [],
        scaleLowLabel: {},
        scaleHighLabel: {},
      },
      {
        id: 'st-2',
        type: 'single_choice',
        prompt: {
          en: 'Read it back. Whose sentence is it?',
          pt: 'Releia. De quem é a frase?',
        },
        help: {
          en: 'Answer before you decide what the right answer is.',
          pt: 'Responda antes de decidir qual é a resposta certa.',
        },
        options: [
          { en: 'Mine', pt: 'Minha' },
          { en: 'Someone I admire', pt: 'De alguém que admiro' },
          { en: 'My employer', pt: 'Da minha entidade patronal' },
          { en: 'I am not sure yet', pt: 'Ainda não tenho a certeza' },
        ],
        scaleLowLabel: {},
        scaleHighLabel: {},
      },
      {
        id: 'st-3',
        type: 'free_text',
        prompt: {
          en: 'Rewrite it so it could only have come from you.',
          pt: 'Reescreva-a para que só pudesse ter vindo de si.',
        },
        help: {
          en: 'Keep the part that would embarrass you slightly.',
          pt: 'Mantenha a parte que o embaraçaria ligeiramente.',
        },
        options: [],
        scaleLowLabel: {},
        scaleHighLabel: {},
      },
    ],
    closingReflectionPrompt: {
      en: 'Which version would you say out loud?',
      pt: 'Qual das versões diria em voz alta?',
    },
    suggestedAction: {
      en: 'Say your sentence out loud to one person this week',
      pt: 'Diga a sua frase em voz alta a uma pessoa esta semana',
    },
    isActive: true,
    order: 1,
  });

  batch.set(firestore.collection('exercises').doc('ex-not-trade'), {
    principle: 'purpose',
    title: { en: 'What You Would Not Trade', pt: 'O Que Não Trocaria' },
    summary: {
      en: 'Find the line you will not cross, before you are asked to.',
      pt: 'Encontre o limite que não ultrapassa, antes de lho pedirem.',
    },
    durationMinutes: 6,
    steps: [
      {
        id: 'st-1',
        type: 'free_text',
        prompt: {
          en: 'Name a result you want badly.',
          pt: 'Nomeie um resultado que deseja muito.',
        },
        help: {
          en: 'The one you would not say in a meeting.',
          pt: 'Aquele que não diria numa reunião.',
        },
        options: [],
        scaleLowLabel: {},
        scaleHighLabel: {},
      },
      {
        id: 'st-2',
        type: 'scale',
        prompt: {
          en: 'How much of yourself would you trade for it?',
          pt: 'Quanto de si trocaria por isso?',
        },
        help: { en: 'Answer honestly, then look at it.', pt: 'Responda com honestidade, depois olhe.' },
        options: [],
        scaleLowLabel: { en: 'Nothing', pt: 'Nada' },
        scaleHighLabel: { en: 'Anything', pt: 'Tudo' },
      },
    ],
    closingReflectionPrompt: {
      en: 'Where is the line, in your own words?',
      pt: 'Onde está o limite, nas suas palavras?',
    },
    suggestedAction: {
      en: 'Write the line down where you will see it on a hard week',
      pt: 'Escreva o limite onde o verá numa semana difícil',
    },
    isActive: true,
    order: 2,
  });

  await batch.commit();

  // Counted back from Firestore rather than from the script's own tally, so
  // the report reflects what is actually stored.
  const collections = await userRef.listCollections();
  const counts: Record<string, number> = {};
  let nested = 0;

  for (const collection of collections) {
    const snapshot = await collection.get();
    counts[collection.id] = snapshot.size;
    for (const doc of snapshot.docs) {
      for (const child of await doc.ref.listCollections()) {
        nested += (await child.get()).size;
      }
    }
  }

  const exercises = await firestore.collection('exercises').get();

  console.log(
    [
      '',
      created ? 'Created the persona account.' : 'Reseeded the existing persona account.',
      `  uid:   ${uid}`,
      `  email: ${email}`,
      '',
      'users/' + uid,
      ...Object.entries(counts)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([name, size]) => `  ${name}: ${size}`),
      `  (nested documents: ${nested})`,
      '',
      `exercises: ${exercises.size}`,
      '',
      'Get a token for this account with: npm run token',
      '',
    ].join('\n'),
  );
}

try {
  await seed();
  process.exit(0);
} catch (error) {
  console.error('\nSeeding failed:', error instanceof Error ? error.message : error, '\n');
  process.exit(1);
}
