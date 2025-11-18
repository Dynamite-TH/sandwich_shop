# Requirements Document — Sandwich Shop: Cart Item Modification & Account/Auth/Profile Management

Overview
- Purpose: Add robust cart item modification features and basic account authentication/profile management to the existing Sandwich Shop Flutter app so users can create accounts, sign in, view/edit their profile, and modify cart items (quantity, customizations, remove, save-for-later) reliably with persistence and test coverage.
- Scope: Two feature groups:
  1. Cart Item Modification (quantity controls, manual quantity input, remove/undo, edit customizations, save-for-later)
  2. Authentication & Profile Management (sign up, sign in, view/edit profile, sign out)
- State management choice: Provider + ChangeNotifier for minimal intrusion and easy review.
- Persistence: flutter_secure_storage for auth tokens; SharedPreferences (or Hive if preferred) for cart and saved-for-later persistence. State must persist across restarts.

---

## 1. Cart Item Modification

### 1.1 Feature Description
Allow users to change the contents of their cart in common ways:
- Increment/decrement quantity with buttons.
- Manually set exact quantity via numeric modal.
- Remove items via trash icon or swipe-to-delete with Undo.
- Edit per-item customizations using the existing customization UI; merge identical items.
- Optionally save items for later (persisted list separate from cart).

### 1.2 Subtasks
1. Add/modify Cart model to include:
   - id, productId, name, unitPrice, quantity, options (serialized map), subtotal getter.
2. Implement CartProvider (ChangeNotifier) with APIs:
   - addItem(cartItem), updateQuantity(cartItemId, qty), setQuantity(cartItemId, qty), removeItem(cartItemId), undoRemove(), editItem(cartItemId, newOptions), saveForLater(cartItemId), moveToCart(savedItemId), persist()/load().
3. Cart UI changes:
   - CartRow widget: + / − buttons, long-press or tap-quantity to open numeric modal, Edit button, Trash icon, Save-for-later action, accessibility labels.
   - Enable swipe-to-delete with Dismissible and confirm/undo behavior.
4. Numeric input modal: validate integer 1..max (configurable, default 99).
5. Edit flow: open existing customization route, pre-fill options, on save call editItem; if identical item exists merge quantities.
6. Persistence: save cart and saved-for-later lists to SharedPreferences (JSON) on every change, load on startup.
7. Tests: unit tests for CartProvider methods and widget tests for CartRow behaviors (increment, decrement->remove+undo, manual set, edit+merge, persistence).

### 1.3 User Stories
- As a shopper I can tap + or − on a cart row to increase/decrease quantity so I can adjust order counts quickly.
- As a shopper I can long-press the quantity to type an exact number so I can set large quantities easily.
- As a shopper I can remove an item (trash icon or swipe) and get an option to Undo so I can recover mistakes.
- As a shopper I can edit an item’s customizations and have updated price/quantity reflect immediately; if identical item exists it merges.
- As a shopper I can Save for later and move items back to the cart; saved items persist across restarts.

### 1.4 Acceptance Criteria
- Increment: tapping + increases quantity by 1, updates item subtotal and cart grand total immediately; persisted.
- Decrement:
  - If implementing remove-on-zero: tapping − from 1 triggers remove flow with Undo (5s) and item removed immediately; Undo restores original item with same options & qty.
  - Prevent negative quantities; − disabled at 1 (if not removing on zero).
- Manual set: numeric modal enforces integer between 1 and max (default 99). Confirm updates quantity, totals, and persists. Cancel leaves quantity unchanged.
- Remove: trash icon and swipe-to-delete both remove item; show Undo snackbar for 5 seconds that restores item exactly.
- Edit customizations:
  - Edit opens customization screen prefilled.
  - Saving applies price change and updates subtotal and grand total.
  - If edited item equals another cart row (same productId + identical serialized options), merge rows by summing quantities and remove duplicate row.
- Save for later: moves item out of cart into saved list; totals update; saved list persists.
- UI responsiveness: no jank; ListView.builder used; no duplicate updates; atomic ChangeNotifier updates.
- Persistence: cart and saved lists persist and restore on app restart.

### 1.5 Edge Cases & Validation Rules
- Max quantity enforced (configurable, default 99). + disabled when reached.
- Manual input rejects non-integers, negative numbers, zeros (unless chosen behavior allows zero → remove).
- Undo must restore item in original list position and with same options.
- Merge determinism: equality by productId + canonical serialized options (stable key).
- Concurrent updates: operations queued on main isolate; provider must batch notifyListeners to avoid duplicate rebuilds.

