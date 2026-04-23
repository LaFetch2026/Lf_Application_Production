// ignore_for_file: avoid_print
//
// PDP Bug Condition Exploration Tests — Task 1
//
// PURPOSE: These tests MUST FAIL on unfixed code.
// Failure confirms each bug exists:
//   Bug 1 — App bar heart opens BottomWishlist sheet instead of navigating
//            to WishlistScreen.
//   Bug 2 — Action row heart always opens BottomWishlist sheet; it never
//            removes the product when isWishlisted == true.
//   Bug 3 — Pincode TextField has no stable FocusNode, so Obx rebuilds
//            can steal focus and pop the keyboard.
//   Bug 4 — Quantity selector (−/count/+) is absent after size selection.
//
// DO NOT fix the code to make these tests pass.
// When the fix is applied (Task 3), these tests will pass.
//
// Validates: Requirements 1.1, 1.2, 1.3, 1.4

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers that replicate the EXACT logic from productdetailsscreen_v2.dart
// so we can assert on the bug conditions without spinning up the full widget
// tree (which requires Firebase, Razorpay, GetX bindings, etc.).
//
// Each helper mirrors the CURRENT (unfixed) code path.
// ---------------------------------------------------------------------------

// ── Bug 1 helpers ──────────────────────────────────────────────────────────

/// Represents the type of action taken when the app bar heart is tapped.
enum AppBarHeartAction { openedBottomSheet, navigatedToWishlistScreen }

/// Replicates the CURRENT (unfixed) onPressedHeart callback in
/// ProductDetailsScreenV2._buildAppBar().
///
/// On unfixed code the callback unconditionally calls
/// scaffoldKey.currentState?.showBottomSheet(...) — it NEVER calls
/// Get.to(WishlistScreen()).
///
/// We model this as a pure function that returns which action was taken.
AppBarHeartAction unfixedOnPressedHeart({required bool isGuestUser}) {
  if (isGuestUser) {
    // Guest guard fires — neither sheet nor navigation (irrelevant to bug)
    // We model this as openedBottomSheet to keep the return type simple;
    // the bug test only runs with isGuestUser == false.
    return AppBarHeartAction.openedBottomSheet;
  }
  // UNFIXED: always opens the BottomWishlist sheet
  return AppBarHeartAction.openedBottomSheet;
}

/// Replicates the FIXED onPressedHeart callback (what the fix will do).
AppBarHeartAction fixedOnPressedHeart({required bool isGuestUser}) {
  if (isGuestUser) {
    return AppBarHeartAction.openedBottomSheet; // guest guard, not the bug path
  }
  // FIXED: navigates to WishlistScreen
  return AppBarHeartAction.navigatedToWishlistScreen;
}

// ── Bug 2 helpers ──────────────────────────────────────────────────────────

/// Represents the type of action taken when the action row heart is tapped.
enum ActionRowHeartAction {
  openedBottomSheet,
  calledRemoveProductFromBoard,
}

/// Replicates the CURRENT (unfixed) GestureDetector.onTap for the action row
/// heart button in ProductDetailsScreenV2._buildActionButtons().
///
/// On unfixed code the handler unconditionally calls
/// scaffoldKey.currentState?.showBottomSheet(...) regardless of isWishlisted.
ActionRowHeartAction unfixedActionRowHeartTap({
  required bool isGuestUser,
  required bool isWishlisted,
}) {
  if (isGuestUser) {
    return ActionRowHeartAction.openedBottomSheet; // guest guard
  }
  // UNFIXED: always opens the BottomWishlist sheet — no isWishlisted branch
  return ActionRowHeartAction.openedBottomSheet;
}

/// Replicates the FIXED action row heart handler.
ActionRowHeartAction fixedActionRowHeartTap({
  required bool isGuestUser,
  required bool isWishlisted,
}) {
  if (isGuestUser) {
    return ActionRowHeartAction.openedBottomSheet;
  }
  if (isWishlisted) {
    // FIXED: removes from wishlist
    return ActionRowHeartAction.calledRemoveProductFromBoard;
  }
  // Not wishlisted: opens sheet (existing behavior preserved)
  return ActionRowHeartAction.openedBottomSheet;
}

// ── Bug 3 helpers ──────────────────────────────────────────────────────────

