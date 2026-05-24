# Project State

Last updated: 2026-05-24

> Read this first in a new chat when the task depends on current project status.
> Keep this file short. Replace stale facts instead of appending history.

## Current status

SwipeClean is a SwiftUI iOS app with PhotoKit-based media loading, cleanup mode selection, month-based review, swipe decisions, a summary screen, and PhotoKit deletion after final confirmation.

The app starts at `OnboardingScreen`, then routes into cleanup modes and review flows. Theme and language preferences are stored with `@AppStorage` and applied at the app root.

## Implemented

- Photo Library permission flow and permission-aware UI states.
- Cleanup modes: Monthly Review, All Media, Screenshots, and Videos.
- Media loading through `PhotoLibraryService`, including grouping by month and filtering screenshots/videos.
- Swipe session state in `SwipeSessionViewModel`; swipe up marks pending deletion, swipe down keeps, and users can finish review early.
- Undo, progress count, progress messages, and session-local completion feedback.
- Swipe review shows a live pending deletion count derived from session decisions.
- Summary screen with pending deletion previews and a final delete confirmation alert.
- Real deletion through `PhotoDeletionService` using PhotoKit change requests.
- Limited/denied/restricted access handling with Settings actions where relevant.
- Thumbnail loading for photos and videos; videos are previewed as thumbnails.
- Tap-to-fullscreen preview in the swipe review screen, with swipe decisions disabled while fullscreen is open.
- Summary screen cancellation, including the system iOS back gesture, resets the current review session and returns to cleanup modes without deleting media.
- System/Light/Dark appearance setting and System/English/Russian language setting.
- English and Russian localization folders exist.

## Current architecture notes

- UI is organized by feature under `SwipeClean/Features`.
- PhotoKit access lives in `SwipeClean/Services`.
- Simple model structs live in `SwipeClean/Models`.
- Mock data for previews lives in `SwipeClean/Shared/MockData`.
- No third-party dependencies are used.

## Safety invariants

- Never delete media during swipe.
- Swipe up only records a pending deletion decision.
- Deletion must stay behind the summary screen and final confirmation alert.
- Deletion must use PhotoKit change requests.
- Pending deletion selections should remain visible if deletion fails.

## Known issues

- No automated test status is recorded in this summary yet.
- Localization coverage should be checked when changing user-facing strings.
- Real PhotoKit behavior should be verified on an iOS simulator/device with an accessible photo library.

## Next likely tasks

- Add or update focused XCTest coverage for pure session/deletion logic.
- Verify all user-facing strings are localized in English and Russian.
- Polish accessibility and light/dark readability on the main screens.
- Keep this file updated after meaningful product, architecture, setup, or known-issue changes.
