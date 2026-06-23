### Task 2: Create BasePage (Page Object base class)

**Status: DONE**

**Commit**

- `de73d06` feat: add BasePage for E2E Page Objects

**Files Created**

- `test/e2e/pages/base_page.dart` — BasePage abstract class with tap, enterText, waitFor, takeScreenshot

**Verification**

- `dart analyze test/e2e/pages/base_page.dart` — No issues found

**Implementation Notes**

- `takeScreenshot` is a stub because `WidgetTester.takeScreenshot` is not available in `flutter_test` (requires `integration_test` package). Kept as no-op stub for future integration_test usage.
- `tap` supports `#keyName` (by Key) and text-based locators
- `enterText` supports `#keyName` (by Key) and TextField type fallback
- `waitFor` pumps with configurable timeout then asserts widget existence
- Follows project conventions: `final` fields, `Future<void>` return types
