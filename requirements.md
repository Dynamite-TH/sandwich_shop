# Cart Modification Feature Requirements

## 1. Feature Description and Purpose

The Cart Modification feature enables users of the Sandwich Shop Flutter app to manage the contents of their cart before checkout. Users can adjust the quantity of each sandwich or remove items. Editing sandwich details (such as bread type or size) is not supported on the cart page; users must add a new item from the order screen if they wish to change sandwich options. This feature aims to provide a flexible and user-friendly shopping experience, ensuring users can easily correct mistakes or change their order without starting over.

---

## 2. User Stories

### 2.1. Adjust Quantity

- **As a user**, I want to increase or decrease the quantity of a sandwich in my cart, so I can order the exact number I want.
- **As a user**, I want the cart to automatically remove an item if I decrease its quantity below 1, so my cart never contains items with zero or negative quantity.

### 2.2. Remove Item

- **As a user**, I want to remove a sandwich from my cart with a single action, so I can quickly update my order if I change my mind.

### 2.3. Feedback and UI Responsiveness

- **As a user**, I want the cart and total price to update immediately when I make changes, so I always see an accurate summary of my order.
- **As a user**, I want to receive feedback (such as a snackbar) when I remove or update an item, so I know my action was successful.
- **As a user**, I want to see a clear message if my cart is empty, so I know I need to add items before checking out.

---

## 3. Acceptance Criteria

### 3.1. Quantity Adjustment

- [x] Each cart item displays "+" and "–" buttons for quantity adjustment.
- [x] Tapping "+" increases the quantity by 1.
- [x] Tapping "–" decreases the quantity by 1.
- [x] If the quantity is reduced below 1, the item is removed from the cart.
- [x] The total price updates automatically and accurately.
- [x] The UI updates immediately to reflect changes.

### 3.2. Remove Item

- [x] Each cart item has a "Remove" button (e.g., trash icon).
- [x] Tapping "Remove" deletes the item from the cart.
- [x] The total price updates accordingly.
- [x] A snackbar or similar feedback is shown when an item is removed.

### 3.3. General UI and Behavior

- [x] All changes are reflected immediately in the UI.
- [x] The cart's total price is always accurate.
- [x] The cart handles empty states gracefully (e.g., displays a message if empty).
- [x] The UI prevents negative quantities.
- [x] User feedback is provided for all cart modification actions.

---

## 4. Subtasks

1. Implement "+" and "–" quantity adjustment buttons for each cart item.
2. Implement logic to remove an item if its quantity is reduced below 1.
3. Add a "Remove" button for each cart item.
4. Ensure the total price and UI update immediately after any change.
5. Provide user feedback (snackbar) for remove and update actions.
6. Handle empty cart states with a clear message.