### 1.6 Test Requirements
- Unit tests for CartProvider:
  - addItem, updateQuantity, setQuantity, removeItem, undoRemove, editItem (including merge), saveForLater, persistence load/save.
- Widget tests for CartRow:
  - Tap + increments, − decrements, long-press opens modal and sets qty, swipe-to-delete removes and shows Undo, Edit opens customization route and on return updates/merges.
- Persistence tests: simulate app restart (re-create provider, load data) and assert saved state.

---

## 2. Authentication & Profile Management
# Feature Requirements: Profile Screen (View + Edit)

## 1. Feature overview and purpose
Description
- Add a new "Profile" screen to the app where a user can view and edit their personal details: Name, Email, Phone.
- Purpose: allow users to enter or update basic contact information required for orders and future personalization. No authentication or persistence required initially — data is stored in-memory for the current app session.

Scope
- UI screen accessible from the Order screen via a link at the bottom.
- View mode (readonly) and Edit mode (editable fields).
- Client-side validation only.
- In-memory state only; no backend, no local storage.
- UX behaviors for Save, Cancel, and unsaved-change confirmation.

Out of scope
- Real authentication, server-side persistence, multi-account support, profile image upload.

---

## 2. User stories

User role: End user (anonymous or signed-in)
- As a user, I want to open a Profile screen from the Order screen so I can see my saved name, email, and phone for quick reference.
- As a user with no saved profile, I want the Profile screen to show empty fields and a prompt to complete my profile.
- As a user, I want to tap Edit to change my name, email, or phone so that order details use up-to-date contact information.
- As a user, I want validation errors shown inline if I enter an invalid email or phone so I can correct mistakes before saving.
- As a user, I want Save to persist changes for the current app session and return the screen to view mode with a confirmation message.
- As a user, I want Cancel to discard my unsaved edits and restore previously saved values.
- As a user, if I try to navigate back with unsaved changes, I want a confirmation prompt to avoid accidental loss of edits.

Edge-case user stories
- As a user, if I attempt to Save with an empty required Name field, I want an error preventing save.
- As a user, if I enter a phone with spaces or punctuation, I want the app to accept common phone formats (digits, +, spaces, -, parentheses) or show clear validation instructions if invalid.

---

## 3. Acceptance criteria (testable)

Navigation
- [AC-1] A "Profile" link/button is present at the bottom of the Order screen.
- [AC-2] Tapping the "Profile" link navigates to the Profile screen.

Profile screen layout & initial state
- [AC-3] Profile screen shows a header "Profile" and three fields: Name, Email, Phone.
- [AC-4] On first open with no prior in-memory data, fields are empty and view mode shows an "Edit" button and optional hint text ("Complete your profile").
- [AC-5] Fields are readonly in view mode; tapping "Edit" switches to edit mode.

Edit mode behavior
- [AC-6] Edit mode shows editable inputs for Name, Email, Phone and buttons "Save" and "Cancel".
- [AC-7] Focus is placed on the Name input when entering edit mode.

Validation rules
- [AC-8] Name is required; Save fails with inline error when Name is empty.
- [AC-9] Email must match a basic email regex (e.g., contains "@" and a domain); invalid email shows inline error and prevents Save.
- [AC-10] Phone is optional; if provided, it must contain only digits and allowed characters (+, spaces, -, parentheses); invalid phone shows inline error and prevents Save.

Saving and canceling
- [AC-11] On successful Save, the in-memory profile state is updated for the session, the screen returns to view mode, and a visible confirmation message "Profile saved" appears.
- [AC-12] Cancel discards unsaved edits and returns the screen to view mode showing last-saved values (or empty if none).
- [AC-13] No actual persistence to disk or network occurs after Save.

Unsaved changes and back navigation
- [AC-14] If the user has unsaved changes and attempts to navigate back (via header back or system back), a confirmation prompt "Discard changes?" with actions "Discard" and "Continue editing" is shown.
- [AC-15] Selecting "Discard" navigates back and discards edits; selecting "Continue editing" returns to edit mode and preserves edits.

Accessibility & UX
- [AC-16] All inputs have accessible labels.
- [AC-17] Inline errors are programmatically associated with inputs for screen readers.
- [AC-18] Buttons are reachable by keyboard/tab navigation (where applicable).