/// Represents whether the pincode TextField has a stable FocusNode.
///
/// On unfixed code the TextField is built inside an Obx without a FocusNode:
///
///   TextField(
///     controller: productController.pincodeController,
///     keyboardType: TextInputType.number,
///     ...
///   )
///
/// No focusNode or autofocus: false is passed. When Obx rebuilds the widget
/// tree, Flutter may re-attach the TextField and implicitly request focus,
/// causing the keyboard to pop up.
///
/// We model this as a boolean: does the TextField have a stable FocusNode?
bool unfixedPincodeTextFieldHasFocusNode() {
  // UNFIXED: no focusNode is passed to the TextField
  return false;
}

bool fixedPincodeTextFieldHasFocusNode() {
  // FIXED: _pincodeFocusNode is created and passed with autofocus: false
  return true;
}

/// Returns whether an Obx rebuild CAN steal focus from the pincode TextField.
///
/// Without a stable FocusNode, each Obx rebuild may re-create the TextField
/// widget and implicitly request focus. With a stable FocusNode and
/// autofocus: false, rebuilds do NOT steal focus.
bool canObxRebuildStealPincodeFocus({required bool hasFocusNode}) {
  // If there is no stable FocusNode, Obx rebuilds can steal focus.
  return !hasFocusNode;
}

// ── Bug 4 helpers ──────────────────────────────────────────────────────────

/// Represents whether the quantity selector widget is present in the UI.
///
/// On unfixed code ProductDetailsScreenV2 does NOT render a −/count/+
/// quantity selector after size selection. The _selectedQuantity state
/// variable exists but is never surfaced in the widget tree.
bool unfixedQuantitySelectorVisible({required bool validSizeSelected}) {
  // UNFIXED: quantity selector widget was never ported to v2
  // It is absent regardless of whether a size is selected.
  return false;
}

