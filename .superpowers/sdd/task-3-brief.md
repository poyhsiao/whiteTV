### Task 3: Create LoginPage and HomePage POMs

**Files:**
- Create: `test/e2e/pages/login_page.dart`
- Create: `test/e2e/pages/home_page.dart`

**Interfaces:**
- Consumes: `BasePage`
- Produces: `LoginPage`, `HomePage` classes

- [ ] **Step 1: Create LoginPage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class LoginPage extends BasePage {
  LoginPage(super.tester);

  /// Keys from login_screen.dart
  static const usernameKey = Key('username_field');
  static const passwordKey = Key('password_field');
  static const loginButtonKey = Key('login_button');
  static const qrInputKey = Key('qr_input_button');

  /// Enter username
  Future<void> enterUsername(String username) async {
    await tester.enterText(find.byKey(usernameKey), username);
    await tester.pumpAndSettle();
  }

  /// Enter password
  Future<void> enterPassword(String password) async {
    await tester.enterText(find.byKey(passwordKey), password);
    await tester.pumpAndSettle();
  }

  /// Tap login button
  Future<void> tapLogin() async {
    await tester.tap(find.byKey(loginButtonKey));
    await tester.pumpAndSettle();
  }

  /// Login with credentials
  Future<void> login(String username, String password) async {
    await enterUsername(username);
    await enterPassword(password);
    await tapLogin();
  }
}
```

- [ ] **Step 2: Create HomePage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class HomePage extends BasePage {
  HomePage(super.tester);

  /// Key from home_screen.dart
  static const homeScreenKey = Key('home_screen');

  /// Wait for home to load
  Future<void> waitForLoad() async {
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(homeScreenKey), findsOneWidget);
  }

  /// Check if category tab exists
  bool hasCategory(String categoryName) {
    return find.text(categoryName).evaluate().isNotEmpty;
  }
}
```

- [ ] **Step 3: Verify both compile**

Run: `dart analyze test/e2e/pages/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add test/e2e/pages/login_page.dart test/e2e/pages/home_page.dart
git commit -m "feat: add LoginPage and HomePage Page Objects"
```

---

