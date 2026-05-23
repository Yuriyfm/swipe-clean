App architecture:

- SwiftUI views for UI
- Observable state objects / view models for screen state
- PhotoLibraryService for PhotoKit access
- SwipeSessionStore for current session state
- Simple model structs for MonthGroup, PhotoAsset, SwipeDecision

Example project structure:

```text
SwipeClean/
  App/
    SwipeCleanApp.swift

  Features/
    Onboarding/
    MonthList/
    SwipeSession/
    CleanupSummary/

  Services/
    PhotoLibraryService.swift

  Models/
    PhotoAsset.swift
    MonthGroup.swift
    SwipeDecision.swift

  Shared/
    Components/
    Extensions/
```
