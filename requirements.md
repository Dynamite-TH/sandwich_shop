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

### 2.1 Feature Description
Add account creation, sign-in, profile viewing and editing so users can manage addresses and personal data across devices. Persist tokens securely.

### 2.2 Subtasks
1. Auth model: User {id, name, email, address}, AuthState {user, token, isLoading}.
2. Implement AuthProvider (ChangeNotifier) with methods:
   - signUp(name,email,password,address), signIn(email,password), signOut(), refreshUser(), updateProfile(updatedUser).
3. Secure storage: store token in flutter_secure_storage; cache user in SharedPreferences for quick display.
4. Routes & UI screens:
   - /sign-in (SignInScreen), /sign-up (SignUpScreen)
   - /profile (ProfileScreen read-only with Edit + Sign out), /profile/edit (EditProfileScreen)
5. HTTP client:
   - Central API client that includes Authorization: Bearer <token> when present and handles 401 by triggering signOut().
6. Forms:
   - Validation: name required, email format, password min 8, confirm password match.
   - Inline field errors and server-side error mapping.
7. Tests:
   - Unit tests for AuthProvider (signIn/signUp/updateProfile) using mocked HTTP layer and mocked secure storage.
   - Widget tests for sign-in/up form validation and navigation.

### 2.3 User Stories
- As a new user I can create an account by providing name, email, password and address so I can save orders to my account.
- As a returning user I can sign in with email and password and remain signed in across app restarts.
- As a signed-in user I can view my profile details immediately and refresh from server.
- As a signed-in user I can edit my name, email and address; conflicts (email in use) surface as clear inline errors.
- As a signed-in user I can sign out which clears my token and cached user data.

### 2.4 Acceptance Criteria
- Sign up:
  - Local validation enforced; on success API returns token+user, token stored securely, user navigated to home/profile and state updated.
  - Server validation errors shown inline.
- Sign in:
  - Valid creds save token securely, update AuthProvider, navigate to home.
  - Invalid creds show clear error (e.g., "Invalid credentials").
- Profile view:
  - Cached user shown immediately; GET /api/users/me refreshes and updates cache.
  - 401 from API triggers sign out flow.
- Edit profile:
  - Valid updates PATCH to /api/users/me, updates local cache and UI.
  - 409 conflict (email) surfaces inline and leaves form editable.
- Sign out:
  - Token removed from secure storage and in-memory cache; user redirected to /sign-in.
- Security:
  - Token stored in flutter_secure_storage, all API calls over HTTPS, never store plaintext password.

### 2.5 Minimal API Contract (examples)
- POST /api/auth/register
  - Req: {name,email,password,address:{line,city,postcode}}
  - 201: {user:{id,name,email,address}, token:"..."}
  - 400/422: {errors:{field:"msg"}}
- POST /api/auth/login
  - Req: {email,password}
  - 200: {user:{...}, token:"..."}
  - 401: {message:"Invalid credentials"}
- GET /api/users/me
  - Header: Authorization: Bearer <token>
  - 200: {user:{...}}
  - 401: {message:"Token expired"}
- PATCH /api/users/me
  - Header: Authorization
  - Req: {name,email,address:{...}}
  - 200: {user:{...}}
  - 409: {message:"Email already in use"}

### 2.6 Validation & Error Messages
- Email: required, valid format → "Enter a valid email."
- Password: required, min 8 chars → "Password must be at least 8 characters."
- Name: required → "Enter your name."
- Address fields: required (line, city, postcode) → "Address is required."
- Network error: "Unable to connect. Check your internet and try again."
- 401: "Session expired. Please sign in again."

### 2.7 Test Requirements
- Unit tests for AuthProvider:
  - signUp success/failure, signIn success/401, updateProfile success/409, signOut clears storage.
- Widget tests for SignIn/SignUp forms:
  - Validation messages appear, navigation on success.

---

## Migration Plan & Files to Change

### Files to add/modify (suggested layout)
- lib/models/cart_item.dart (new) — cart item model + serialization
- lib/providers/cart_provider.dart (new) — ChangeNotifier with cart logic & persistence
- lib/views/cart/cart_screen.dart (modify) — use CartProvider, update totals UI
- lib/views/cart/cart_row.dart (new) — row widget with +/−, edit, trash, swipe handling
- lib/views/cart/quantity_modal.dart (new) — numeric input modal
- lib/views/customization/customization_screen.dart (modify) — support prefill for editing
- lib/services/storage_service.dart (new/modify) — SharedPreferences wrapper
- lib/models/user.dart (new) — user model
- lib/providers/auth_provider.dart (new) — auth logic + secure storage
- lib/views/auth/sign_in.dart (new), sign_up.dart (new), profile.dart (new), profile_edit.dart (new)

### Integration checklist
- Replace direct cart state in order screen to call CartProvider.addItem(...)
- Ensure customization screen returns CartItemOptions when used for edit flow
- Register providers in main.dart (ChangeNotifierProvider for CartProvider and AuthProvider)
- Add routes: /sign-in, /sign-up, /profile, /profile/edit, cart screens if not present

### How to run tests & QA
- Run unit/widget tests:
  - flutter test
- Manual QA flows:
  - Add items in OrderScreen, go to Cart, test increment/decrement/manual set.
  - Remove item and confirm Undo restores.
  - Edit item with price change; ensure totals update and merge behavior works.
  - Save-for-later move and restart app to validate persistence.
  - Sign up, sign in, view/edit profile, sign out flows with mocked API or test backend.

---

## Non-functional & Security Notes
- All network operations asynchronous; UI must show progress indicators and disable repeated actions.
- Store tokens in flutter_secure_storage; do not store passwords.
- Use HTTPS; handle 401 globally to sign out.
- Accessibility: label +/− buttons, Edit, Remove, Save-for-later for screen readers.
- Performance: use ListView.builder, avoid rebuilding whole list on single-row updates (notifyListeners granularity).

---

## Priority Implementation Plan (Minimal Viable Changes)
1. Create CartProvider + Cart model + persist/load from SharedPreferences.
2. Implement CartScreen + CartRow with +/− and trash icon (swipe later).
3. Add Undo snackbar and basic numeric modal for manual set.
4. Implement edit flow integration with existing customization screen and merging logic.
5. Add save-for-later persistence.
6. Add AuthProvider and basic SignIn/SignUp/Profile screens (use mocked API if backend not available).
7. Add unit/widget tests iteratively for each completed piece.
