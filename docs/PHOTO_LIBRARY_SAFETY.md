Photo deletion safety rules:

1. Swipe left never deletes a photo.
2. Swipe left only adds asset ID to pending deletion list.
3. User must see a confirmation screen before deletion.
4. Confirmation screen must show count and preview of selected photos.
5. Deletion must use PhotoKit change requests.
6. App must handle denied, limited, and full photo permissions.
7. App must not attempt to bypass iOS privacy controls.
8. App must gracefully handle iCloud/unavailable assets.