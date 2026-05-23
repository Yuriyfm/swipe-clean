# Product Spec

## App idea

Swipe-based photo cleanup app for iOS.

## Main user flow

1. Request photo library access.
2. Load photo library grouped by month.
3. Show months with photo counts.
4. User selects a month.
5. App starts a swipe session.
6. User swipes each photo:
   - down = keep
   - up = mark for deletion
7. App shows session summary.
8. User confirms deletion.
9. App requests system photo deletion.
10. App shows result.

## MVP scope

Included:
- Photo permission screen
- Month list
- Swipe session
- Keep/delete decisions
- Final confirmation
- Safe deletion request
- Basic progress/gamification

Not included:
- Cloud sync
- Accounts
- Subscriptions
- AI duplicate detection
- Video cleanup
- Social sharing
- Advanced analytics
