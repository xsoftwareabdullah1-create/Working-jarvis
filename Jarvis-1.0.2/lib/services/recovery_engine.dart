import '../models/task_step.dart';

/// Detects when the agent loop is stuck (same action repeating, A-B-A-B
/// oscillation, or the screen never changing) and proposes corrective
/// fallback actions.
class RecoveryEngine {
  static const _signatureWindow = 3;
  static const _unchangedThreshold = 3;

  final List<String> _recentSignatures = [];
  String? _lastScreenFingerprint;
  int _unchangedScreens = 0;
  int _recoveryCursor = 0;

  void reset() {
    _recentSignatures.clear();
    _lastScreenFingerprint = null;
    _unchangedScreens = 0;
    _recoveryCursor = 0;
  }

  /// How many consecutive observations showed an identical screen.
  int get unchangedScreens => _unchangedScreens;

  void recordAction(TaskStep step) {
    _recentSignatures.add(step.signature);
    if (_recentSignatures.length > 12) {
      _recentSignatures.removeAt(0);
    }
  }

  /// Records a lightweight fingerprint of the latest screen dump.
  void recordScreen(String formattedDump) {
    if (formattedDump == _lastScreenFingerprint) {
      _unchangedScreens++;
    } else {
      _unchangedScreens = 0;
      _lastScreenFingerprint = formattedDump;
      // Real progress was made: restart the strategy rotation.
      _recoveryCursor = 0;
    }
  }

  /// The exact same action (name + params) repeated >= 3 times in a row.
  bool get isRepeatingActions {
    if (_recentSignatures.length < _signatureWindow) return false;
    final tail =
        _recentSignatures.sublist(_recentSignatures.length - _signatureWindow);
    return tail.toSet().length == 1;
  }

  /// A-B-A-B oscillation (e.g. scroll down / scroll up forever).
  bool get isOscillating {
    if (_recentSignatures.length < 4) return false;
    final t = _recentSignatures.sublist(_recentSignatures.length - 4);
    return t[0] == t[2] && t[1] == t[3] && t[0] != t[1];
  }

  bool get isScreenStuck => _unchangedScreens >= _unchangedThreshold;

  /// Repeating the same action is only a problem when the screen is not
  /// reacting (scrolling a long feed 10x is perfectly legitimate).
  bool get shouldRecover =>
      (isRepeatingActions && _unchangedScreens >= 1) ||
      isScreenStuck ||
      isOscillating;

  /// Rotating recovery strategies: scroll for more content, wait for slow
  /// screens, look back up, then back out of a dead end.
  TaskStep suggestRecovery() {
    const strategies = [
      TaskStep(
        action: TaskStep.actionScroll,
        params: {'direction': 'down'},
        reasoning: 'Recovery: screen appears stuck; scrolling for new content.',
      ),
      TaskStep(
        action: TaskStep.actionWait,
        params: {'ms': 2500},
        reasoning: 'Recovery: waiting for the UI to settle.',
      ),
      TaskStep(
        action: TaskStep.actionScroll,
        params: {'direction': 'up'},
        reasoning: 'Recovery: scrolling back up to look for missed elements.',
      ),
      TaskStep(
        action: TaskStep.actionPressBack,
        params: {},
        reasoning: 'Recovery: backing out of a possible dead end.',
      ),
    ];
    final step = strategies[_recoveryCursor % strategies.length];
    _recoveryCursor++;
    return step;
  }
}
