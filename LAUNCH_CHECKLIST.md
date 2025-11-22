# 🚀 Pocketly Launch Checklist
## Simple Task Tracking for v1.0 Release

Last Updated: October 30, 2025

---

## 🔥 CRITICAL BLOCKERS (Must Complete)

### 1. Cloud Sync Completion
- [ ] Remove TODO at line 227 in `sync_manager.dart`
- [ ] Remove TODO at line 264 in `sync_manager.dart`
- [ ] Implement actual sync in `_handleSyncForExpense` (expenses_provider.dart:228)
- [ ] Implement actual sync in `_handleSyncForDelete` (expenses_provider.dart:258)
- [ ] Test: Add expense online → syncs immediately
- [ ] Test: Add expense offline → queues for sync
- [ ] Test: Reconnect to internet → pending items sync
- [ ] Test: Edit expense offline → syncs on reconnection
- [ ] Test: Delete expense offline → syncs on reconnection
- [ ] Connect sync_status_indicator to sync_manager
- [ ] Connect sync_details_bottom_sheet to sync_manager
- [ ] Test on 2+ devices with same account
- [ ] Verify no data loss in any scenario

**Time:** 6-8 hours | **Priority:** 🔴 CRITICAL

---

### 2. Testing Suite (Biggest Gap!)
- [ ] Create test directory structure
  - [ ] `test/unit/`
  - [ ] `test/widget/`
  - [ ] `integration_test/`
- [ ] Add test dependencies (mockito, mocktail, integration_test)
- [ ] Unit Tests:
  - [ ] auth_provider_test.dart (login, signup, token refresh)
  - [ ] expenses_provider_test.dart (CRUD + sync)
  - [ ] sync_manager_test.dart (queue, retry, conflicts)
  - [ ] network_service_test.dart
  - [ ] token_storage_service_test.dart
  - [ ] format_utils_test.dart
  - [ ] validator_test.dart
- [ ] Widget Tests:
  - [ ] login_view_test.dart
  - [ ] signup_view_test.dart
  - [ ] add_expense_view_test.dart
  - [ ] dashboard_view_test.dart
  - [ ] expense_card_test.dart
- [ ] Integration Tests:
  - [ ] full_expense_flow_test.dart (signup → add → edit → delete)
  - [ ] offline_sync_flow_test.dart
- [ ] Run `flutter test --coverage`
- [ ] Verify coverage ≥ 80%

**Time:** 40-50 hours | **Priority:** 🔴 CRITICAL

---

### 3. Search & Filter UI
- [ ] Add search bar to expenses_view.dart
- [ ] Implement search by expense name
- [ ] Implement search by description
- [ ] Add debouncing (300ms)
- [ ] Show search results count
- [ ] Add clear search button
- [ ] Enhance expense_filter_bar.dart:
  - [ ] Date range picker (week/month/custom)
  - [ ] Amount range filter
  - [ ] Category multi-select
  - [ ] Sort options (date/amount)
- [ ] Show active filters count badge
- [ ] Add "Clear all filters" button
- [ ] Save filters to shared preferences
- [ ] Add empty state for no results

**Time:** 10-12 hours | **Priority:** 🔴 CRITICAL

---

### 4. Privacy Policy & Terms of Service
- [ ] Write Privacy Policy
  - [ ] What data you collect (email, expenses)
  - [ ] How data is used
  - [ ] How data is stored (local + cloud)
  - [ ] Third-party services (if any)
  - [ ] Contact information
- [ ] Write Terms of Service
  - [ ] Acceptable use policy
  - [ ] Liability disclaimer
  - [ ] Account termination terms
- [ ] Host documents (GitHub Pages or website)
- [ ] Add links in app settings
- [ ] Test links work

**Time:** 2-3 hours | **Priority:** 🔴 CRITICAL (App stores require)

---

### 5. Error Handling & Logging
- [ ] Add logger package to pubspec.yaml
- [ ] Create `logger_service.dart`
- [ ] Replace all `debugPrint` with logger
- [ ] Add global error handler in main.dart
- [ ] Implement network error handling:
  - [ ] Timeout errors (show retry)
  - [ ] No internet (show offline message)
  - [ ] 401 Unauthorized (force logout)
  - [ ] 500 Server error (maintenance message)
- [ ] Add user-friendly error messages
- [ ] Test error scenarios

**Time:** 8-10 hours | **Priority:** 🔴 CRITICAL

---

## 📱 APP STORE REQUIREMENTS

