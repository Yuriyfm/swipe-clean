# Product Spec

## App idea

Swipe-based photo and video cleanup app for iOS.

## Main user flow

1. Request photo library access.
2. User chooses a cleanup mode:
   - Monthly Review
   - All Media
   - Screenshots
   - Videos
3. App loads the selected media set.
4. Monthly Review shows months with media item counts; other modes start one swipe session.
5. App starts a swipe session.
6. User swipes each media item:
   - down = keep
   - up = mark for deletion
7. App shows session summary.
8. User reviews media items marked for deletion.
9. User taps Confirm Delete and confirms the final deletion alert.
10. App requests system media deletion through a PhotoKit change request.
11. App shows result.
12. After successful deletion, user returns to the refreshed month list.

## MVP scope

Included:
- Photo Library permission screen
- Cleanup mode selection
- Month list
- Swipe session
- Keep/delete decisions
- Final confirmation
- Safe deletion request
- Light progress and session-local completion feedback
- Photo and video thumbnail previews
- Swipe cards that adapt to photo and video aspect ratio
- Screenshots-only and videos-only review modes
- System, Light, and Dark appearance setting
- English and Russian localization with a language setting

Not included:
- Cloud sync
- Accounts
- Subscriptions
- AI duplicate detection
- Social sharing
- Advanced analytics
- Streaks, points, daily challenges, push notifications, or pressure mechanics

## Light gamification

SwipeClean uses calm session feedback:

- session title, reviewed count, total count, and progress bar during review
- short progress messages such as "Getting started", "Nice progress", and "Almost done"
- completion feedback on the summary screen
- session-local achievement-style messages such as "Clean sweep", "Ready for review", and "Big review session"

These messages are not persisted. The app does not use streaks, points, daily challenges, notifications, or addictive mechanics.

## Appearance

SwipeClean supports three app appearance settings:

- System: follows the current iOS appearance
- Light: forces light appearance
- Dark: forces dark appearance

Theme selection is a visual preference only. It does not change Photo Library permissions, media loading, swipe decisions, deletion confirmation, or PhotoKit deletion behavior.

## Localization

SwipeClean supports English and Russian. The language setting is available in Settings:

- System: follows the current iOS language
- English: forces English app text
- Russian: forces Russian app text

All user-facing app strings should be localized, including permission messages, cleanup modes, empty states, swipe controls, summary copy, and deletion confirmation text. Language selection is a UI preference only and does not change media safety or deletion behavior.

## Permissions and Empty States

SwipeClean explains photo library access states clearly:

- Denied or restricted access shows a helpful message and an Open Settings action.
- Limited access is allowed and explained as a non-blocking state.
- Users with limited access can open Settings to manage selected photos.
- Empty cleanup modes show mode-specific messages for no accessible media, no screenshots, or no videos.
- If deletion fails because full access is required, pending deletion previews remain visible and the user can open Settings or retry.
