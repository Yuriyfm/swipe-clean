# Review Checklist

Before accepting Codex changes:

## Scope

- Did Codex only change files related to the task?
- Did Codex avoid unrelated refactoring?
- Did Codex avoid third-party dependencies?

## Safety

- Are photos never deleted immediately after swipe?
- Is deletion only possible after confirmation?
- Are permission states handled?

## UX

- Are loading states present?
- Are empty states present?
- Is there a clear cancel path?

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
