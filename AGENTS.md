## Project

Native iOS app for cleaning the user's photo library by month using swipe gestures.

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

- Never delete photos immediately after a swipe.
- An upward swipe only marks a photo as pending deletion.
- Actual deletion must happen only after the final confirmation screen.
- Prefer safe, reversible, user-confirmed flows.
- Do not add third-party dependencies unless explicitly requested.

## Code style

- Keep changes small and focused.
- Prefer simple SwiftUI architecture.
- Avoid premature abstraction.
- Avoid large refactors unless explicitly requested.
- Use clear names and comments for iOS-specific concepts.

## After every task

Report:
- changed files
- what was implemented
- how to test manually
- risks or open questions
