# Development Plan

## Stage 0. Environment setup

Goal: the project opens in Xcode and runs in the iOS simulator.

Expected result:

- Xcode installed
- New SwiftUI iOS project created
- Git repository initialized
- AGENTS.md added
- Docs added
- Empty app runs successfully

## Stage 1. App skeleton

Goal: build navigation and screen structure without PhotoKit or real photos.

Screens:

- OnboardingScreen
- CleanupModesScreen
- MonthListScreen
- SwipeSessionScreen
- CleanupSummaryScreen

At this stage the app uses only mock cards and mock month data.

This is important because the UX and architecture should be validated before connecting the sensitive Photo Library functionality.

## Stage 2. Photo Library permissions

Goal: request Photo Library access and show the correct UI for each permission state:

- notDetermined
- authorized
- limited
- denied
- restricted

Add the required privacy description to Info.plist. iOS requires apps to explain why they need access to the user's photos before the system permission dialog is shown.

## Stage 3. Load media grouped by month

Goal:

- Fetch assets from PhotoKit
- Group assets by year-month
- Show a month list
- Show media item count for each month
- Include photos and videos, but do not load full-size media during grouping

There is still no deletion in this stage.

## Stage 3.5. Cleanup modes

Goal:

- Let the user choose Monthly Review, All Media, Screenshots, or Videos.
- Monthly Review uses the existing month list.
- All Media starts one session with all available photos and videos.
- Screenshots starts one session with image assets whose PhotoKit subtype is `photoScreenshot`.
- Videos starts one session with video assets only.
- All modes use the same swipe session, summary screen, final confirmation alert, and PhotoKit deletion service.
- Videos are previewed as thumbnails, not played.

## Stage 4. Swipe session

Goal:

- Show photos and videos one at a time
- Swipe down = keep
- Swipe up = mark as pending deletion
- Videos are previewed as thumbnails, not played
- Show progress
- Store decisions in the current session state

There is still no deletion in this stage.

## Stage 5. Summary before deletion

Goal:

- Show the number of media items marked for deletion
- Show previews of selected photos and videos
- Provide a Cancel button
- Provide a Confirm Delete button

This is the key safety screen. An upward swipe only marks a media item as pending deletion; the app must not request deletion before this confirmation step.

## Stage 6. Real deletion through PhotoKit

Goal:

- Run only after Confirm Delete and the final deletion alert confirmation
- Use a PhotoKit change request
- Handle success and errors
- Show the result to the user
- After success, return to the month list and reload media item counts

Apple performs Photo Library create, delete, and update operations through change requests. For this app, deletion must always happen through that system-controlled flow.
Photos and videos must never be deleted during swipe, when entering the summary screen, or in the background.

## Stage 7. Simple gamification

Goal: make cleanup sessions feel clearer and more rewarding without pressure mechanics.

Included:

- Progress bar
- Reviewed count and total count
- Calm progress messages
- Completion feedback on the summary screen
- Session-local achievement-style messages

Not included:

- Persistent achievements
- Streaks
- Points
- Daily challenges
- Push notifications
- "You saved 120 MB" unless the app can calculate storage size correctly later

## Stage 8. Polish

- Empty states
- Permission denied state
- Limited library explanation
- Loading states
- Error states
- System, Light, and Dark appearance setting
- Dark mode and light mode readability checks for all main screens
- Basic accessibility
- Basic tests for pure logic

Appearance settings must not affect media safety or deletion flow. Deletion remains limited to the final confirmation flow and PhotoKit deletion service.
