# SwipeClean

SwipeClean is a native iOS MVP for reviewing and cleaning up a photo and video library with safe swipe-based decisions.

The app is built with SwiftUI and PhotoKit. It focuses on a cautious flow: swipes only mark media items locally, and real deletion happens only after a summary screen and a final system-confirmed action.

## Features

- Photo Library permission flow with support for full, limited, denied, and restricted access.
- Cleanup modes:
  - Monthly Review
  - All Media
  - Screenshots
  - Videos
- Vertical swipe session:
  - swipe down to keep
  - swipe up to mark for deletion
- Undo for the last swipe decision.
- Real photo and video thumbnail previews.
- Media cards adapt to portrait, landscape, square, very wide, and very tall aspect ratios.
- Summary screen with selected deletion previews.
- Real PhotoKit deletion after final confirmation.
- Month list refresh after successful deletion.
- System, Light, and Dark appearance settings.
- English and Russian localization.
- Calm session progress and completion feedback.

## Safety Model

SwipeClean is designed around explicit confirmation.

- Swiping up does not delete anything.
- Swiping up only marks a photo or video as pending deletion in the current session.
- The user must review the summary before deletion.
- The user must tap `Confirm Delete`.
- The user must confirm the final deletion alert.
- Only then does the app call PhotoKit deletion APIs.
- Deleted items are moved to Recently Deleted in the Photos app.

PhotoKit mutation APIs are isolated in:

```text
SwipeClean/Services/PhotoDeletionService.swift
```

## Tech Stack

- Swift
- SwiftUI
- PhotoKit
- Xcode project
- Native iOS localization files

No third-party dependencies are used.

## Project Structure

```text
SwipeClean/
  App/
    SwipeCleanApp.swift

  Features/
    Onboarding/
    CleanupModes/
    MonthList/
    SwipeSession/
    CleanupSummary/
    Settings/

  Models/
    AppLanguage.swift
    AppTheme.swift
    MonthGroup.swift
    PhotoAsset.swift
    SwipeDecision.swift

  Services/
    PhotoLibraryService.swift
    PhotoThumbnailService.swift
    PhotoDeletionService.swift
    PhotoLibraryAccessHelper.swift

  Shared/
    MockData/

docs/
  PRODUCT_SPEC.md
  ARCHITECTURE.md
  DEVELOPMENT_PLAN.md
  PHOTO_LIBRARY_SAFETY.md
  REVIEW_CHECKLIST.md
  IOS_BEGINNER_GUIDE.md
```

## How to Run

1. Open the project in Xcode:

   ```text
   SwipeClean.xcodeproj
   ```

2. Select an iOS Simulator or a real device.

3. Build and run the app from Xcode.

4. Grant photo library access when prompted.

For the most realistic testing, use a real device or a simulator with test photos and videos.

## Manual Test Flow

1. Launch the app.
2. Grant full or limited photo library access.
3. Choose a cleanup mode.
4. Review media with vertical swipes.
5. Use Undo to verify the last decision can be reverted.
6. Finish the session.
7. Review the summary screen.
8. Confirm deletion only on test media.
9. Verify the app shows success or failure clearly.
10. Return to the month list and confirm counts refresh.

## Permissions

SwipeClean requests Photo Library access because it needs to list media and show thumbnails for review.

Supported states:

- not determined
- authorized
- limited
- denied
- restricted

Limited access is supported. In limited mode, the app only reviews media selected by the user in iOS photo permissions.

## Localization

Supported language modes:

- System
- English
- Russian

Localization files:

```text
SwipeClean/en.lproj/Localizable.strings
SwipeClean/ru.lproj/Localizable.strings
SwipeClean/en.lproj/InfoPlist.strings
SwipeClean/ru.lproj/InfoPlist.strings
```

## Appearance

Supported appearance modes:

- System
- Light
- Dark

The theme setting affects only UI appearance. It does not change permissions, swipe decisions, or deletion behavior.

## Current MVP Limitations

- No cloud sync.
- No accounts.
- No subscriptions.
- No analytics.
- No duplicate detection.
- No AI features.
- No video playback.
- No background cleanup.
- No automatic deletion.

## Documentation

The main product and safety docs are in `docs/`:

- `docs/PRODUCT_SPEC.md`
- `docs/PHOTO_LIBRARY_SAFETY.md`
- `docs/DEVELOPMENT_PLAN.md`
- `docs/REVIEW_CHECKLIST.md`

Read `docs/PHOTO_LIBRARY_SAFETY.md` before changing deletion behavior.
