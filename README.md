

 ### I initially explained the entire project and its requirements in Hindi, 
 ### and then used AI to help me organize that information and create the README.md file in a professional format.

# Job Matching App (GCC)

A Flutter mobile application built for candidates looking for job opportunities across Gulf countries (UAE, Saudi Arabia, Qatar). 
The app focuses on clean UI, reactive state management, offline support, bilingual capabilities (English and Hindi), and resilient handling of network failures with optimistic UI updates.

# How to Run the Project

## Prerequisites
- Flutter SDK (3.12.0 or above)
- Android Studio / VS Code with Flutter extension
- An Android emulator, iOS simulator, or a connected physical device

## Steps
1. Clone or open the repository:
   ```bash
   cd /Users/amolchitrak/Documents/job_matching
   ```

2. Get project dependencies:
   ```bash
   flutter pub get
   ```

3. Run the unit and widget tests:
   ```bash
   flutter test
   ```
   (All 6 tests verify match score sorting, country filtering, optimistic apply, rollback on failure, and offline blocking).

4. Run the app:
   ```bash
   flutter run
   ```

## Libraries Used & Why

I kept external dependencies minimal to keep the app lightweight and fast:

1. GetX (`get: ^4.7.3`):
   - Reactive State Management: Simple observable variables (`.obs` and `Obx`) for managing job lists, filters, offline status, and applied states without boilerplate.
   - Dependency Injection: Used `Get.put()` and `Get.find()` to easily access services (`MockJobApiService`, `StorageService`) and controllers across views without prop-drilling or `InheritedWidget` complexity.
   - Internationalization: GetX has built-in translation support (`Get.updateLocale`), which allows on-the-fly language switching without restarting the app or rebuilding the entire widget tree manually.

2. Shared Preferences (`shared_preferences: ^2.5.6`):
   - Used for persisting lightweight local data:
     - Applied job IDs (so applied status survives app restarts)
     - Cached jobs list (for offline viewing)
     - Selected language preference (`en` or `hi`)
   - Avoided heavy database engines like SQLite or Realm because the local data requirements for this assignment are straightforward key-value and serialized JSON strings.

3. Cupertino Icons (`cupertino_icons: ^1.0.8`):
   - Default icon set bundled with Flutter for standard navigation and interface icons.

---

## Features & Implementation Details

### 1. Job Listing & Infinite Scroll
- Displays jobs with key trade details: job title, employer, country, city, salary range in AED, match score percentage, and skill tags.
- Uses `ListView.builder` combined with a `ScrollController` listener. When the user scrolls within 200 pixels of the bottom, `loadMore()` triggers the next page of 20 items.
- A pull-to-refresh (`RefreshIndicator`) is attached to reload the first page fresh from the API.

### 2. Country Filtering & Match Score Sorting
- Filter chips at the top allow filtering by All, UAE, Saudi Arabia, and Qatar.
- Tapping a chip updates the controller state and queries the API for filtered results.
- Jobs are sorted in descending order of match score so the most relevant matches appear first.

### 3. Job Details Screen
- Tapping any card opens the detailed view showing:
  - Full job title, employer, location, and salary badge.
  - An AI match score card with the specific rationale for why this job fits the profile.
  - Benefits breakdown (Accommodation, Food, Visa) with visual status indicators.
  - Required skills and bullet-pointed job requirements.
  - A sticky Apply button at the bottom of the screen.

### 4. Apply Confirmation & Optimistic UI Updates
- Tapping Apply Now opens a confirmation modal bottom sheet (`ApplyConfirmationDialog`) confirming the application.
- Optimistic Update: The UI immediately marks the job as "Applied" both in the detail screen and in the main list so the user experiences zero lag.
- The background call executes via `MockJobApiService.applyJob(jobId)`.
  - On Success: The job ID is saved into `SharedPreferences` so it remains marked as applied even if the user restarts the app.
  - On Failure: The optimistic change is rolled back immediately (the ID is removed from `appliedJobIds` and the job card returns to its unapplied state), and an error snackbar is displayed alerting the user to retry.

