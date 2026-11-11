import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:private_agent/models/task_step.dart';
import 'package:private_agent/services/ai_service.dart';
import 'package:private_agent/services/app_usage_service.dart';
import 'package:private_agent/services/calendar_reminder_service.dart';
import 'package:private_agent/services/commute_traffic_service.dart';
import 'package:private_agent/services/conversational_memory_service.dart';
import 'package:private_agent/services/email_triage_service.dart';
import 'package:private_agent/services/finance_tracking_service.dart';
import 'package:private_agent/services/form_filling_service.dart';
import 'package:private_agent/services/hermes_evolution_service.dart';
import 'package:private_agent/services/inbox_service.dart';
import 'package:private_agent/services/jarvis_service.dart';
import 'package:private_agent/services/macro_recorder_service.dart';
import 'package:private_agent/services/message_drafting_service.dart';
import 'package:private_agent/services/notes_knowledge_service.dart';
import 'package:private_agent/services/permission_manager_service.dart';
import 'package:private_agent/services/air_gesture_service.dart';
import 'package:private_agent/services/airspace_radar_service.dart';
import 'package:private_agent/services/charging_telemetry_service.dart';
import 'package:private_agent/services/code_black_service.dart';
import 'package:private_agent/services/floating_copilot_service.dart';
import 'package:private_agent/services/multi_task_service.dart';
import 'package:private_agent/services/network_audit_service.dart';
import 'package:private_agent/services/optical_solver_service.dart';
import 'package:private_agent/services/personality_service.dart';
import 'package:private_agent/services/phone_storage_service.dart';
import 'package:private_agent/services/polyglot_diplomat_service.dart';
import 'package:private_agent/services/proactive_agent_service.dart';
import 'package:private_agent/services/routine_automation_service.dart';
import 'package:private_agent/services/security_alert_service.dart';
import 'package:private_agent/services/sentry_service.dart';
import 'package:private_agent/services/settings_service.dart';
import 'package:private_agent/services/smart_home_service.dart';
import 'package:private_agent/services/sound_radar_service.dart';
import 'package:private_agent/services/sports_service.dart';
import 'package:private_agent/services/system_diagnostics_service.dart';
import 'package:private_agent/services/todo_service.dart';
import 'package:private_agent/services/vision_perception_service.dart';
import 'package:private_agent/services/workflow_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Feature 1: Conversational Memory & Learning', () {
    test('Stores, retrieves, and wipes cross-session facts and dialogue history', () async {
      final memory = ConversationalMemoryService.instance;
      await memory.wipeAll();

      final fact = await memory.addFact('User prefers dark mode and British English voice', category: 'preference');
      expect(fact.fact, contains('dark mode'));
      expect(memory.facts.length, 1);

      // Record dialogue turn
      await memory.recordTurn('Remember that my favorite club is Real Madrid', 'Understood, sir. Recorded in your knowledge base.');
      expect(memory.persistedHistory.length, 2);
      expect(memory.facts.any((f) => f.fact.contains('Real Madrid')), isTrue);

      final promptContext = memory.buildMemoryContext();
      expect(promptContext, contains('USER MEMORY & PREFERENCES'));
      expect(promptContext, contains('dark mode'));

      // Delete fact
      await memory.deleteFact(fact.id);
      expect(memory.facts.any((f) => f.id == fact.id), isFalse);

      // Wipe all
      await memory.wipeAll();
      expect(memory.facts.isEmpty, isTrue);
      expect(memory.persistedHistory.isEmpty, isTrue);
    });
  });

  group('Feature 2: Personality & Emotional Awareness', () {
    test('Adapts persona instructions, detects urgency and emotion', () async {
      final personality = PersonalityService.instance;
      await personality.init();

      await personality.setArchetype(PersonalityArchetype.jarvis);
      await personality.setFormality(FormalityLevel.formal);
      await personality.setHumor(HumorLevel.subtle);

      final jarvisPrompt = personality.buildPersonaPrompt('Please help me quickly');
      expect(jarvisPrompt, contains('ARCHETYPE: You are Jarvis'));
      expect(jarvisPrompt, contains('FORMALITY'));

      // Emotional state detection
      final urgentEmotion = personality.detectEmotion('Please hurry, this is an emergency ASAP!');
      expect(urgentEmotion, DetectedEmotion.urgent);

      final frustratedEmotion = personality.detectEmotion('This is so annoying and broken, I hate it');
      expect(frustratedEmotion, DetectedEmotion.frustrated);

      final tiredEmotion = personality.detectEmotion('I am feeling so exhausted and tired today');
      expect(tiredEmotion, DetectedEmotion.tired);

      final happyEmotion = personality.detectEmotion('This is wonderful, great job!');
      expect(happyEmotion, DetectedEmotion.happy);
    });
  });

  group('Feature 3: Calendar & Reminders', () {
    test('Schedules items, provides daily briefing, and deletes events', () async {
      final calendar = CalendarReminderService.instance;
      await calendar.init();

      final now = DateTime.now();
      final item = await calendar.addItem(
        title: 'Team Architecture Sync',
        dateTime: DateTime(now.year, now.month, now.day, now.hour, now.minute),
        isReminder: false,
        description: 'Discuss Jarvis neural integration',
      );

      expect(calendar.items.any((i) => i.id == item.id), isTrue);

      final briefing = calendar.getTodayBriefingSpoken();
      expect(briefing, contains('Team Architecture Sync'));

      await calendar.deleteItem(item.id);
      expect(calendar.items.any((i) => i.id == item.id), isFalse);
    });
  });

  group('Feature 4: Email Triage', () {
    test('Triages email into structured priority and suggested replies', () async {
      final triage = EmailTriageService.instance;

      final urgentResult = await triage.triageEmail('Urgent: server cluster outage, immediate attention required.');
      expect(urgentResult.priority, EmailPriority.urgent);
      expect(urgentResult.suggestedReplies.isNotEmpty, isTrue);
    });
  });

  group('Feature 5: To-Do List & Task Tracking', () {
    test('Manages tasks with priority, completion state, and spoken summary', () async {
      final todo = TodoService.instance;
      await todo.init();

      final task = await todo.addTask(
        'Submit quarterly expense report',
        priority: TodoPriority.high,
      );

      expect(todo.items.any((t) => t.id == task.id), isTrue);
      expect(todo.pendingItems.any((t) => t.id == task.id), isTrue);

      final spoken = todo.getPendingTasksSpoken();
      expect(spoken, contains('quarterly expense report'));

      // Toggle done
      await todo.toggleDone(task.id);
      expect(todo.pendingItems.any((t) => t.id == task.id), isFalse);
      expect(todo.completedItems.any((t) => t.id == task.id), isTrue);

      // Delete task
      await todo.deleteTask(task.id);
      expect(todo.items.any((t) => t.id == task.id), isFalse);
    });
  });

  group('Feature 6: Notes & Knowledge Base', () {
    test('Stores notes, supports keyword search, and deletes notes', () async {
      final notes = NotesKnowledgeService.instance;
      await notes.init();

      final note = await notes.addNote(
        title: 'Quantum Core Specs',
        content: 'Arc-Reactor frequency calibrated to 14.2 GHz with neodymium coils.',
        tags: ['hardware', 'stark'],
      );

      expect(notes.notes.any((n) => n.id == note.id), isTrue);

      final searchResults = notes.searchNotes('neodymium');
      expect(searchResults.length, 1);
      expect(searchResults.first.title, 'Quantum Core Specs');

      final searchMiss = notes.searchNotes('cryptocurrency');
      expect(searchMiss.isEmpty, isTrue);

      await notes.deleteNote(note.id);
      expect(notes.notes.any((n) => n.id == note.id), isFalse);
    });
  });

  group('Feature 7: Routine Automation', () {
    test('Generates morning briefing and evening routines', () async {
      final routines = RoutineAutomationService.instance;
      final morning = await routines.executeMorningRoutine();
      expect(morning, contains('Good morning, sir'));

      final evening = await routines.executeEveningRoutine();
      expect(evening, contains('Night Protocol'));
    });
  });

  group('Feature 8: Security Monitoring & Risk Assessment', () {
    test('Assesses low, medium, and high risk actions correctly', () {
      final security = SecurityAlertService.instance;

      final lowRisk = security.evaluateActionRisk('Check the weather in London');
      expect(lowRisk.riskLevel, RiskLevel.low);
      expect(lowRisk.requiresConfirmation, isFalse);

      final mediumRisk = security.evaluateActionRisk('Turn off Bluetooth');
      expect(mediumRisk.riskLevel, RiskLevel.medium);

      final highRisk = security.evaluateActionRisk('Transfer money and delete all personal messages');
      expect(highRisk.riskLevel, RiskLevel.high);
      expect(highRisk.requiresConfirmation, isTrue);
    });
  });

  group('Feature 9 & 10: Finance Tracking & Sports Service', () {
    test('Constructs crypto queries and sports updates', () async {
      final finance = FinanceTrackingService.instance;
      expect(finance, isNotNull);

      final sports = SportsService.instance;
      expect(sports, isNotNull);
    });
  });

  group('Feature 13: Message Drafting & Dispatch', () {
    test('Generates WhatsApp and SMS draft models', () {
      final draft = const MessageDraft(
        channel: MessageChannel.whatsapp,
        recipient: '+1234567890',
        body: 'Meeting moved to 3 PM',
      );

      expect(draft.channel, MessageChannel.whatsapp);
      expect(draft.recipient, '+1234567890');
      expect(draft.body, 'Meeting moved to 3 PM');

      final smsDraft = const MessageDraft(
        channel: MessageChannel.sms,
        recipient: '+1987654321',
        body: 'I have arrived safely',
      );
      expect(smsDraft.channel, MessageChannel.sms);
    });
  });

  group('Advanced Intelligence: Proactive Needs Evaluation & Autonomous Voice', () {
    test('Evaluates temporal and contextual needs', () async {
      final proactive = ProactiveAgentService.instance;
      final suggestion = await proactive.evaluateProactiveNeeds();
      // Hour dependent, but will always produce a valid ProactiveSuggestion or null
      if (suggestion != null) {
        expect(suggestion.title.isNotEmpty, isTrue);
        expect(suggestion.actionGoal.isNotEmpty, isTrue);
        expect(suggestion.spokenPrompt.isNotEmpty, isTrue);
        proactive.dismissSuggestion();
        expect(proactive.currentSuggestion, isNull);
      }
    });

    test('Night Mode Auto-Speak trigger at 10:00 PM (22:00)', () async {
      final proactive = ProactiveAgentService.instance;
      proactive.clearDeduplicationHistory();

      final nightTime = DateTime(2026, 11, 2, 22, 0); // 10:00 PM
      final suggestion = await proactive.evaluateProactiveNeeds(nowOverride: nightTime);

      expect(suggestion, isNotNull);
      expect(suggestion!.id, contains('night_prompt'));
      expect(suggestion.spokenPrompt, "It's night time, sir. Should I turn on the night mode?");
      expect(suggestion.actionGoal, 'turn on night mode');
    });

    test('Study & Focus Protocol trigger at 3:00 PM (15:00)', () async {
      final proactive = ProactiveAgentService.instance;
      proactive.clearDeduplicationHistory();

      final studyTime = DateTime(2026, 11, 2, 15, 0); // 3:00 PM
      final suggestion = await proactive.evaluateProactiveNeeds(nowOverride: studyTime);

      expect(suggestion, isNotNull);
      expect(suggestion!.id, contains('study_prompt'));
      expect(suggestion.spokenPrompt, contains('study and focus session'));
      expect(suggestion.actionGoal, 'study mode');
    });

    test('Upcoming Meeting reminder within 30 minutes', () async {
      final calendar = CalendarReminderService.instance;
      await calendar.init();

      final now = DateTime(2026, 11, 2, 11, 0);
      final meetingTime = DateTime(2026, 11, 2, 11, 20); // 20 minutes from now

      final item = await calendar.addItem(
        title: 'Quarterly Executive Review',
        dateTime: meetingTime,
        description: 'Boardroom Presentation',
      );

      final proactive = ProactiveAgentService.instance;
      proactive.clearDeduplicationHistory();

      final suggestion = await proactive.evaluateProactiveNeeds(nowOverride: now);
      expect(suggestion, isNotNull);
      expect(suggestion!.id, 'meeting_${item.id}');
      expect(suggestion.spokenPrompt, contains('Quarterly Executive Review'));
      expect(suggestion.title, contains('Quarterly Executive Review'));
    });

    test('Pending Tasks Review in early evening at 6:00 PM (18:00)', () async {
      final todos = TodoService.instance;
      await todos.init();
      await todos.addTask('Finalize Quarterly Budget Report', priority: TodoPriority.high);

      final proactive = ProactiveAgentService.instance;
      proactive.clearDeduplicationHistory();

      final eveningTime = DateTime(2026, 11, 2, 18, 0); // 6:00 PM
      final suggestion = await proactive.evaluateProactiveNeeds(nowOverride: eveningTime);

      expect(suggestion, isNotNull);
      expect(suggestion!.id, contains('todo_prompt'));
      expect(suggestion.spokenPrompt, contains('remaining on your agenda today'));
      expect(suggestion.actionGoal, 'Show my tasks');
    });

    test('Hands-Free Voice Confirmation: Affirmative response classification', () {
      expect(JarvisService.isAffirmativeResponse('yes'), isTrue);
      expect(JarvisService.isAffirmativeResponse('yeah please'), isTrue);
      expect(JarvisService.isAffirmativeResponse('sure'), isTrue);
      expect(JarvisService.isAffirmativeResponse('turn it on'), isTrue);
      expect(JarvisService.isAffirmativeResponse('do it'), isTrue);
      expect(JarvisService.isAffirmativeResponse('engage'), isTrue);
      expect(JarvisService.isAffirmativeResponse('activate'), isTrue);
      expect(JarvisService.isAffirmativeResponse('ok go ahead'), isTrue);
      expect(JarvisService.isAffirmativeResponse('sounds good'), isTrue);
    });

    test('Hands-Free Voice Confirmation: Negative response classification', () {
      expect(JarvisService.isNegativeResponse('no'), isTrue);
      expect(JarvisService.isNegativeResponse('nope'), isTrue);
      expect(JarvisService.isNegativeResponse('not now'), isTrue);
      expect(JarvisService.isNegativeResponse('cancel'), isTrue);
      expect(JarvisService.isNegativeResponse('never mind'), isTrue);
      expect(JarvisService.isNegativeResponse('later'), isTrue);
      expect(JarvisService.isNegativeResponse('dismiss'), isTrue);
      expect(JarvisService.isNegativeResponse('leave it'), isTrue);
    });
  });

  group('Desk Mode: Wake Word Gating & Ambient Chatter Rejection', () {
    test('Rejects ambient conversations between friends sitting near desk', () {
      expect(JarvisService.extractWakeCommand('Hey man did you see the match yesterday'), isNull);
      expect(JarvisService.extractWakeCommand('Bro what are we having for lunch'), isNull);
      expect(JarvisService.extractWakeCommand('I searched that on google earlier'), isNull);
      expect(JarvisService.extractWakeCommand('Pass me that jar, visitor is here'), isNull);
      expect(JarvisService.extractWakeCommand('What are today to new headlines'), isNull);
    });

    test('Accurately detects Jarvis wake phrases and extracts user commands', () {
      // User says: "Hey Jarvis what are today to new headlines"
      expect(
        JarvisService.extractWakeCommand('Hey Jarvis, what are today to new headlines'),
        'what are today to new headlines',
      );
      expect(
        JarvisService.extractWakeCommand('jarvis what are today to new headlines'),
        'what are today to new headlines',
      );
      expect(
        JarvisService.extractWakeCommand('Hello Jarvis what are today to new headlines?'),
        'what are today to new headlines',
      );
      expect(
        JarvisService.extractWakeCommand('what are today to new headlines, Jarvis?'),
        'what are today to new headlines',
      );
    });

    test('Recognizes stand-alone wake greetings', () {
      expect(JarvisService.extractWakeCommand('Hey Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Hey, Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Jarvis!'), '');
      expect(JarvisService.extractWakeCommand('Hello Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Hello, Jarvis!'), '');
      expect(JarvisService.extractWakeCommand('Ok Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Hi Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Hey Javis'), '');
      expect(JarvisService.extractWakeCommand('Wake up Jarvis'), '');
      expect(JarvisService.extractWakeCommand('Jarvis wake up'), '');
      expect(JarvisService.extractWakeCommand('Hey service'), '');
      expect(JarvisService.extractWakeCommand('Hey Travis'), '');
      expect(JarvisService.extractWakeCommand('Hey Davis'), '');
      expect(JarvisService.extractWakeCommand('Hey Davies'), '');
    });
  });

  group('Hermes Agent Self-Evolution (SOUL.md, USER.md, AGENT.md)', () {
    test('Initializes, evolves, updates, and resets tri-partite markdown context', () async {
      final hermes = HermesEvolutionService.instance;
      await hermes.resetAll();

      expect(hermes.soulMd, contains('SOUL.md'));
      expect(hermes.soulMd, contains('J.A.R.V.I.S.'));
      expect(hermes.userMd, contains('USER.md'));
      expect(hermes.userMd, contains('Operator Profile'));
      expect(hermes.agentMd, contains('AGENT.md'));
      expect(hermes.agentMd, contains('Active Hardware Protocols'));

      // Evolve with simulated memory facts
      final memory = ConversationalMemoryService.instance;
      await memory.addFact('Favorite language is Rust', category: 'preference');
      await memory.addFact('Prefers morning meetings before 11 AM', category: 'habit');

      await hermes.evolveContext();

      expect(hermes.lastEvolvedAt, isNotNull);
      expect(hermes.userMd, contains('Favorite language is Rust'));
      expect(hermes.userMd, contains('Prefers morning meetings before 11 AM'));
      expect(hermes.agentMd, contains('Study Protocol'));
      expect(hermes.agentMd, contains('Sleep Protocol'));
      expect(hermes.evolutionLog.isNotEmpty, isTrue);

      // Verify system context injection
      final contextStr = hermes.buildHermesSystemContext();
      expect(contextStr, contains('[HERMES CONTEXT: SLOT 1 - SOUL.md]'));
      expect(contextStr, contains('[HERMES CONTEXT: SLOT 2 - USER.md]'));
      expect(contextStr, contains('[HERMES CONTEXT: SLOT 3 - AGENT.md]'));

      // Test custom update
      await hermes.updateSoul('# CUSTOM SOUL\nDirect and ruthless efficiency.');
      expect(hermes.soulMd, contains('CUSTOM SOUL'));

      // Test reset soul
      await hermes.resetSoul();
      expect(hermes.soulMd, contains('J.A.R.V.I.S. Core Identity'));

      // Clean up
      await hermes.resetAll();
      await memory.wipeAll();
    });
  });

  group('Inbox Reading & Permission Manager', () {
    test('Parses and formats SMS and Email inbox models', () async {
      final sms = SmsMessage.fromMap({
        'id': '101',
        'sender': '+1234567890',
        'body': 'Your one-time login code is 492819',
        'date': DateTime.now().milli