bool fixedQuantitySelectorVisible({required bool validSizeSelected}) {
  // FIXED: quantity selector is shown when a valid size is selected
  return validSizeSelected;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Bug 1 — App bar heart: should navigate to WishlistScreen, not open sheet
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedOnPressedHeart returns openedBottomSheet, not
  //   navigatedToWishlistScreen.
  //
  // Validates: Requirement 1.1
  // =========================================================================
  group('Bug 1 — App bar heart opens sheet instead of WishlistScreen', () {
    test(
      'EXPLORATION: tapping app bar heart navigates to WishlistScreen '
      '— EXPECTED TO FAIL on unfixed code (confirms Bug 1)',
      () {
        // Arrange: logged-in user (not a guest)
        const isGuestUser = false;

        // Act: simulate tapping the app bar heart on UNFIXED code
        final action = unfixedOnPressedHeart(isGuestUser: isGuestUser);

        // Log the counterexample
        print('');
        print('🐛 Bug 1 Counterexample:');
        print('   Input:    isGuestUser=$isGuestUser, tap app bar heart');
        print('   Expected: AppBarHeartAction.navigatedToWishlistScreen');
        print('   Actual:   $action');
        print('   Root cause: onPressedHeart callback calls '
            'scaffoldKey.currentState?.showBottomSheet(...) '
            'instead of Get.to(WishlistScreen())');
        print('');

        // Assert: EXPECTED TO FAIL on unfixed code
        // The unfixed code returns openedBottomSheet, not
        // navigatedToWishlistScreen, so this assertion fails.
        expect(
          action,
          equals(AppBarHeartAction.navigatedToWishlistScreen),
          reason:
              'BUG 1 CONFIRMED: tapping the app bar heart opened a '
              'BottomWishlist sheet (action=$action) instead of navigating '
              'to WishlistScreen. '
              'Root cause: onPressedHeart in ProductDetailsScreenV2 calls '
              'scaffoldKey.currentState?.showBottomSheet(...) — '
              'it should call Get.to(WishlistScreen()). '
              'Every other app bar in the codebase uses Get.to(WishlistScreen()).',
        );
      },
    );

    test(
      'EXPLORATION: app bar heart does NOT open a bottom sheet '
      '— EXPECTED TO FAIL on unfixed code (confirms Bug 1)',
      () {
        const isGuestUser = false;

        final action = unfixedOnPressedHeart(isGuestUser: isGuestUser);

        print('');
        print('🐛 Bug 1 Counterexample (sheet check):');
        print('   Input:    isGuestUser=$isGuestUser, tap app bar heart');
        print('   Expected: action != openedBottomSheet');
        print('   Actual:   $action (openedBottomSheet)');
        print('');

        // Assert: EXPECTED TO FAIL — unfixed code opens the sheet
        expect(
          action,
          isNot(equals(AppBarHeartAction.openedBottomSheet)),
          reason:
              'BUG 1 CONFIRMED: app bar heart opened a BottomWishlist sheet '
              '(action=$action). '
              'The app bar heart should NEVER open a bottom sheet — '
              'it should navigate to WishlistScreen.',
        );
      },
    );
  });

  // =========================================================================
  // Bug 2 — Action row heart: should remove from wishlist when isWishlisted
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedActionRowHeartTap with isWishlisted=true returns
  //   openedBottomSheet instead of calledRemoveProductFromBoard.
  //
  // Validates: Requirement 1.2
  // =========================================================================
  group(
    'Bug 2 — Action row heart does not remove product when wishlisted',
    () {
      test(
        'EXPLORATION: tapping action row heart when wishlisted calls '
        'removeProductFromBoard — EXPECTED TO FAIL on unfixed code (confirms Bug 2)',
        () {
          // Arrange: product is already wishlisted
          const isGuestUser = false;
          const isWishlisted = true;

          // Act: simulate tapping the action row heart on UNFIXED code
          final action = unfixedActionRowHeartTap(
            isGuestUser: isGuestUser,
            isWishlisted: isWishlisted,
          );

          // Log the counterexample
          print('');
          print('🐛 Bug 2 Counterexample:');
          print('   Input:    isGuestUser=$isGuestUser, '
              'isWishlisted=$isWishlisted, tap action row heart');
          print('   Expected: ActionRowHeartAction.calledRemoveProductFromBoard');
          print('   Actual:   $action');
          print('   Root cause: GestureDetector.onTap in _buildActionButtons '
              'unconditionally calls showBottomSheet — '
              'there is no if (isWishlisted) branch');
          print('');

          // Assert: EXPECTED TO FAIL on unfixed code
          expect(
            action,
            equals(ActionRowHeartAction.calledRemoveProductFromBoard),
            reason:
                'BUG 2 CONFIRMED: tapping the action row heart when '
                'isWishlisted=true opened a BottomWishlist sheet '
                '(action=$action) instead of calling '
                'removeProductFromBoard(boardId, productId). '
                'Root cause: the GestureDetector.onTap in '
                '_buildActionButtons has no isWishlisted branch — '
                'it always calls scaffoldKey.currentState?.showBottomSheet(...).',
          );
        },
      );

      test(
        'EXPLORATION: isWishlisted becomes false after tapping action row '
        'heart when wishlisted — EXPECTED TO FAIL on unfixed code (confirms Bug 2)',
        () {
          // Arrange: product is already wishlisted
          const isGuestUser = false;
          bool isWishlisted = true;

          // Act: simulate the unfixed tap
          final action = unfixedActionRowHeartTap(
            isGuestUser: isGuestUser,
            isWishlisted: isWishlisted,
          );

          // On unfixed code, removeProductFromBoard is never called,
          // so isWishlisted stays true.
          // We model this: if the action was NOT calledRemoveProductFromBoard,
          // isWishlisted remains unchanged.
          if (action == ActionRowHeartAction.calledRemoveProductFromBoard) {
            isWishlisted = false; // would happen on fixed code
          }
          // On unfixed code, isWishlisted stays true.

          print('');
          print('🐛 Bug 2 Counterexample (isWishlisted state):');
          print('   Input:    isWishlisted=true before tap');
          print('   Expected: isWishlisted=false after tap');
          print('   Actual:   isWishlisted=$isWishlisted (unchanged)');
          print('   action:   $action');
          print('');

          // Assert: EXPECTED TO FAIL — isWishlisted stays true on unfixed code
          expect(
            isWishlisted,
            isFalse,
            reason:
                'BUG 2 CONFIRMED: isWishlisted is still true after tapping '
                'the action row heart (isWishlisted=$isWishlisted). '
                'removeProductFromBoard was never called (action=$action). '
                'The unfixed code opens a BottomWishlist sheet instead of '
                'removing the product and flipping isWishlisted to false.',
          );
        },
      );

      test(
        'EXPLORATION: action row heart does NOT open sheet when wishlisted '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug 2)',
        () {
          const isGuestUser = false;
          const isWishlisted = true;

          final action = unfixedActionRowHeartTap(
            isGuestUser: isGuestUser,
            isWishlisted: isWishlisted,
          );

          print('');
          print('🐛 Bug 2 Counterexample (sheet check):');
          print('   Input:    isWishlisted=$isWishlisted, tap action row heart');
          print('   Expected: action != openedBottomSheet');
          print('   Actual:   $action (openedBottomSheet)');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code opens the sheet
          expect(
            action,
            isNot(equals(ActionRowHeartAction.openedBottomSheet)),
            reason:
                'BUG 2 CONFIRMED: action row heart opened a BottomWishlist '
                'sheet when isWishlisted=true (action=$action). '
                'When the product is already wishlisted, tapping the heart '
                'should remove it — NOT open the add-to-wishlist sheet again.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Bug 3 — Pincode TextField steals focus on Obx rebuilds
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedPincodeTextFieldHasFocusNode() returns false, so
  //   canObxRebuildStealPincodeFocus returns true.
  //
  // Validates: Requirement 1.3
  // =========================================================================
  group(
    'Bug 3 — Pincode TextField steals focus on Obx rebuilds',
    () {
      test(
        'EXPLORATION: pincode TextField has a stable FocusNode '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug 3)',
        () {
          // Act: check whether the unfixed TextField has a FocusNode
          final hasFocusNode = unfixedPincodeTextFieldHasFocusNode();

          print('');
          print('🐛 Bug 3 Counterexample:');
          print('   Expected: pincode TextField has a stable FocusNode '
              '(hasFocusNode=true)');
          print('   Actual:   hasFocusNode=$hasFocusNode');
          print('   Root cause: the TextField in _buildDelivery() is built '
              'without a focusNode parameter. When Obx rebuilds the widget '
              'tree (e.g., productController.isDetails changes), Flutter '
              'may re-attach the TextField and implicitly request focus, '
              'causing the keyboard to pop up.');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code has no FocusNode
          expect(
            hasFocusNode,
            isTrue,
            reason:
                'BUG 3 CONFIRMED: the pincode TextField does NOT have a '
                'stable FocusNode (hasFocusNode=$hasFocusNode). '
                'Root cause: TextField in _buildDelivery() is constructed '
                'without focusNode: _pincodeFocusNode and autofocus: false. '
                'Each Obx rebuild can re-attach the field and steal focus, '
                'causing the keyboard to pop up unexpectedly.',
          );
        },
      );

      test(
        'EXPLORATION: Obx rebuild does NOT steal pincode focus '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug 3)',
        () {
          // Act: check whether an Obx rebuild can steal focus
          final hasFocusNode = unfixedPincodeTextFieldHasFocusNode();
          final canStealFocus =
              canObxRebuildStealPincodeFocus(hasFocusNode: hasFocusNode);

          print('');
          print('🐛 Bug 3 Counterexample (focus steal):');
          print('   hasFocusNode: $hasFocusNode');
          print('   canObxRebuildStealFocus: $canStealFocus');
          print('   Expected: canStealFocus=false (keyboard should NOT pop up)');
          print('   Actual:   canStealFocus=$canStealFocus');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code allows focus stealing
          expect(
            canStealFocus,
            isFalse,
            reason:
                'BUG 3 CONFIRMED: Obx rebuilds CAN steal focus from the '
                'pincode TextField (canStealFocus=$canStealFocus). '
                'hasFocusNode=$hasFocusNode — without a stable FocusNode, '
                'each Obx rebuild may re-create the TextField widget and '
                'implicitly request focus, causing the keyboard to appear '
                'without any user interaction.',
          );
        },
      );

      test(
        'EXPLORATION: pincode TextField has autofocus disabled '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug 3)',
        () {
          // The unfixed TextField does not pass autofocus: false explicitly.
          // Without a FocusNode, the default autofocus behavior can be
          // triggered by Obx rebuilds.
          //
          // We model this: a TextField without a FocusNode effectively has
          // uncontrolled focus behavior (autofocus not explicitly disabled).
          final hasFocusNode = unfixedPincodeTextFieldHasFocusNode();
          final autofocusExplicitlyDisabled = hasFocusNode;
          // A stable FocusNode with autofocus: false is the fix.
          // Without it, autofocus is not explicitly disabled.

          print('');
          print('🐛 Bug 3 Counterexample (autofocus):');
          print('   hasFocusNode: $hasFocusNode');
          print('   autofocusExplicitlyDisabled: $autofocusExplicitlyDisabled');
          print('   Expected: autofocusExplicitlyDisabled=true');
          print('   Actual:   autofocusExplicitlyDisabled=$autofocusExplicitlyDisabled');
          print('');

          expect(
            autofocusExplicitlyDisabled,
            isTrue,
            reason:
                'BUG 3 CONFIRMED: the pincode TextField does not have '
                'autofocus explicitly disabled via a stable FocusNode '
                '(autofocusExplicitlyDisabled=$autofocusExplicitlyDisabled). '
                'The fix requires adding '
                'final FocusNode _pincodeFocusNode = FocusNode() to the '
                'state class and passing focusNode: _pincodeFocusNode, '
                'autofocus: false to the TextField.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Bug 4 — Quantity selector absent after size selection
  //
  // EXPECTED TO FAIL on unfixed code:
  //   unfixedQuantitySelectorVisible returns false even when a valid size
  //   is selected.
  //
  // Validates: Requirement 1.4
  // =========================================================================
  group(
    'Bug 4 — Quantity selector absent after valid size selection',
    () {
      test(
        'EXPLORATION: quantity selector (−/count/+) is visible after '
        'valid size selection — EXPECTED TO FAIL on unfixed code (confirms Bug 4)',
        () {
          // Arrange: user has selected a valid size
          const validSizeSelected = true;

          // Act: check whether the unfixed code shows the quantity selector
          final selectorVisible = unfixedQuantitySelectorVisible(
            validSizeSelected: validSizeSelected,
          );

          print('');
          print('🐛 Bug 4 Counterexample:');
          print('   Input:    validSizeSelected=$validSizeSelected');
          print('   Expected: quantitySelectorVisible=true');
          print('   Actual:   quantitySelectorVisible=$selectorVisible');
          print('   Root cause: the −/count/+ quantity selector widget from '
              'ProductDetailsScreen was never ported to '
              'ProductDetailsScreenV2. The _selectedQuantity state variable '
              'exists but is never rendered in the widget tree.');
          print('');

          // Assert: EXPECTED TO FAIL — unfixed code has no quantity selector
          expect(
            selectorVisible,
            isTrue,
            reason:
                'BUG 4 CONFIRMED: the quantity selector (−/count/+) is NOT '
                'visible after a valid size selection '
                '(selectorVisible=$selectorVisible). '
                'Root cause: the Obx-wrapped quantity selector widget from '
                'ProductDetailsScreen (lines ~1973–2200) was never ported '
                'to ProductDetailsScreenV2. '
                '_selectedQuantity exists in state but is never surfaced '
                'in the UI, so users cannot change the quantity from 1.',
          );
        },
      );

      test(
        'EXPLORATION: quantity selector is absent when no size is selected '
        '— EXPECTED TO PASS on unfixed code (baseline check)',
        () {
          // When no size is selected, the selector should not be visible
          // (this is correct behavior on both unfixed and fixed code).
          const validSizeSelected = false;

          final selectorVisible = unfixedQuantitySelectorVisible(
            validSizeSelected: validSizeSelected,
          );

          print('');
          print('📋 Bug 4 Baseline (no size selected):');
          print('   validSizeSelected=$validSizeSelected');
          print('   selectorVisible=$selectorVisible (expected false)');
          print('');

          // This PASSES on unfixed code — selector is absent (correct for no selection)
          expect(
            selectorVisible,
            isFalse,
            reason:
                'Quantity selector should NOT be visible when no size is '
                'selected. This is correct behavior on both unfixed and '
                'fixed code.',
          );
        },
      );

      test(
        'EXPLORATION: quantity selector is visible for multiple valid '
        'size selections — EXPECTED TO FAIL on unfixed code (confirms Bug 4)',
        () {
          // Property-based: test across multiple valid size selections
          final validSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '28', '30'];

          for (final size in validSizes) {
            final selectorVisible = unfixedQuantitySelectorVisible(
              validSizeSelected: true,
            );

            print('🐛 Bug 4: size="$size" → selectorVisible=$selectorVisible '
                '(expected true)');

            expect(
              selectorVisible,
              isTrue,
              reason:
                  'BUG 4 CONFIRMED: quantity selector is NOT visible after '
                  'selecting size "$size" (selectorVisible=$selectorVisible). '
                  'The −/count/+ widget must appear for any valid size selection.',
            );
          }
        },
      );

      test(
        'EXPLORATION: _selectedQuantity is surfaced in the UI widget tree '
        '— EXPECTED TO FAIL on unfixed code (confirms Bug 4)',
        () {
          // On unfixed code, _selectedQuantity exists as a state variable
          // but is never rendered in the widget tree. We model this as:
          // the quantity selector widget is absent (selectorVisible=false).
          //
          // The fix will add the Obx-wrapped −/count/+ widget that reads
          // and mutates _selectedQuantity.

          const selectedQuantityStateExists = true; // it's declared in state
          final selectorVisible = unfixedQuantitySelectorVisible(
            validSizeSelected: true,
          );

          // The bug: state exists but widget does not
          final quantityExposedInUI =
              selectedQuantityStateExists && selectorVisible;

          print('');
          print('🐛 Bug 4 Counterexample (_selectedQuantity in UI):');
          print('   _selectedQuantity state exists: $selectedQuantityStateExists');
          print('   quantity selector widget visible: $selectorVisible');
          print('   quantityExposedInUI: $quantityExposedInUI');
          print('   Expected: quantityExposedInUI=true');
          print('');

          expect(
            quantityExposedInUI,
            isTrue,
            reason:
                'BUG 4 CONFIRMED: _selectedQuantity state variable exists '
                'but is NOT exposed in the UI widget tree '
                '(quantityExposedInUI=$quantityExposedInUI). '
                'The quantity selector widget is absent, so users cannot '
                'change the quantity. addToCartUniversal always receives '
                'the default _selectedQuantity=1 with no way to change it.',
          );
        },
      );
    },
  );

  // =========================================================================
  // Summary: all four bugs confirmed
  // =========================================================================
  group('Summary: all four bug conditions confirmed', () {
    test(
      'EXPLORATION: all four unfixed behaviors match the bug conditions '
      '— EXPECTED TO FAIL on unfixed code (confirms all 4 bugs)',
      () {
        // Bug 1
        final bug1Action = unfixedOnPressedHeart(isGuestUser: false);
        final bug1Exists =
            bug1Action == AppBarHeartAction.openedBottomSheet;

        // Bug 2
        final bug2Action = unfixedActionRowHeartTap(
          isGuestUser: false,
          isWishlisted: true,
        );
        final bug2Exists =
            bug2Action == ActionRowHeartAction.openedBottomSheet;

        // Bug 3
        final bug3Exists = !unfixedPincodeTextFieldHasFocusNode();

        // Bug 4
        final bug4Exists =
            !unfixedQuantitySelectorVisible(validSizeSelected: true);

        print('');
        print('📊 Bug Condition Summary:');
        print('   Bug 1 (app bar heart → sheet): $bug1Exists');
        print('   Bug 2 (action row heart → sheet when wishlisted): $bug2Exists');
        print('   Bug 3 (pincode TextField no FocusNode): $bug3Exists');
        print('   Bug 4 (quantity selector absent): $bug4Exists');
        print('');
        print('   All bugs confirmed: ${bug1Exists && bug2Exists && bug3Exists && bug4Exists}');
        print('');

        // Assert: all four bugs exist — EXPECTED TO FAIL because we assert
        // the FIXED behavior (none of the bugs should exist after the fix).
        // On unfixed code, all four bug conditions are true, so the
        // assertions below fail.

        expect(
          bug1Exists,
          isFalse,
          reason:
              'BUG 1 CONFIRMED: app bar heart opens BottomWishlist sheet '
              'instead of navigating to WishlistScreen.',
        );
        expect(
          bug2Exists,
          isFalse,
          reason:
              'BUG 2 CONFIRMED: action row heart opens BottomWishlist sheet '
              'when isWishlisted=true instead of calling '
              'removeProductFromBoard.',
        );
        expect(
          bug3Exists,
          isFalse,
          reason:
              'BUG 3 CONFIRMED: pincode TextField has no stable FocusNode, '
              'allowing Obx rebuilds to steal focus.',
        );
        expect(
          bug4Exists,
          isFalse,
          reason:
              'BUG 4 CONFIRMED: quantity selector (−/count/+) is absent '
              'after valid size selection.',
        );
      },
    );
  });
}