### 6. App Store Assets
- [ ] Design app icon (1024x1024 for iOS, 512x512 for Android)
- [ ] Create splash screen
- [ ] Take screenshots:
  - [ ] Dashboard (with data)
  - [ ] Add expense screen
  - [ ] Expense list
  - [ ] Charts/analytics
  - [ ] Dark mode showcase
  - [ ] 5-8 screenshots per platform
- [ ] Create feature graphic (Android: 1024x500)
- [ ] Write app description
- [ ] Research keywords
- [ ] Create promotional text

**Time:** 8-10 hours | **Priority:** 🔴 CRITICAL

---

## ⭐ HIGHLY RECOMMENDED

### 7. User Onboarding
- [ ] Create welcome screen
- [ ] Design 3-4 tutorial screens:
  - [ ] Feature 1: Track expenses offline
  - [ ] Feature 2: Cloud sync
  - [ ] Feature 3: Beautiful analytics
  - [ ] Feature 4: Secure & private
- [ ] Add "Skip" option
- [ ] Add "Get Started" button
- [ ] Save onboarding completion to preferences
- [ ] Test onboarding flow

**Time:** 6-8 hours | **Priority:** 🟡 RECOMMENDED

---

### 8. Email Verification Flow
- [ ] Create OTP input screen (6 digits)
- [ ] Add "Resend OTP" button with cooldown
- [ ] Connect to backend OTP endpoints
- [ ] Show verification success
- [ ] Connect expense limit warnings (15th expense)
- [ ] Connect expense limit block (21st expense)
- [ ] Show verification dialog when blocked
- [ ] Update user state after verification
- [ ] Test entire flow

**Time:** 6-8 hours | **Priority:** 🟡 RECOMMENDED

---

### 9. Enhanced Categories
- [ ] Add more predefined categories:
  - [ ] Rent/Mortgage
  - [ ] Education
  - [ ] Savings/Investment
  - [ ] Gifts
  - [ ] Personal Care
- [ ] Improve icon selection for each
- [ ] Test category filtering
- [ ] Test category analytics

**Time:** 4-6 hours | **Priority:** 🟡 RECOMMENDED

---

### 10. Performance Optimization
- [ ] Add `const` constructors to all widgets
- [ ] Profile app with Flutter DevTools
- [ ] Optimize chart rendering
- [ ] Test with 500+ expenses
- [ ] Reduce app size:
  - [ ] Consider removing 2 font families
  - [ ] Compress logo images
  - [ ] Remove unused dependencies
- [ ] Enable code shrinking for release
- [ ] Test app startup time (< 3 seconds)

**Time:** 8-10 hours | **Priority:** 🟡 RECOMMENDED

---

### 11. Settings Enhancement
- [ ] Add currency selection (currently hardcoded ₦)
- [ ] Add data export (CSV format)
- [ ] Add data import (CSV format)
- [ ] Add "About" section:
  - [ ] App version
  - [ ] Build number
  - [ ] Privacy policy link
  - [ ] Terms of service link
  - [ ] Contact support
  - [ ] Rate app button
- [ ] Test all settings persist

**Time:** 10-12 hours | **Priority:** 🟡 RECOMMENDED

---

## 🔐 SECURITY & DEPLOYMENT

