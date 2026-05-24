## Project

Native iOS app for cleaning the user's photo and video library by month using swipe gestures.

## Developer context

The project owner is experienced with JavaScript, TypeScript, Vue/Nuxt, and frontend architecture, but is new to native iOS development.

When making iOS-specific decisions, explain them briefly in frontend-friendly terms.

## Stack

- Swift
- SwiftUI
- PhotoKit
- XCTest
- Xcode project

## Core product rules

- Never delete photos or videos immediately after a swipe.
- An upward swipe only marks a media item as pending deletion.
- Actual deletion must happen only after the final confirmation screen.
- Prefer safe, reversible, user-confirmed flows.
- Do not add third-party dependencies unless explicitly requested.

## Code style

- Keep changes small and focused.
- Prefer simple SwiftUI architecture.
- Avoid premature abstraction.
- Avoid large refactors unless explicitly requested.
- Use clear names and comments for iOS-specific concepts.

## Build and Xcode

- Do not search for Xcode installations.
- Do not attempt to build the app with Xcode or command-line build tools.
- The project owner will build and run the app manually.
- When verification is needed, describe the manual Xcode checks instead of running a build.

## Context budget

- Do not read all docs by default.
- First inspect file names and search with `rg`.
- Read only the docs relevant to the current task.
- Prefer reading narrow sections instead of whole files when possible.
- Do not paste large code or doc excerpts back to the user unless requested.
- Keep iOS explanations short: 1-2 frontend-friendly sentences only when introducing or changing an iOS-specific concept.
- Keep final reports concise and avoid repeating unchanged project rules.

## Docs reading guide

Use these docs only when relevant:

- `docs/PRODUCT_SPEC.md`: product behavior, MVP scope, UX rules, localization, appearance.
- `docs/PROJECT_STATE.md`: current implementation status, known issues, and likely next tasks.
- `docs/PHOTO_LIBRARY_SAFETY.md`: deletion, PhotoKit permissions, pending deletion safety.
- `docs/ARCHITECTURE.md`: intended app structure and naming.
- `docs/DEVELOPMENT_PLAN.md`: roadmap/stage planning only; do not read for small implementation tasks unless the task asks about roadmap.
- `docs/REVIEW_CHECKLIST.md`: use for code reviews or before larger changes.
- `docs/IOS_BEGINNER_GUIDE.md`: use only when explaining Swift/iOS concepts to the project owner.
- `docs/TASKS.md`: use only for task tracking if it contains active tasks.

## Project state summary

- At the start of a new task, read `docs/PROJECT_STATE.md` first if the task depends on current project status.
- Keep `docs/PROJECT_STATE.md` concise: it is a current-state summary, not a changelog.
- Update `docs/PROJECT_STATE.md` after tasks that change product behavior, architecture, major files, setup, or known issues.
- Do not update `docs/PROJECT_STATE.md` for tiny cosmetic changes, typo fixes, or one-off investigation unless project status changed.

## After every task

Report:
- changed files
- what was implemented
- how to test manually
- risks or open questions