### 5. API Error Simulation & Network Handling
- The mock service (`MockJobApiService`) simulates a real-world network environment:
  - Realistic latency between 800ms and 1500ms using `Future.delayed`.
  - A random 20% failure rate (throws a `500 Internal Server Error`).
- The controller safely catches these errors:
  - If initial page load fails and no cache exists, an error screen with a "Retry" button is shown.
  - If pagination fails, it fails gracefully without breaking the already-loaded list.
  - If apply fails, it executes the rollback logic mentioned above.

### 6. Offline Support
- The app supports offline usage:
  - Jobs from successful fetches are cached locally in `SharedPreferences`.
  - If a network error occurs or offline mode is toggled, the app loads and displays the cached jobs.
  - A visible orange banner (`OfflineBanner`) appears at the top indicating that the user is offline and viewing saved jobs.
  - The Apply button is disabled with an informative message ("You are offline — cannot apply right now") to prevent invalid requests.
- For testing and evaluation, an offline toggle button (Wi-Fi icon) is placed directly in the AppBar to switch offline mode on and off easily.

### 7. Bilingual Support (English & Hindi)
- An app bar button allows toggling between English and Hindi (`EN` / `हिन्दी`) at any time.
- All core UI strings (titles, buttons, filters, offline warnings, error messages, benefit labels) are defined in `AppTranslations`.
- When toggled, the language code is saved in local storage, and the app locale updates reactively.

---

## Code Structure

```
lib/
├── main.dart                      # App entry point, dependency injection bindings, theme setup
├── models/
│   └── job_model.dart             # JobModel & JobBenefits with JSON parsing & copyWith
├── controllers/
│   ├── job_controller.dart        # Core business logic: pagination, filtering, optimistic apply, rollback
│   └── language_controller.dart   # Language state and locale switching
├── services/
│   ├── mock_job_api.dart          # Simulated backend: 200 items dataset, latency, 20% 500 errors
│   └── storage_service.dart       # SharedPreferences wrapper for applied jobs, caching, language
├── utils/
│   ├── app_colors.dart            # Custom color palette and constants
│   ├── app_theme.dart             # Material 3 light theme configuration
│   └── app_translations.dart      # Translation maps for English ('en_US') and Hindi ('hi_IN')
└── views/
    ├── job_list_view.dart         # Main listing screen with search/filter, pull-to-refresh, infinite scroll
    ├── job_detail_view.dart       # Detailed job view with sticky apply button
    └── widgets/
        ├── job_card.dart          # Reusable job card widget
        ├── filter_chips_bar.dart  # Country filter chip bar
        ├── offline_banner.dart    # Warning banner when offline
        └── apply_confirmation_dialog.dart # Bottom sheet modal shown on apply
```

---

## Performance & Design Choices

- No Over-engineering: Instead of setting up complex multi-package architectures (BLoC / Redux) for a focused application, GetX provided a clear, reactive separation of concerns while keeping build times fast and memory footprint low.
- Efficient List Rendering: `ListView.builder` renders only visible items on screen, preventing memory spikes when navigating through the 200+ mock jobs dataset.
- Granular Reactivity: Wrapped only dynamic sections (like badges, banners, and button states) inside `Obx` widgets to avoid unnecessary rebuilding of entire views.
- Accessibility & Touch Targets: Filter chips and action buttons have comfortable heights (44–48dp) and legible contrast for easy one-handed operation.

---

## Current Limitations & Future Improvements

### Current Limitations
- Mock Service: The data is currently generated by an in-app mock service rather than a live remote REST or GraphQL backend.
- Flat Local Cache: Cached jobs are stored as a serialized JSON string in `SharedPreferences`. While suitable for 200 jobs, a larger catalog would benefit from SQLite (sqflite) or Hive/Isar.
- Static Job Descriptions: Job descriptions and titles are currently English-only; only the UI labels and application controls toggle between English and Hindi.

### Future Improvements
- Real Backend Integration: Connect to actual REST APIs with authentication tokens (JWT).
- Audio / Voice Applications: Add the ability for candidates to record a short voice intro when applying for a job.
- Offline Sync Queue: Allow users to queue their job applications while offline and automatically dispatch them once internet connectivity returns.
- Push Notifications: Notify candidates when a matching Gulf employer views or shortlists their application.
