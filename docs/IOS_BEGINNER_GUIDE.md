# iOS Beginner Guide for Codex

The project owner is not an iOS developer.

When introducing Swift/iOS concepts, explain them using frontend analogies:

- SwiftUI View ≈ Vue component
- @State ≈ local reactive state
- @StateObject / @Observable ≈ component-owned store
- @Environment ≈ dependency/context injection
- PhotoKit ≈ browser API for media library, but with stricter permissions
- Info.plist permissions ≈ browser permission declarations + app manifest

Avoid assuming deep knowledge of:
- Xcode project structure
- provisioning profiles
- Apple signing
- Swift concurrency
- PhotoKit internals
