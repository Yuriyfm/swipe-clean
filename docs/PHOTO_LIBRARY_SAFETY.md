Photo deletion safety rules:

1. Swipe up never deletes a photo.
2. Swipe up only adds asset ID to pending deletion list.
3. User must see a confirmation screen before deletion.
4. Confirmation screen must show count and preview of selected photos.
5. Deletion happens only after the user taps Confirm Delete and then confirms the final deletion alert.
6. Deletion must use PhotoKit change requests.
7. The deletion result must be shown to the user.
8. App must handle denied, limited, and full photo permissions.
9. App must not attempt to bypass iOS privacy controls.
10. App must gracefully handle iCloud/unavailable assets.