Testing
- [AC-19] Unit tests cover validation logic for email and phone formats.
- [AC-20] Navigation behavior from Order -> Profile and back is covered by an integration/UI test (or manual test steps documented).

Non-functional
- [AC-21] Profile screen renders within acceptable performance bounds (no perceptible delay on navigation).
- [AC-22] Behavior is consistent across supported platforms (Windows desktop dev environment).

---

## 4. Subtasks (implementation plan)

Subtask 1 — Design & spec
- Description: Create simple wireframe for Profile screen showing view/edit states and control placements; define exact validation patterns.
- Done when: wireframe image or small mock and regex definitions exist in the ticket.

Subtask 2 — Add navigation link on Order screen
- Description: Add a small "Profile" link/button at bottom of Order screen.
- Done when: tapping link opens Profile screen (AC-1, AC-2).

Subtask 3 — Implement Profile screen UI
- Description: Implement view mode (readonly) and edit mode UI with Name, Email, Phone, Edit/Save/Cancel controls and confirmation toast area.
- Done when: UI matches spec and header/labels present (AC-3..AC-7, AC-16).

Subtask 4 — Implement in-memory state
- Description: Add app-level in-memory state (singleton/service/context) to store profile data for the session.
- Done when: Save updates in-memory store and view mode displays saved values (AC-11, AC-13).

Subtask 5 — Implement validation logic
- Description: Add client-side validation for Name (required), Email (regex), Phone (allowed chars).
- Done when: invalid inputs block Save and show inline errors (AC-8..AC-10).

Subtask 6 — Unsaved changes handling
- Description: Detect dirty form state; intercept back navigation and show discard confirmation dialog when needed.
- Done when: confirmation dialog behavior works as specified (AC-14, AC-15).

Subtask 7 — Tests
- Description: Unit tests for validation functions and integration tests for navigation and save/cancel flows.
- Done when: tests exist and pass (AC-19, AC-20).

Subtask 8 — Accessibility & QA
- Description: Ensure labels, aria/error associations, keyboard focus handling; run manual test plan.
- Done when: accessibility checks pass and manual QA confirms behaviors (AC-16, AC-17, AC-18).

---

## 5. Example validation patterns (for implementers)
- Name: non-empty string; trim() length > 0.
- Email (basic): /^[^\s@]+@[^\s@]+\.[^\s@]+$/
- Phone (permissive): /^[0-9+\-\s()]*$/ (empty allowed)

---

## 6. Deliverables
- New Profile screen UI code.
- Navigation link from Order screen.
- In-memory profile state implementation.
- Validation logic and unit tests.
- Documentation of manual test steps for QA.

# Feature Requirements: Profile Screen (View + Edit)

## 1. Feature overview and purpose

Description
- Add a new "Profile" screen to the app where a user can view and edit their personal details: Name, Email, Phone.
- Purpose: allow users to enter or update basic contact information required for orders and future personalization. No authentication or persistence required initially — data is stored in-memory for the current app session.

Scope
- UI screen accessible from the Order screen via a link at the bottom.
- View mode (readonly) and Edit mode (editable fields).
- Client-side validation only.
- In-memory state only; no backend, no local storage.
- UX behaviors for Save, Cancel, and unsaved-change confirmation.

Out of scope
- Real authentication, server-side persistence, multi-account support, profile image upload.

---

## 2. User stories

User role: End user (anonymous or signed-in)
- As a user, I want to open a Profile screen from the Order screen so I can see my saved name, email, and phone for quick reference.
- As a user with no saved profile, I want the Profile screen to show empty fields and a prompt to complete my profile.
- As a user, I want to tap Edit to change my name, email, or phone so that order details use up-to-date contact information.
- As a user, I want validation errors shown inline if I enter an invalid email or phone so I can correct mistakes before saving.
- As a user, I want Save to persist changes for the current app session and return the screen to view mode with a confirmation message.
- As a user, I want Cancel to discard my unsaved edits and restore previously saved values.
- As a user, if I try to navigate back with unsaved changes, I want a confirmation prompt to avoid accidental loss of edits.

Edge-case user stories
- As a user, if I attempt to Save with an empty required Name field, I want an error preventing save.
- As a user, if I enter a phone with spaces or punctuation, I want the app to accept common phone formats (digits, +, spaces, -, parentheses) or show clear validation instructions if invalid.

---

## 3. Acceptance criteria (testable)

Navigation
- [AC-1] A "Profile" link/button is present at the bottom of the Order screen.
- [AC-2] Tapping the "Profile" link navigates to the Profile screen.

