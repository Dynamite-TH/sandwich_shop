You are an expert Flutter developer and you will implement "cart item modification" features for a sandwich shop app. The app has two pages: an order screen (select sandwiches and add to cart) and a cart screen (view items + total). The project is in Flutter; you may choose a reasonable state management approach (Provider, Riverpod, Bloc, or setState) — state your choice and keep changes minimal and localized.

Goal
- Let users modify items in their cart in several common ways (change quantity, remove items, edit customizations). Implement UI, state changes, persistence, and tests. Update totals and UI immediately and correctly.

For each feature below, implement the described UI, data changes, and edge-case behavior. Provide code snippets, unit and widget tests, and a short migration plan for existing cart model/state.

Features and expected behavior

1) Change quantity (increment / decrement buttons)
- Description: Each cart row shows plus (+) and minus (−) buttons to increment or decrement quantity.
- Behavior:
  - Tap +: quantity increases by 1; cart item total and cart grand total update instantly.
  - Tap −: quantity decreases by 1; if quantity becomes 0, trigger the "Remove item" flow (see #2) or optionally disallow going below 1 — specify which you implement.
  - Disable the + button if a configurable max quantity is reached (e.g., 99).
  - Prevent negative quantities.
  - Persist change to app state/storage.
- Acceptance criteria:
  - Visually update quantity and price immediately.
  - No UI flicker; state is consistent across order and cart screens.

2) Set quantity via input (manual edit)
- Description: Allow long-press or a numeric input modal to set an exact quantity.
- Behavior:
  - Open a modal with a numeric input; validate integer >= 1 and <= max.
  - On confirm, update quantity and totals.
  - Cancel preserves previous quantity.
- Acceptance criteria:
  - Validation feedback shown for invalid input.
  - Updated state persisted.

3) Remove item
- Description: Users can remove an item fully from the cart via a trash icon or swipe-to-delete.
- Behavior:
  - Provide both a trash icon and swipe-to-delete on the cart row.
  - After removal, show an Undo snackbar for a short period (e.g., 5s). If undone, restore item exactly as before (quantity, customizations).
  - If user confirms removal in a modal (if implemented), remove and update totals.
- Acceptance criteria:
  - Item disappears immediately; totals update.
  - Undo restores item and totals.

4) Edit item customizations (toppings, size, extras)
- Description: Some sandwiches have customizable options. Allow editing an item in the cart to change its configuration.
- Behavior:
  - Tap an "Edit" button on the cart row to open the same customization screen used when adding to cart, pre-filled with the item’s current options.
  - If editing results in a configuration identical to another cart row, merge them by summing quantities and removing the duplicate row; update totals accordingly.
  - If price changes due to customization, reflect new per-item and total prices.
- Acceptance criteria:
  - After saving edits, the cart shows updated item(s) and totals.
  - Merges happen deterministically (match by item id + serialized options).

5) Save for later (optional)
- Description: Allow moving items from cart to a "Saved for later" list.
- Behavior:
  - Provide a "Save for later" action on the cart row.
  - Move item out of cart into a saved list persisted in app state/storage.
  - Allow moving back from saved list to cart.
- Acceptance criteria:
  - Totals update when items are moved.
  - Saved list persists across app restarts if app already supports persistence.

Non-functional requirements
- State updates must be atomic and thread-safe (no duplicated updates).
- Keep UI responsive; avoid blocking the main thread.
- Persist changes to the same storage the app already uses for cart (if none, use local in-memory state and SharedPreferences / Hive for persistence; state which you used).
- Provide clear unit tests and widget tests that assert quantities, removal, undo, edit+merge, and persistent behavior.

Implementation deliverables (what to ask for from the LLM)
- A short plan of changed files and where to put logic (e.g., cart model, cart provider, cart screen, cart row widget, customization screen).
- Concrete Flutter code snippets for:
  - Cart item row widget with +/− buttons, trash, edit, swipe-to-delete handling, and undo snackbar.
  - Modal numeric input for exact quantity.
  - Edit flow integration calling the existing customization screen and merging logic.
  - State management code (Provider/ChangeNotifier or chosen approach) that exposes add/update/remove/undo/merge APIs and persists changes.
- Unit tests and widget tests (examples) for each acceptance criterion. Use flutter_test and mock persistence if needed.
- A brief migration checklist to integrate into the current project:
  - Files to modify or add.
  - Public APIs to call from the order screen if any change required.
  - How to run tests and manual QA steps to validate.

Example user stories / flows to test (include in tests or QA)
- Increment quantity from 1 to 2; total increases by item price.
- Decrement quantity from 2 to 1; total decreases accordingly.
- Decrement quantity from 1 triggers remove flow and shows undo; undo returns item to quantity 1.
- Manual set quantity to 5 via numeric input; total updates.
- Edit customization to change price; cart shows updated per-item price and grand total.
- Edit customization such that it matches another row → rows merge and quantities summed.
- Remove item and verify persistence on app restart (if persistence implemented).

Extras (optional)
- Accessibility: Buttons must have semantics/labels for screen readers.
- Animations: animate item removal and insertion.
- Performance: Ensure list uses ListView.builder and avoids unnecessary rebuilds.

Tone and constraints for generated code
- Keep changes minimal, idiomatic Flutter, and easy to review.
- Provide comments explaining complex parts.
- Provide a small test suite demonstrating behavior; tests should be runnable with flutter test.

End of prompt.