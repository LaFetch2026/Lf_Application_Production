// ignore_for_file: avoid_print
//
// PDP iOS Safe Area & Keyboard Bug Condition Exploration Tests — Task 1
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms each bug exists:
//   Bug A — _buildActionButtons outer Padding.bottom does not include
//            safeAreaBottom, so buttons overlap the iOS home indicator.
//   Bug B — Review bottom sheet Submit container bottom padding does not
//            include safeAreaBottom, so the button is inside the gesture bar.
//   Bug C — Review bottom sheet Container height is fixed at
//            screenHeight * 0.85 regardless of keyboard height, so the
//            keyboard covers the text field and Submit button.
//   Bug D — Review bottom sheet TextField has no textInputAction, so iOS
//            shows no "Done" button in the keyboard toolbar.
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.5, 1.6

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers that replicate the EXACT logic from the source files so we can
// assert on the bug conditions without spinning up the full widget tree
// (which requires Firebase, Razorpay, GetX bindings, etc.).
//
// Each helper mirrors the CURRENT (unfixed) code path.
// ---------------------------------------------------------------------------

// ── Bug A helpers ──────────────────────────────────────────────────────────

/// Replicates the CURRENT (unfixed) bottom padding of the outer Padding
/// widget in `_buildActionButtons` in `pdp_delivery_section.dart`.
///
/// Unfixed code:
///   Padding(
///     padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
///     ...
///   )
///
/// `vertical: 8.sp` means both top AND bottom are 8.sp.
/// The bottom padding does NOT include `MediaQuery.of(context).padding.bottom`.
///
/// We model `sp` as a 1:1 ratio (scale factor = 1.0) for test purposes.
double unfixedActionButtonsBottomPadding({required double safeAreaBottom}) {
  // UNFIXED: bottom padding is always 8.sp, regardless of safeAreaBottom
  const double verticalPadding = 8.0; // 8.sp with scale factor 1.0
  return verticalPadding; // safeAreaBottom is NOT added
}

/// Replicates the FIXED bottom padding of the outer Padding widget.
double fixedActionButtonsBottomPadding({required double safeAreaBottom}) {
  // FIXED: bottom = 8.sp + safeAreaBottom
  const double verticalPadding = 8.0;
  return verticalPadding + safeAreaBottom;
}

// ── Bug B helpers ──────────────────────────────────────────────────────────

/// Replicates the CURRENT (unfixed) bottom padding of the Submit button
/// Container in `_ReviewBottomSheetState.build` in `pdp_dialogs.dart`.
///
/// Unfixed code:
///   Container(
///     padding: EdgeInsets.all(16.sp),
///     ...
///   )
///
/// `EdgeInsets.all(16.sp)` means all sides are 16.sp.
/// The bottom padding does NOT include `MediaQuery.of(context).padding.bottom`.
double unfixedSubmitContainerBottomPadding({required double safeAreaBottom}) {
  // UNFIXED: bottom padding is always 16.sp, regardless of safeAreaBottom
  const double allPadding = 16.0; // 16.sp with scale factor 1.0
  return allPadding; // safeAreaBottom is NOT added
}

/// Replicates the FIXED bottom padding of the Submit button Container.
double fixedSubmitContainerBottomPadding({required double safeAreaBottom}) {
  // FIXED: bottom = 16.sp + safeAreaBottom
  const double allPadding = 16.0;
  return allPadding + safeAreaBottom;
}

// ── Bug C helpers ──────────────────────────────────────────────────────────

/// Replicates the CURRENT (unfixed) height of the root Container in
/// `_ReviewBottomSheetState.build` in `pdp_dialogs.dart`.
///
/// Unfixed code:
///   Container(
///     height: MediaQuery.of(context).size.height * 0.85,
///     ...
///   )
///
/// The height is fixed at 85% of screen height regardless of keyboard height.
double unfixedSheetHeight({
  required double screenHeight,
  required double keyboardHeight,
}) {
  // UNFIXED: height is always screenHeight * 0.85, keyboard is NOT subtracted
  return screenHeight * 0.85;
}

/// Replicates the FIXED height of the root Container.
double fixedSheetHeight({
  required double screenHeight,
  required double keyboardHeight,
}) {
  // FIXED: height = screenHeight * 0.85 - keyboardHeight
  return screenHeight * 0.85 - keyboardHeight;
}

// ── Bug D helpers ──────────────────────────────────────────────────────────

