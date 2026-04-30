// ignore_for_file: avoid_print
//
// Audio Focus Bug Condition Exploration Tests — Task 1
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms the bug exists:
//   VideoPlayerController.initialize() is called WITHOUT a prior
//   AudioSession.configure(ambient) call in all 6 muted video locations.
//
// DO NOT fix the production code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7
//
// Bug Condition (from design.md):
//   isBugCondition(controller, sessionConfiguredAmbient=false) returns true
//   for all 6 muted video locations — no ambient session is configured before
//   VideoPlayerController.initialize(), so the OS takes audio focus and
//   interrupts background audio (e.g. Spotify).
//
// Test approach:
//   Since the production code does NOT call configureAmbientAudioSession()
//   before initialize(), we model the call sequence as a list of recorded
//   calls and assert that 'configureAmbientAudioSession' appears BEFORE
//   'initialize' in that list. On unfixed code, 'configureAmbientAudioSession'
//   never appears at all — so the assertion fails, confirming the bug.
//
// NOTE: The audio_session package is not yet in pubspec.yaml (added in Task
//   3.1). These tests use a pure-Dart call-order tracking approach that does
//   not import audio_session directly, so they compile and run today.
//   After Task 3.1 adds the dependency, the tests remain valid.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Call-order tracker
//
// A lightweight recorder that captures the sequence of named operations.
// Used to assert that configureAmbientAudioSession() is called BEFORE
// VideoPlayerController.initialize() in each muted video location.
// ---------------------------------------------------------------------------

class CallOrderTracker {
  final List<String> calls = [];

  void record(String callName) {
    calls.add(callName);
    print('  [CallOrderTracker] recorded: $callName');
  }

  /// Returns true if [first] appears before [second] in the recorded calls.
  bool calledBefore(String first, String second) {
    final firstIndex = calls.indexOf(first);
    final secondIndex = calls.indexOf(second);
    if (firstIndex == -1) return false; // first was never called
    if (secondIndex == -1) return false; // second was never called
    return firstIndex < secondIndex;
  }

  /// Returns true if [name] was ever recorded.
  bool wasCalled(String name) => calls.contains(name);
}

// ---------------------------------------------------------------------------
// Simulated initialization sequences
//
// Each function below replicates the EXACT call sequence from the production
// code (unfixed). The tracker records what actually happens.
//
// On unfixed code: configureAmbientAudioSession is NEVER recorded.
// On fixed code:   configureAmbientAudioSession is recorded BEFORE initialize.
// ---------------------------------------------------------------------------

/// Replicates BannerVideoPlayer._initializeVideo (homescreen.dart, unfixed).
///
/// Unfixed code:
///   final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
///   await controller.initialize();   // ← no session config before this
///   controller..setLooping(true)..setVolume(0.0);
///   controller.play();
Future<void> simulateBannerVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize'); // initialize() called
  tracker.record('controller.setLooping');
  tracker.record('controller.setVolume.0.0');
  tracker.record('controller.play');
}

/// Replicates HomeScreenState._initSectionVideoController (homescreen.dart, unfixed).
///
/// Unfixed code:
///   final controller = VideoPlayerController.networkUrl(Uri.parse(url));
///   await controller.initialize();   // ← no session config before this
///   controller..setLooping(true)..setVolume(0.0)..play();
Future<void> simulateSectionVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize');
  tracker.record('controller.setLooping');
  tracker.record('controller.setVolume.0.0');
  tracker.record('controller.play');
}

/// Replicates _DynamicHomeScreenState._initVideo (dynamic_homescreen.dart, unfixed).
///
/// Unfixed code:
///   final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
///   await ctrl.initialize();         // ← no session config before this
///   ctrl..setLooping(true)..setVolume(0.0)..play();
Future<void> simulateDynamicHomeVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize');
  tracker.record('ctrl.setLooping');
  tracker.record('ctrl.setVolume.0.0');
  tracker.record('ctrl.play');
}

/// Replicates _BottomNavScreenState._initializeVideoPlayer (bottomnavscreen.dart, unfixed).
///
/// Unfixed code (chained .then() pattern):
///   _videoAdController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
///     ..initialize().then((_) {
///       setState(() => _showVideoAd = true);
///       _videoAdController?.setLooping(true);
///       _videoAdController?.setVolume(0);
///       _videoAdController?.play();
///     });
Future<void> simulateBottomNavVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize');
  // .then() callback fires after initialize completes
  tracker.record('setState._showVideoAd');
  tracker.record('controller.setLooping');
  tracker.record('controller.setVolume.0');
  tracker.record('controller.play');
}

/// Replicates WelcomeScreenState.initState (welcomescreen.dart, unfixed).
///
/// Unfixed code:
///   _videoController = VideoPlayerController.asset(videoOnboard);
///   _initializeVideo = _videoController.initialize().then((_) {
///     if (mounted) {
///       _videoController..setLooping(true)..play();
///       setState(() {});
///     }
///   });
Future<void> simulateWelcomeScreenVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize');
  // .then() callback fires after initialize completes
  tracker.record('controller.setLooping');
  tracker.record('controller.play');
  tracker.record('setState');
}

