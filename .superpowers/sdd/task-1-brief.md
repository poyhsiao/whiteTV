### Task 1: Add integration_test dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add integration_test to dev_dependencies**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:  # Add this
    sdk: flutter
  # ... existing deps
```

- [ ] **Step 2: Verify dependency**

Run: `flutter pub get`
Expected: `integration_test` listed in dependencies

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: add integration_test dependency for E2E"
```

---