### 12. Security Hardening
- [ ] Create `.env` file for environment variables
- [ ] Move API URL to environment config
- [ ] Create `environment.dart` config
- [ ] Enable code obfuscation:
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/debug-info
  ```
- [ ] Test obfuscated build
- [ ] Ensure no secrets in code

**Time:** 4-6 hours | **Priority:** 🟢 NICE TO HAVE

---

### 13. Backend Deployment
- [ ] Choose hosting (Railway/Heroku/DigitalOcean)
- [ ] Set up production database
- [ ] Configure environment variables
- [ ] Set up domain and SSL
- [ ] Deploy backend
- [ ] Test production API
- [ ] Set up database backups
- [ ] Set up monitoring (UptimeRobot)

**Time:** 8-10 hours | **Priority:** 🟢 NICE TO HAVE (Can use localhost for testing)

---

### 14. CI/CD Pipeline
- [ ] Create `.github/workflows/flutter_ci.yml`
- [ ] Add lint step
- [ ] Add test step
- [ ] Add build step
- [ ] Add coverage reporting
- [ ] Test workflow on PR
- [ ] Set up automated versioning

**Time:** 6-8 hours | **Priority:** 🟢 NICE TO HAVE

---

### 15. Analytics & Monitoring
- [ ] Choose analytics (Firebase/Mixpanel)
- [ ] Add analytics package
- [ ] Track key events:
  - [ ] App opened
  - [ ] User signup
  - [ ] Expense added
  - [ ] Sync completed
- [ ] Set up crash reporting (Sentry/Firebase Crashlytics)
- [ ] Test analytics in debug mode

**Time:** 6-8 hours | **Priority:** 🟢 NICE TO HAVE

---

## 🧪 QUALITY ASSURANCE

### 16. Manual Testing
- [ ] Test on iPhone (iOS 15+)
- [ ] Test on Android (Android 10+)
- [ ] Test on small screen (5.5")
- [ ] Test on large screen (6.7")
- [ ] Test on tablet
- [ ] Test poor network
- [ ] Test offline mode extensively
- [ ] Test dark mode
- [ ] Test with 100+ expenses
- [ ] Test sync across 2 devices
- [ ] Test all user flows:
  - [ ] New user signup → add expense → view dashboard
  - [ ] Existing user login → add expense → edit → delete
  - [ ] Offline user → add expense → go online → verify sync
  - [ ] Email verification flow
  - [ ] Password change
  - [ ] Profile update

**Time:** 15-20 hours | **Priority:** 🔴 CRITICAL

---

### 17. Beta Testing
- [ ] Set up TestFlight (iOS)
- [ ] Set up Google Play Internal Testing (Android)
- [ ] Recruit 10-20 beta testers
- [ ] Create feedback form
- [ ] Run beta for 2-3 weeks
- [ ] Collect and analyze feedback
- [ ] Fix critical bugs
- [ ] Iterate based on feedback

**Time:** 2-4 weeks | **Priority:** 🟡 RECOMMENDED

---

## 📋 PRE-SUBMISSION CHECKLIST

### Final Review Before App Store Submission
- [ ] All TODOs removed from code
- [ ] All console warnings resolved
- [ ] Test coverage ≥ 80%
- [ ] All features working
- [ ] Privacy policy linked
- [ ] Terms of service linked
- [ ] App icon ready (all sizes)
- [ ] Screenshots ready (all sizes)
- [ ] App description ready
- [ ] Backend deployed (if using cloud)
- [ ] Cloud sync working perfectly
- [ ] Offline mode seamless
- [ ] No crashes in testing
- [ ] Performance smooth (< 3s startup)
- [ ] Beta testers approve
- [ ] Version number set (1.0.0)
- [ ] Build number incremented

---

## 🎯 LAUNCH!

### App Store Submission
- [ ] Submit to Apple App Store
  - [ ] Create App Store Connect listing
  - [ ] Upload build via Xcode/Transporter
  - [ ] Fill app information
  - [ ] Add screenshots
  - [ ] Submit for review
- [ ] Submit to Google Play Store
  - [ ] Create Play Console listing
  - [ ] Upload APK/AAB
  - [ ] Fill app information
  - [ ] Add screenshots
  - [ ] Submit for review

### Post-Launch
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Respond to feedback
- [ ] Plan next version
- [ ] Celebrate! 🎉

---

## 📊 Progress Tracking

**Critical Tasks:** 0/6 ⬜⬜⬜⬜⬜⬜  
**Recommended Tasks:** 0/5 ⬜⬜⬜⬜⬜  
**Nice to Have:** 0/4 ⬜⬜⬜⬜  
**QA Tasks:** 0/2 ⬜⬜  

**Overall Progress:** 0/17 (0%)

---

## 🕒 Time Budget

**Minimum Viable Launch:** 65-88 hours (~2-3 weeks)  
**Recommended Launch:** 130-170 hours (~4-5 weeks)  
**Polished Launch:** 180-240 hours (~6-8 weeks)

---

## 💡 Quick Tips

1. **Start with cloud sync** - Your #1 feature promise
2. **Don't skip testing** - Biggest gap right now
3. **Test offline extensively** - Critical for your target market
4. **Launch stable first** - Better fewer features than crashes
5. **Beta test thoroughly** - Catch bugs before public launch

---

## 🆘 Stuck? Check These Docs

- Full details: `PRODUCTION_READINESS_CHECKLIST.md`
- Quick overview: `PRODUCTION_QUICK_SUMMARY.md`
- Your cursor rules: `.cursorrules`
- Backend API: `backend/pocketly_api/API_DOCUMENTATION.md`
- Offline guide: `frontend/offline_first.md`

---

**Good luck with your launch! You're building something valuable! 🚀**