Profile screen layout & initial state
- [AC-3] Profile screen shows a header "Profile" and three fields: Name, Email, Phone.
- [AC-4] On first open with no prior in-memory data, fields are empty and view mode shows an "Edit" button and optional hint text ("Complete your profile").
- [AC-5] Fields are readonly in view mode; tapping "Edit" switches to edit mode.

Edit mode behavior
- [AC-6] Edit mode shows editable inputs for Name, Email, Phone and buttons "Save" and "Cancel".
- [AC-7] Focus is placed on the Name input when entering edit mode.

Validation rules
- [AC-8] Name is required; Save fails with inline error when Name is empty.
- [AC-9] Email must match a basic email regex (e.g., contains "@" and a domain); invalid email shows inline error and prevents Save.
- [AC-10] Phone is optional; if provided, it must contain only digits and allowed characters (+, spaces, -, parentheses); invalid phone shows inline error and prevents Save.

Saving and canceling
- [AC-11] On successful Save, the in-memory profile state is updated for the session, the screen returns to view mode, and a visible confirmation message "Profile saved" appears.
- [AC-12] Cancel discards unsaved edits and returns the screen to view mode showing last-saved values (or empty if none).
- [AC-13] No actual persistence to disk or network occurs after Save.

Unsaved changes and back navigation
- [AC-14] If the user has unsaved changes and attempts to navigate back (via header back or system back), a confirmation prompt "Discard changes?" with actions "Discard" and "Continue editing" is shown.
- [AC-15] Selecting "Discard" navigates back and discards edits; selecting "Continue editing" returns to edit mode and preserves edits.

Accessibility & UX
- [AC-16] All inputs have accessible labels.
- [AC-17] Inline errors are programmatically associated with inputs for screen readers.
- [AC-18] Buttons are reachable by keyboard/tab navigation (where applicable).

Testing
- [AC-19] Unit tests cover validation logic for email and phone formats.
- [AC-20] Navigation behavior from Order -> Profile and back is covered by an integration/UI test (or manual test steps documented).

Non-functional
- [AC-21] Profile screen renders within acceptable performance bounds (no perceptible delay on navigation).
- [AC-22] Behavior is consistent across supported platforms (Windows desktop dev environment).

---

## 4. Subtasks (implementation plan)

Subtask 1 — Design & spec
- Description: Create simple wireframe for Profile screen showing view/edit states and control placements; define exact validation patterns.
- Done when: wireframe image or small mock and regex definitions exist in the ticket.

Subtask 2 — Add navigation link on Order screen
- Description: Add a small "Profile" link/button at bottom of Order screen.
- Done when: tapping link opens Profile screen (AC-1, AC-2).

Subtask 3 — Implement Profile screen UI
- Description: Implement view mode (readonly) and edit mode UI with Name, Email, Phone, Edit/Save/Cancel controls and confirmation toast area.
- Done when: UI matches spec and header/labels present (AC-3..AC-7, AC-16).

Subtask 4 — Implement in-memory state
- Description: Add app-level in-memory state (singleton/service/context) to store profile data for the session.
- Done when: Save updates in-memory store and view mode displays saved values (AC-11, AC-13).

Subtask 5 — Implement validation logic
- Description: Add client-side validation for Name (required), Email (regex), Phone (allowed chars).
- Done when: invalid inputs block Save and show inline errors (AC-8..AC-10).

Subtask 6 — Unsaved changes handling
- Description: Detect dirty form state; intercept back navigation and show discard confirmation dialog when needed.
- Done when: confirmation dialog behavior works as specified (AC-14, AC-15).

Subtask 7 — Tests
- Description: Unit tests for validation functions and integration tests for navigation and save/cancel flows.
- Done when: tests exist and pass (AC-19, AC-20).

Subtask 8 — Accessibility & QA
- Description: Ensure labels, aria/error associations, keyboard focus handling; run manual test plan.
- Done when: accessibility checks pass and manual QA confirms behaviors (AC-16, AC-17, AC-18).

---

## 5. Example validation patterns (for implementers)
- Name: non-empty string; trim() length > 0.
- Email (basic): /^[^\s@]+@[^\s@]+\.[^\s@]+$/
- Phone (permissive): /^[0-9+\-\s()]*$/ (empty allowed)

---

## 6. Deliverables
- New Profile screen UI code.
- Navigation link from Order screen.
- In-memory profile state implementation.
- Validation logic and unit tests.
- Documentation of manual test steps for QA.
