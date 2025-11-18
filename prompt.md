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


Authentication

You are an expert Flutter developer and backend engineer. Help me implement account auth and profile management in my existing Sandwich Shop app. For each feature below include a short description, expected UI flow, exact behavior when the user performs actions, acceptance criteria, and a minimal API contract (HTTP endpoints + request/response examples). Also list validation rules, error messages, and simple security notes. Keep answers actionable for implementing in Flutter (routes, widgets, storage, tests).

Features:

1) Sign up (Create account)
- Description:
  Let users create a new account with name, email, password, and address (line, city, postcode). The app must validate inputs, show inline errors, and call backend to create account.
- UI flow / screens:
  Route: /sign-up. Form with fields: full name, email, password, confirm password, address line, city, postcode, "Create account" button, link to Sign in.
- What happens on submit:
  1. Validate locally: required fields, email format, password min length 8, password == confirm.
  2. Disable form, show loading indicator.
  3. POST /api/auth/register with JSON {name,email,password,address:{line,city,postcode}}.
  4. On 201 Created: backend returns {user:{id,name,email,address}, token}. Save token securely (flutter_secure_storage), navigate to /home (or /profile) and show success toast.
  5. On 400/422: show server validation messages inline.
  6. On network error: show generic "Unable to create account. Check connection." and re-enable form.
- Acceptance criteria:
  - New user gets token stored securely and is navigated to the app main screen.
  - Errors are shown inline or as a snackbar.
- API contract example:
  POST /api/auth/register
  Request:
  { "name":"Alice", "email":"alice@example.com", "password":"Secret123", "address":{"line":"1 Main St","city":"Town","postcode":"12345"} }
  Success 201:
  { "user": { "id":"u123", "name":"Alice", "email":"alice@example.com", "address":{...} }, "token":"ey..." }
  Error 400/422:
  { "errors": { "email":"Email already in use", "password":"Too short" } }

2) Sign in
- Description:
  Allow existing users to sign in with email and password to receive an auth token and access protected features.
- UI flow / screens:
  Route: /sign-in. Form: email, password, "Sign in" button, "Forgot password?" link, link to Sign up.
- What happens on submit:
  1. Validate fields (required, email format).
  2. POST /api/auth/login {email,password}.
  3. On 200: backend returns {user, token}. Save token in secure storage, update app auth state, navigate to home, hide loading.
  4. On 401: show "Invalid email or password" below fields.
  5. On network error: show generic error.
- Acceptance criteria:
  - Valid credentials log user in and persist session until sign out or token expiry.
  - Invalid credentials show clear error.
- API contract:
  POST /api/auth/login
  Request: { "email":"alice@example.com", "password":"Secret123" }
  Success 200: { "user":{...},"token":"ey..." }
  Error 401: { "message":"Invalid credentials" }

3) View profile (read user details)
- Description:
  Show current signed-in user's profile data: name, email, address. Data should be fetched from local cache first, then refreshed from server.
- UI flow / screens:
  Route: /profile. Read-only view with Edit button and Sign out button.
- What happens on open:
  1. If offline or token present, display cached user object immediately.
  2. Send GET /api/users/me with Authorization: Bearer <token> to refresh.
  3. On 200: update UI and local cache.
  4. On 401: force sign out and navigate to /sign-in.
- Acceptance criteria:
  - Profile displays up-to-date user data.
  - Unauthorized response triggers sign out flow.
- API contract:
  GET /api/users/me
  Headers: Authorization: Bearer <token>
  Success 200: { "user":{ "id","name","email","address":{...} } }
  Error 401: { "message":"Token expired" }

4) Edit profile (update name, email, address)
- Description:
  Allow users to update name, email and address. Email update may require re-verification depending on backend policy.
- UI flow / screens:
  Route: /profile/edit (or modal). Prefill fields, Save and Cancel buttons.
- What happens on save:
  1. Validate inputs (email format, required for name).
  2. PATCH /api/users/me with JSON {name,email,address:{...}} and Authorization header.
  3. On 200: update local cache and UI, show "Profile updated" message, return to /profile.
  4. On 409 (email conflict): show "Email already in use".
  5. On 401: sign out and redirect to /sign-in.
- Acceptance criteria:
  - Changes persist on server and locally.
  - Conflicting email returns clear error and form remains editable.
- API contract:
  PATCH /api/users/me
  Request: { "name":"New Name", "email":"new@example.com", "address":{...} }
  Success 200: { "user":{...} }
  Error 409: { "message":"Email already in use" }

5) Sign out
- Description:
  Clear stored token and cached user, navigate to /sign-in.
- What happens when user taps Sign out:
  1. Optionally call POST /api/auth/logout to revoke token.
  2. Delete token from secure storage, clear in-memory user, navigate to /sign-in and remove auth-only routes from navigation stack.
- Acceptance criteria:
  - Token and user data removed and protected routes require sign-in afterwards.

Implementation hints for Flutter
- Routes: add '/sign-in', '/sign-up', '/profile', '/profile/edit'.
- State: use Provider / Riverpod / Bloc to expose AuthState {user, token, isLoading, signIn(), signUp(), signOut(), refreshUser(), updateProfile()}.
- Storage: store token in flutter_secure_storage; cache user in local storage (shared_preferences or sqlite) for instant UI.
- HTTP: central API client that attaches Authorization header when token exists and handles 401 globally to trigger signOut().
- Forms: use TextFormField with validators, show inline errors returned from backend mapped to fields.
- Navigation: After sign-in or sign-up use Navigator.of(context).pushReplacementNamed('/'); for home.
- Tests: unit tests for validators and AuthState methods, integration tests covering sign-in -> profile -> edit -> sign-out flows.
- UX notes: disable submit buttons while network call in progress; show progress indicator; confirm unsaved changes when leaving edit screen.
- Security notes: never store plain password, use TLS, store JWT/refresh token securely, prefer refresh token flow for long sessions.

Developer tasks to deliver (prioritized)
1. Create SignInScreen and SignUpScreen widgets and add routes.
2. Create ProfileScreen and EditProfileScreen.
3. Implement AuthProvider with methods described and secure storage usage.
4. Implement API client and endpoints described.
5. Add unit tests for validation and AuthProvider; integration test for full flow.

If you need, generate a concrete Flutter scaffold (widgets, provider class, and API client) matching my project structure (lib/views, lib/services, lib/models). Provide code examples and tests next.