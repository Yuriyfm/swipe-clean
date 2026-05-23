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
- Screenshots-only and videos-only review modes

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