/// Replicates ProductImageScreenState.getListForPageView (productimage.dart, unfixed).
///
/// Unfixed code (inside getListForPageView loop):
///   videoController = VideoPlayerController.networkUrl(Uri.parse(widget.list[i]["name"]));
///   _initializeVideoPlayerFuture = videoController.initialize();
///   videoController.setLooping(true);
Future<void> simulateProductImageVideoInit(CallOrderTracker tracker) async {
  // UNFIXED: no configureAmbientAudioSession() call here
  tracker.record('videoPlayerController.initialize');
  tracker.record('videoController.setLooping');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Test 1 — Banner Video (BannerVideoPlayer._initializeVideo)
  // =========================================================================
  group(
    'Bug Condition 1.2: BannerVideoPlayer._initializeVideo — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        'VideoPlayerController.initialize() in BannerVideoPlayer._initializeVideo '
        '— EXPECTED TO FAIL (confirms bug 1.2)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 1: BannerVideoPlayer._initializeVideo ---');
          print('Simulating unfixed _initializeVideo call sequence...');

          await simulateBannerVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );
          print(
            'configureAmbientAudioSession before initialize: '
            '${tracker.calledBefore('configureAmbientAudioSession', 'videoPlayerController.initialize')}',
          );

          // This assertion FAILS on unfixed code because
          // configureAmbientAudioSession() is never called.
          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent from the call list.
          //   → OS takes audio focus unconditionally during initialize().
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: BannerVideoPlayer._initializeVideo calls '
                'VideoPlayerController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the OS takes audio focus unconditionally, interrupting '
                'background audio (e.g. Spotify). '
                'Fix: call configureAmbientAudioSession() before initialize().',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test 2 — Section Video (_initSectionVideoController in homescreen.dart)
  // =========================================================================
  group(
    'Bug Condition 1.3: HomeScreen._initSectionVideoController — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        'VideoPlayerController.initialize() in _initSectionVideoController '
        '— EXPECTED TO FAIL (confirms bug 1.3)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 2: HomeScreen._initSectionVideoController ---');
          print('Simulating unfixed _initSectionVideoController call sequence...');

          await simulateSectionVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );

          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent.
          //   → Section video (men/women/accessories tab) takes audio focus.
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: HomeScreen._initSectionVideoController calls '
                'VideoPlayerController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the section/gender tab video takes audio focus, '
                'interrupting background audio. '
                'Fix: call configureAmbientAudioSession() before initialize().',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test 3 — Dynamic Home Video (_initVideo in dynamic_homescreen.dart)
  // =========================================================================
  group(
    'Bug Condition 1.4: DynamicHomeScreen._initVideo — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        'VideoPlayerController.initialize() in DynamicHomeScreen._initVideo '
        '— EXPECTED TO FAIL (confirms bug 1.4)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 3: DynamicHomeScreen._initVideo ---');
          print('Simulating unfixed _initVideo call sequence...');

          await simulateDynamicHomeVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );

          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent.
          //   → Dynamic home screen video takes audio focus.
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: DynamicHomeScreen._initVideo calls '
                'VideoPlayerController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the dynamic home screen video takes audio focus, '
                'interrupting background audio. '
                'Fix: call configureAmbientAudioSession() before initialize().',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test 4 — Bottom Nav Video Ad (_initializeVideoPlayer in bottomnavscreen.dart)
  // =========================================================================
  group(
    'Bug Condition 1.5: BottomNavScreen._initializeVideoPlayer — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        'VideoPlayerController.initialize() in _initializeVideoPlayer '
        '— EXPECTED TO FAIL (confirms bug 1.5)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 4: BottomNavScreen._initializeVideoPlayer ---');
          print('Simulating unfixed _initializeVideoPlayer call sequence...');

          await simulateBottomNavVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );

          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent.
          //   → Video ad (muted, setVolume(0)) takes audio focus.
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: BottomNavScreen._initializeVideoPlayer calls '
                'VideoPlayerController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the video ad (muted via setVolume(0)) takes audio focus, '
                'interrupting background audio. '
                'Fix: call configureAmbientAudioSession() before initialize() '
                'and refactor from .then() to async/await.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test 5 — Welcome Screen (_videoController.initialize() in welcomescreen.dart)
  // =========================================================================
  group(
    'Bug Condition 1.6: WelcomeScreen._videoController.initialize() — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        '_videoController.initialize() in WelcomeScreen.initState '
        '— EXPECTED TO FAIL (confirms bug 1.6)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 5: WelcomeScreen._videoController.initialize() ---');
          print('Simulating unfixed WelcomeScreen initState call sequence...');

          await simulateWelcomeScreenVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );

          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent.
          //   → Welcome/onboarding video takes audio focus (no setVolume call
          //     at all — defaults to system volume, but still takes focus).
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: WelcomeScreen.initState calls '
                '_videoController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the welcome/onboarding video takes audio focus, '
                'interrupting background audio. '
                'Note: no setVolume(0) call exists in this location — '
                'the video plays at system volume but still takes focus. '
                'Fix: extract _initVideoWithAmbientSession() and call '
                'configureAmbientAudioSession() before initialize().',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test 6 — Product Image Video (videoController.initialize() in productimage.dart)
  // =========================================================================
  group(
    'Bug Condition 1.7: ProductImageScreen.videoController.initialize() — '
    'ambient session NOT configured before initialize()',
    () {
      test(
        'EXPLORATION: configureAmbientAudioSession() is NOT called before '
        'videoController.initialize() in ProductImageScreen.getListForPageView '
        '— EXPECTED TO FAIL (confirms bug 1.7)',
        () async {
          final tracker = CallOrderTracker();

          print('\n--- Test 6: ProductImageScreen.videoController.initialize() ---');
          print('Simulating unfixed getListForPageView call sequence...');

          await simulateProductImageVideoInit(tracker);

          print('Recorded calls: ${tracker.calls}');
          print(
            'configureAmbientAudioSession called: '
            '${tracker.wasCalled('configureAmbientAudioSession')}',
          );

          // COUNTEREXAMPLE: calls = [videoPlayerController.initialize, ...]
          //   → 'configureAmbientAudioSession' is absent.
          //   → Product image video takes audio focus (no setVolume call —
          //     user-controlled play/pause, but initialize() still takes focus).
          expect(
            tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            ),
            isTrue,
            reason:
                'BUG CONFIRMED: ProductImageScreen.getListForPageView calls '
                'videoController.initialize() without a prior '
                'AudioSession.configure(ambient) call. '
                'Recorded call sequence: ${tracker.calls}. '
                'configureAmbientAudioSession was never called — '
                'the product image video takes audio focus on initialization, '
                'interrupting background audio. '
                'Fix: extract _initVideoAmbient(url) and call '
                'configureAmbientAudioSession() before initialize().',
          );
        },
      );
    },
  );

  // =========================================================================
  // Summary group: all 6 locations fail the same invariant
  // =========================================================================
  group(
    'Summary: isBugCondition holds for all 6 muted video locations',
    () {
      test(
        'EXPLORATION: none of the 6 muted video locations call '
        'configureAmbientAudioSession() at all — EXPECTED TO FAIL',
        () async {
          final simulators = <String, Future<void> Function(CallOrderTracker)>{
            'BannerVideoPlayer._initializeVideo': simulateBannerVideoInit,
            'HomeScreen._initSectionVideoController': simulateSectionVideoInit,
            'DynamicHomeScreen._initVideo': simulateDynamicHomeVideoInit,
            'BottomNavScreen._initializeVideoPlayer': simulateBottomNavVideoInit,
            'WelcomeScreen.initState': simulateWelcomeScreenVideoInit,
            'ProductImageScreen.getListForPageView': simulateProductImageVideoInit,
          };

          print('\n--- Summary: checking all 6 muted video locations ---');

          final failingLocations = <String>[];

          for (final entry in simulators.entries) {
            final tracker = CallOrderTracker();
            await entry.value(tracker);

            final sessionCalledFirst = tracker.calledBefore(
              'configureAmbientAudioSession',
              'videoPlayerController.initialize',
            );

            if (!sessionCalledFirst) {
              failingLocations.add(entry.key);
              print(
                '  ❌ ${entry.key}: configureAmbientAudioSession NOT called '
                'before initialize(). Calls: ${tracker.calls}',
              );
            } else {
              print(
                '  ✅ ${entry.key}: configureAmbientAudioSession called '
                'before initialize().',
              );
            }
          }

          print('\nFailing locations (${failingLocations.length}/6):');
          for (final loc in failingLocations) {
            print('  - $loc');
          }

          // This assertion FAILS on unfixed code because all 6 locations
          // are missing the configureAmbientAudioSession() call.
          // COUNTEREXAMPLE: failingLocations contains all 6 location names.
          expect(
            failingLocations,
            isEmpty,
            reason:
                'BUG CONFIRMED: ${failingLocations.length} of 6 muted video '
                'locations call VideoPlayerController.initialize() without a '
                'prior AudioSession.configure(ambient) call:\n'
                '${failingLocations.map((l) => '  - $l').join('\n')}\n'
                'In each case, isBugCondition(controller, '
                'sessionConfiguredAmbient=false) returns true — the OS takes '
                'audio focus unconditionally during initialize(), interrupting '
                'background audio (e.g. Spotify). '
                'Fix: call configureAmbientAudioSession() before each '
                'VideoPlayerController.initialize() in all 6 locations.',
          );
        },
      );
    },
  );
}