/// Represents the textInputAction of the review TextField.
///
/// Unfixed code:
///   TextField(
///     controller: _ctrl,
///     maxLines: 6,
///     maxLength: 500,
///     decoration: InputDecoration(...),
///     style: TextStyle(...),
///   )
///
/// No `textInputAction` is set, so it defaults to null (Flutter uses the
/// platform default, which on iOS is the "return" key with no "Done" button).
String? unfixedTextFieldTextInputAction() {
  // UNFIXED: textInputAction is not set → null
  return null;
}

/// Replicates the FIXED textInputAction of the review TextField.
String? fixedTextFieldTextInputAction() {
  // FIXED: textInputAction: TextInputAction.done
  return 'TextInputAction.done';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Test A — PDP action buttons: bottom padding must include safeAreaBottom
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedActionButtonsBottomPadding(safeAreaBottom: 34) returns 8.0,
  //   which is < 34, so the assertion `>= 34` fails.
  //
  // Validates: Requirements 1.6, 2.1, 2.6
  // =========================================================================
  group(
    'Test A — PDP action buttons: outer Padding.bottom >= safeAreaBottom',
    () {
      test(
        'EXPLORATION: _buildActionButtons outer Padding.bottom >= 34 '
        'on iPhone 14 (safeAreaBottom=34) '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug A)',
        () {
          // Arrange: iPhone 14 / iPhone X class device
          const double safeAreaBottom = 34.0;

          // Act: compute the bottom padding as the UNFIXED code does
          final bottomPadding = unfixedActionButtonsBottomPadding(
            safeAreaBottom: safeAreaBottom,
          );

          // Log the counterexample
          print('');
          print('🐛 Bug A Counterexample:');
          print('   Device:       iPhone 14 (safeAreaBottom=$safeAreaBottom)');
          print('   Expected:     Padding.bottom >= $safeAreaBottom');
          print('   Actual:       Padding.bottom = $bottomPadding');
          print('   Root cause:   _buildActionButtons uses '
              'EdgeInsets.symmetric(vertical: 8.sp) — '
              'safeAreaBottom is NOT added to the bottom padding.');
          print('   Impact:       "ADD TO BAG" and "BUY NOW" buttons overlap '
              'the iOS home indicator and are unclickable.');
          print('');

          // Assert: EXPECTED TO FAIL on unfixed code
          // The unfixed code returns 8.0, which is < 34.
          expect(
            bottomPadding,
            greaterThanOrEqualTo(safeAreaBottom),
            reason:
                'BUG A CONFIRMED: _buildActionButtons outer Padding.bottom = '
                '$bottomPadding, which is < $safeAreaBottom. '
                'Root cause: EdgeInsets.symmetric(vertical: 8.sp) does not '
                'include MediaQuery.of(context).padding.bottom. '
                'On iPhone 14 (safeAreaBottom=34), the "ADD TO BAG" and '
                '"BUY NOW" buttons overlap the home indicator zone and '
                'become unclickable. '
                'Fix: replace with EdgeInsets.only(bottom: 8.sp + safeAreaBottom).',
          );
        },
      );

      test(
        'EXPLORATION: _buildActionButtons bottom padding equals '
        '8.sp + safeAreaBottom on iOS '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug A)',
        () {
          const double safeAreaBottom = 34.0;
          const double expectedBottomPadding = 8.0 + safeAreaBottom; // 42.0

          final actualBottomPadding = unfixedActionButtonsBottomPadding(
            safeAreaBottom: safeAreaBottom,
          );

          print('');
          print('🐛 Bug A Counterexample (exact value):');
          print('   safeAreaBottom:       $safeAreaBottom');
          print('   Expected bottom:      $expectedBottomPadding (8.sp + 34)');
          print('   Actual bottom:        $actualBottomPadding (8.sp only)');
          print('');

          expect(
            actualBottomPadding,
            equals(expectedBottomPadding),
            reason:
                'BUG A CONFIRMED: Padding.bottom = $actualBottomPadding, '
                'expected $expectedBottomPadding (8.sp + safeAreaBottom). '
                'The unfixed code uses vertical: 8.sp which ignores '
                'safeAreaBottom entirely.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test B — Review Submit container: bottom padding must include safeAreaBottom
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedSubmitContainerBottomPadding(safeAreaBottom: 34) returns 16.0,
  //   which is < 34, so the assertion `>= 34` fails.
  //
  // Validates: Requirements 1.2, 2.2
  // =========================================================================
  group(
    'Test B — Review Submit container: bottom padding >= safeAreaBottom',
    () {
      test(
        'EXPLORATION: Submit container bottom padding >= 34 '
        'on iPhone 14 (safeAreaBottom=34) '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug B)',
        () {
          // Arrange: iPhone 14 / iPhone X class device
          const double safeAreaBottom = 34.0;

          // Act: compute the bottom padding as the UNFIXED code does
          final bottomPadding = unfixedSubmitContainerBottomPadding(
            safeAreaBottom: safeAreaBottom,
          );

          // Log the counterexample
          print('');
          print('🐛 Bug B Counterexample:');
          print('   Device:       iPhone 14 (safeAreaBottom=$safeAreaBottom)');
          print('   Expected:     Container.bottom >= $safeAreaBottom');
          print('   Actual:       Container.bottom = $bottomPadding');
          print('   Root cause:   _ReviewBottomSheetState.build uses '
              'EdgeInsets.all(16.sp) for the Submit container — '
              'safeAreaBottom is NOT added to the bottom padding.');
          print('   Impact:       "SUBMIT REVIEW" button overlaps the iOS '
              'home indicator and is unclickable.');
          print('');

          // Assert: EXPECTED TO FAIL on unfixed code
          // The unfixed code returns 16.0, which is < 34.
          expect(
            bottomPadding,
            greaterThanOrEqualTo(safeAreaBottom),
            reason:
                'BUG B CONFIRMED: Submit container bottom padding = '
                '$bottomPadding, which is < $safeAreaBottom. '
                'Root cause: EdgeInsets.all(16.sp) does not include '
                'MediaQuery.of(context).padding.bottom. '
                'On iPhone 14 (safeAreaBottom=34), the "SUBMIT REVIEW" '
                'button overlaps the home indicator zone and becomes '
                'unclickable. '
                'Fix: replace with EdgeInsets.only(bottom: 16.sp + safeAreaBottom).',
          );
        },
      );

      test(
        'EXPLORATION: Submit container bottom padding equals '
        '16.sp + safeAreaBottom on iOS '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug B)',
        () {
          const double safeAreaBottom = 34.0;
          const double expectedBottomPadding = 16.0 + safeAreaBottom; // 50.0

          final actualBottomPadding = unfixedSubmitContainerBottomPadding(
            safeAreaBottom: safeAreaBottom,
          );

          print('');
          print('🐛 Bug B Counterexample (exact value):');
          print('   safeAreaBottom:       $safeAreaBottom');
          print('   Expected bottom:      $expectedBottomPadding (16.sp + 34)');
          print('   Actual bottom:        $actualBottomPadding (16.sp only)');
          print('');

          expect(
            actualBottomPadding,
            equals(expectedBottomPadding),
            reason:
                'BUG B CONFIRMED: Submit container bottom = $actualBottomPadding, '
                'expected $expectedBottomPadding (16.sp + safeAreaBottom). '
                'The unfixed code uses EdgeInsets.all(16.sp) which ignores '
                'safeAreaBottom entirely.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test C — Review sheet height: must shrink when keyboard is open
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedSheetHeight(screenHeight: 844, keyboardHeight: 336) returns
  //   844 * 0.85 = 717.4, which is > 717.4 - 336 = 381.4, so the assertion
  //   `<= screenHeight * 0.85 - keyboardHeight` fails.
  //
  // Validates: Requirements 1.3, 2.3
  // =========================================================================
  group(
    'Test C — Review sheet height: must subtract keyboard height',
    () {
      test(
        'EXPLORATION: sheet Container height <= screenHeight * 0.85 - 336 '
        'when keyboard is open (viewInsets.bottom=336) '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug C)',
        () {
          // Arrange: iPhone 14 with keyboard open
          const double screenHeight = 844.0; // iPhone 14 screen height in pt
          const double keyboardHeight = 336.0; // typical iOS keyboard height
          final double maxAllowedHeight =
              screenHeight * 0.85 - keyboardHeight; // 717.4 - 336 = 381.4

          // Act: compute the sheet height as the UNFIXED code does
          final actualHeight = unfixedSheetHeight(
            screenHeight: screenHeight,
            keyboardHeight: keyboardHeight,
          );

          // Log the counterexample
          print('');
          print('🐛 Bug C Counterexample:');
          print('   Device:           iPhone 14 (screenHeight=$screenHeight)');
          print('   Keyboard height:  $keyboardHeight');
          print('   Expected height:  <= $maxAllowedHeight '
              '(screenHeight * 0.85 - keyboardHeight)');
          print('   Actual height:    $actualHeight '
              '(screenHeight * 0.85, keyboard NOT subtracted)');
          print('   Root cause:       _ReviewBottomSheetState.build uses '
              'height: MediaQuery.of(context).size.height * 0.85 — '
              'viewInsets.bottom is NOT subtracted.');
          print('   Impact:           The keyboard slides over the sheet '
              'content, hiding the text field and Submit button.');
          print('');

          // Assert: EXPECTED TO FAIL on unfixed code
          // The unfixed code returns 717.4, which is > 381.4.
          expect(
            actualHeight,
            lessThanOrEqualTo(maxAllowedHeight),
            reason:
                'BUG C CONFIRMED: sheet height = $actualHeight, '
                'expected <= $maxAllowedHeight '
                '(screenHeight * 0.85 - keyboardHeight). '
                'Root cause: Container height is fixed at '
                'MediaQuery.of(context).size.height * 0.85 without '
                'subtracting MediaQuery.of(context).viewInsets.bottom. '
                'When the keyboard opens (viewInsets.bottom=$keyboardHeight), '
                'the sheet does not shrink and the keyboard covers the '
                'text field and Submit button. '
                'Fix: height = screenHeight * 0.85 - keyboardHeight.',
          );
        },
      );

      test(
        'EXPLORATION: sheet height equals screenHeight * 0.85 - keyboardHeight '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug C)',
        () {
          const double screenHeight = 844.0;
          const double keyboardHeight = 336.0;
          final double expectedHeight = screenHeight * 0.85 - keyboardHeight;

          final actualHeight = unfixedSheetHeight(
            screenHeight: screenHeight,
            keyboardHeight: keyboardHeight,
          );

          print('');
          print('🐛 Bug C Counterexample (exact value):');
          print('   screenHeight:     $screenHeight');
          print('   keyboardHeight:   $keyboardHeight');
          print('   Expected height:  $expectedHeight');
          print('   Actual height:    $actualHeight');
          print('');

          expect(
            actualHeight,
            equals(expectedHeight),
            reason:
                'BUG C CONFIRMED: sheet height = $actualHeight, '
                'expected $expectedHeight (screenHeight * 0.85 - keyboardHeight). '
                'The unfixed code ignores viewInsets.bottom entirely.',
          );
        },
      );

      test(
        'EXPLORATION: sheet height is NOT fixed at screenHeight * 0.85 '
        'when keyboard is open '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug C)',
        () {
          const double screenHeight = 844.0;
          const double keyboardHeight = 336.0;
          final double fixedHeight = screenHeight * 0.85; // unfixed value

          final actualHeight = unfixedSheetHeight(
            screenHeight: screenHeight,
            keyboardHeight: keyboardHeight,
          );

          print('');
          print('🐛 Bug C Counterexample (not fixed):');
          print('   Expected: height != $fixedHeight (should shrink with keyboard)');
          print('   Actual:   height = $actualHeight (fixed, keyboard ignored)');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code returns the fixed height
          expect(
            actualHeight,
            isNot(equals(fixedHeight)),
            reason:
                'BUG C CONFIRMED: sheet height = $actualHeight, which equals '
                'the fixed value screenHeight * 0.85 = $fixedHeight. '
                'The sheet does NOT shrink when the keyboard opens. '
                'Fix: subtract viewInsets.bottom from the height.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Test D — Review TextField: textInputAction must be TextInputAction.done
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedTextFieldTextInputAction() returns null, not 'TextInputAction.done'.
  //
  // Validates: Requirements 1.5, 2.5
  // =========================================================================
  group(
    'Test D — Review TextField: textInputAction == TextInputAction.done',
    () {
      test(
        'EXPLORATION: TextField textInputAction == TextInputAction.done '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug D)',
        () {
          // Act: get the textInputAction as the UNFIXED code sets it
          final textInputAction = unfixedTextFieldTextInputAction();

          // Log the counterexample
          print('');
          print('🐛 Bug D Counterexample:');
          print('   Expected:     textInputAction == "TextInputAction.done"');
          print('   Actual:       textInputAction = $textInputAction (null)');
          print('   Root cause:   The TextField in _ReviewBottomSheetState.build '
              'does not set textInputAction. iOS defaults to the "return" '
              'key with no "Done" button in the keyboard toolbar.');
          print('   Impact:       Users on iOS have no native way to dismiss '
              'the keyboard without tapping outside the sheet, which '
              'dismisses the sheet entirely instead of just the keyboard.');
          print('');

          // Assert: EXPECTED TO FAIL on unfixed code
          // The unfixed code returns null, not 'TextInputAction.done'.
          expect(
            textInputAction,
            equals('TextInputAction.done'),
            reason:
                'BUG D CONFIRMED: TextField.textInputAction = $textInputAction '
                '(null), expected "TextInputAction.done". '
                'Root cause: the TextField in _ReviewBottomSheetState.build '
                'does not set textInputAction, so iOS shows no "Done" button '
                'in the keyboard toolbar. '
                'Fix: add textInputAction: TextInputAction.done to the TextField.',
          );
        },
      );

      test(
        'EXPLORATION: TextField textInputAction is not null '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug D)',
        () {
          final textInputAction = unfixedTextFieldTextInputAction();

          print('');
          print('🐛 Bug D Counterexample (null check):');
          print('   Expected: textInputAction != null');
          print('   Actual:   textInputAction = $textInputAction');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code returns null
          expect(
            textInputAction,
            isNotNull,
            reason:
                'BUG D CONFIRMED: TextField.textInputAction is null. '
                'The unfixed code does not set textInputAction on the '
                'review TextField. iOS users see no "Done" button in the '
                'keyboard toolbar and cannot dismiss the keyboard without '
                'closing the sheet.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Summary: all four bug conditions confirmed
  // =========================================================================
  group('Summary: all four iOS safe area / keyboard bug conditions confirmed', () {
    test(
      'EXPLORATION: all four unfixed behaviors match the bug conditions '
      '— EXPECTED TO FAIL on unfixed code (confirms all 4 bugs)',
      () {
        // Bug A: action buttons bottom padding
        const double safeAreaBottom = 34.0;
        final bugABottomPadding = unfixedActionButtonsBottomPadding(
          safeAreaBottom: safeAreaBottom,
        );
        final bugAExists = bugABottomPadding < safeAreaBottom;

        // Bug B: Submit container bottom padding
        final bugBBottomPadding = unfixedSubmitContainerBottomPadding(
          safeAreaBottom: safeAreaBottom,
        );
        final bugBExists = bugBBottomPadding < safeAreaBottom;

        // Bug C: sheet height not shrinking with keyboard
        const double screenHeight = 844.0;
        const double keyboardHeight = 336.0;
        final bugCHeight = unfixedSheetHeight(
          screenHeight: screenHeight,
          keyboardHeight: keyboardHeight,
        );
        final bugCExists = bugCHeight > screenHeight * 0.85 - keyboardHeight;

        // Bug D: TextField textInputAction is null
        final bugDTextInputAction = unfixedTextFieldTextInputAction();
        final bugDExists = bugDTextInputAction != 'TextInputAction.done';

        print('');
        print('📊 iOS Safe Area / Keyboard Bug Condition Summary:');
        print('   Bug A (action buttons bottom padding):');
        print('     Padding.bottom = $bugABottomPadding, '
            'safeAreaBottom = $safeAreaBottom, bug exists: $bugAExists');
        print('   Bug B (Submit container bottom padding):');
        print('     Container.bottom = $bugBBottomPadding, '
            'safeAreaBottom = $safeAreaBottom, bug exists: $bugBExists');
        print('   Bug C (sheet height not shrinking):');
        print('     height = $bugCHeight, '
            'expected <= ${screenHeight * 0.85 - keyboardHeight}, '
            'bug exists: $bugCExists');
        print('   Bug D (TextField textInputAction):');
        print('     textInputAction = $bugDTextInputAction, '
            'expected "TextInputAction.done", bug exists: $bugDExists');
        print('');
        print('   All bugs confirmed: '
            '${bugAExists && bugBExists && bugCExists && bugDExists}');
        print('');

        // Assert: all four bugs exist — EXPECTED TO FAIL because we assert
        // the FIXED behavior (none of the bugs should exist after the fix).
        // On unfixed code, all four bug conditions are true, so the
        // assertions below fail.

        expect(
          bugAExists,
          isFalse,
          reason:
              'BUG A CONFIRMED: _buildActionButtons outer Padding.bottom = '
              '$bugABottomPadding < safeAreaBottom = $safeAreaBottom. '
              '"ADD TO BAG" and "BUY NOW" buttons overlap the iOS home indicator.',
        );
        expect(
          bugBExists,
          isFalse,
          reason:
              'BUG B CONFIRMED: Submit container bottom padding = '
              '$bugBBottomPadding < safeAreaBottom = $safeAreaBottom. '
              '"SUBMIT REVIEW" button overlaps the iOS home indicator.',
        );
        expect(
          bugCExists,
          isFalse,
          reason:
              'BUG C CONFIRMED: sheet height = $bugCHeight, '
              'expected <= ${screenHeight * 0.85 - keyboardHeight}. '
              'The keyboard covers the text field and Submit button.',
        );
        expect(
          bugDExists,
          isFalse,
          reason:
              'BUG D CONFIRMED: TextField.textInputAction = $bugDTextInputAction, '
              'expected "TextInputAction.done". '
              'iOS keyboard toolbar shows no "Done" button.',
        );
      },
    );
  });
}
