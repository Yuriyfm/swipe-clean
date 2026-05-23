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

## Stage 3. Load photos grouped by month

Goal:

- Fetch assets from PhotoKit
- Group assets by year-month
- Show a month list
- Show photo count for each month

There is still no deletion in this stage.

## Stage 4. Swipe session

Goal:

- Show photos one at a time
- Swipe down = keep
- Swipe up = mark as pending deletion
- Show progress
- Store decisions in the current session state

There is still no deletion in this stage.

## Stage 5. Summary before deletion

Goal:

- Show the number of photos marked for deletion
- Show previews of selected photos
- Provide a Cancel button
- Provide a Confirm Delete button

This is the key safety screen. An upward swipe only marks a photo as pending deletion; the app must not request deletion before this confirmation step.

## Stage 6. Real deletion through PhotoKit

Goal:

- Run only after Confirm Delete
- Use a PhotoKit change request
- Handle success and errors
- Show the result to the user

Apple performs Photo Library create, delete, and update operations through change requests. For this app, deletion must always happen through that system-controlled flow.

## Stage 7. Simple gamification

Do not start with this stage. Add it only after the basic cleanup flow works.

Ideas:

- Progress bar
- Streak counter
- Month completed state
- "You reviewed 84 photos"
- "You saved 120 MB" only if the app can calculate storage size correctly

## Stage 8. Polish

- Empty states
- Permission denied state
- Limited library explanation
- Loading states
- Error states
- Basic accessibility
- Basic tests for pure logic
