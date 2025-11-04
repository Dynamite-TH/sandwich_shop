
**1. Project Title and Description**
- **Title:** Sandwich Shop App  
- **Description:** A small Flutter app to create sandwich orders with size selection (Footlong / 6-inch), bread selection, and per-item special instructions. The UI shows total quantity, per-size counts, and stored notes.
- **Key features:**
  - Segmented control to pick sandwich size (Footlong / 6-inch)
  - Bread selection via dropdown (White, Wheat, Wholemeal)
  - Text field to add per-item special instructions before pressing Add
  - Add / Remove buttons with enable/disable logic (respecting maxQuantity)
  - In-memory tracking of each added sandwich's size and note
  - Widget tests to validate counter behavior

---

**2. Installation and Setup Instructions**

Prerequisites
- OS: Windows (instructions here), macOS or Linux also supported by Flutter
- Flutter SDK (stable) installed and on PATH: https://flutter.dev/docs/get-started/install
- Git
- A connected device or emulator (Android/iOS) or desktop support enabled for Flutter

Clone repository
```bash
git clone <your-repo-url>
cd "c:\Users\thayw\OneDrive\Desktop\University\lv5\programming application and programming languages\sandwich_shop"
```

Install dependencies
```bash
flutter pub get
```

Run the app
- From terminal:
```bash
flutter run
```
- To target Windows:
```bash
flutter run -d windows
```
- From VS Code / Android Studio: open the project folder, select a device, press Run or Debug.

Notes:
- If you change widget constructors or state, do a full restart (not only hot reload) to avoid initialization issues with SegmentedButton selection or controllers.

---

**3. Usage Instructions**

How to use main features
- Select sandwich size using the SegmentedButton (Footlong / 6-inch).
- Choose bread type from the dropdown.
- Type any special instructions into the "Special Instructions" TextField (e.g., "no onions").
- Press Add to add one sandwich with the chosen size, bread and note. The Add button is disabled when the order reaches maxQuantity.
- Press Remove to remove the most recently added sandwich (and its associated note). Remove is disabled when there are zero items.

Important user flows
- Add note first, then press Add — the note is attached to the newly added item.
- Removing an item removes the last-added sandwich and its note in LIFO order.
- Per-size counts are shown next to the order display.

Configuration options
- OrderScreen accepts an optional maxQuantity parameter: `OrderScreen(maxQuantity: 5)` to change the maximum allowed items.
- `OrderRepository` (lib/repositories/order_repository.dart) can be extended to persist orders or change business rules.

How to run tests
```bash
flutter test
```
- Example included: `test/widget_test.dart` contains a counter test that verifies Add/Remove behavior and respects a max quantity value.

Screenshots / GIFs
- Add images to `assets/screenshots/` and reference here. Example placeholders:
  - assets/screenshots/home.png
  - assets/screenshots/add-note.gif

---

**4. Project Structure and Technologies Used**

Top-level
- `lib/`
  - `main.dart` — app entry, UI for `OrderScreen`, `StyledButton`, `OrderItemDisplay`
  - `views/app_styles.dart` — shared styling and theme helpers
  - `repositories/order_repository.dart` — order-related logic / persistence stub
- `test/`
  - `widget_test.dart` — widget tests for the app
- `pubspec.yaml` — dependencies and assets

Key dependencies (examples)
- `flutter` (SDK)
- (Add packages you use, e.g., provider, shared_preferences, etc., if applicable)

Development tools
- VS Code or Android Studio (recommended)
- Flutter DevTools for debugging and profiling

---

**5. Known Issues or Limitations**

Current/observed issues
- `SegmentedButton` can clear selection if not configured — ensure `emptySelectionAllowed: false` and initialize `_selectedSize` in `initState` to avoid a null selection error.
- `DropdownMenuEntry.label` must be a Widget (wrap enum names in `Text(...)`) — passing a raw String causes a runtime `TypeError`.
- Dart doesn't support string multiplication (e.g., `'🥪' * n`) — use `List.filled(n, '🥪').join()` for repeated emoji.
- Order data is in-memory only — app restart clears current orders.

Planned improvements
- Persist orders to local storage (shared_preferences or sqflite).
- Add order confirmation and a summary screen.
- Allow editing of individual items (change note, bread, or size).
- Improve accessibility and visual design.

Contribution guidelines
- Open an issue with a clear title and description before starting larger changes.
- Fork the repo, create a feature branch, add tests for your changes, and submit a pull request.
- Keep changes focused and document breaking changes in the PR.

---

**6. Contact Information**
- Project owner: (replace with your name)
- Contact: (replace with your email or GitHub profile link)
- Additional projects / profiles: (add links if desired)
