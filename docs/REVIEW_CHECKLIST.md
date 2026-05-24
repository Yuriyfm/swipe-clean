# Review Checklist

Before accepting Codex changes:

## Scope

- Did Codex only change files related to the task?
- Did Codex avoid unrelated refactoring?
- Did Codex avoid third-party dependencies?

## Safety

- Are photos and videos never deleted immediately after swipe?
- Is deletion only possible after confirmation?
- Is deletion triggered only from the summary screen after the final alert confirmation?
- Is the deletion result shown to the user?
- Does the month list refresh after successful deletion?
- Are permission states handled?
- Does denied or restricted access show a clear Open Settings action?
- Is limited access explained without blocking cleanup?
- Can limited-access users manage selected photos when supported?
- Are videos shown as thumbnails without full-size media preloading?
- Do all cleanup modes use the same final deletion confirmation flow?
- Are gamification messages session-local and free of streaks, points, daily challenges, or push notifications?

## UX

- Are loading states present?
- Are empty states present?
- Are empty states specific to Monthly Review, All Media, Screenshots, and Videos?
- Is there a clear cancel path?
- Is session progress readable without relying only on color?
- Does undo update reviewed count and progress correctly?
- Can the user choose System, Light, and Dark appearance from Settings?
- Can the user choose System, English, and Russian language from Settings?
- Are all main screens readable in both Light and Dark appearance?
- Does theme selection leave media safety and deletion flow unchanged?
- Are all user-facing strings localized in English and Russian?
- Is deletion confirmation copy localized and still clear about final confirmation?

## Code

- Does the app build?
- Are names clear?
- Is business logic separated from UI where reasonable?

## Explanation

Codex must explain:
- what changed
- why it changed
- how to test manually
- known risks
