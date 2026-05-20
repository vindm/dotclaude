# Design north star — Telegram + Apple iOS 26

Every user-facing surface is graded against **Apple's iOS 26 native chrome and Telegram on iOS 26**. Not "premium SaaS." Not "WHOOP-style." Apple + Telegram. Specifically.

This isn't aesthetic preference — it's a calibrated decision about who your users compare you against. Mobile users run their lives from an iPhone they already use for Apple Music, Photos, Messages, Telegram, Wallet. Anything in your UI that reads as "another React Native app" instead of "iOS-native" gets benchmarked unfavorably the moment they open it.

## What "North Star" means concretely

When making a UI decision, the question is **"would Apple or Telegram do this on iOS 26?"** If the answer is no, redesign. If unclear, screenshot the equivalent surface in Apple Music / Photos / Settings / Wallet OR Telegram, and copy the pattern.

Surfaces this rule binds:

| Surface | iOS 26 reference |
|---|---|
| Tab bar | Native `UITabBar` (Liquid Glass pill, floating, refractive). Use `<NativeTabs>` from `expo-router/unstable-native-tabs`. **Do NOT roll your own RN-rendered tab bar with custom blur** — every attempt fails the comparison test. |
| Cards / list rows | Apple Settings rows, Telegram settings rows — generous vertical padding, hairline dividers, tappable rows with chevrons, restrained color. |
| Chrome surfaces (sheet headers, modal backdrops, floating buttons, chat bubble assistant turns) | Telegram-iOS-style solid neutral card + hairline border + accent-tint blend by default. iOS 26 `UIGlassEffect` adapts to dark canvas → invisible chrome with passthrough blur on every flat-canvas surface. Use real glass only on photographic / camera backdrops (see "Per-surface glass" below). |
| Sheets | UIKit-native bottom sheets with **solid** dark background by default. Apple's Settings / Telegram's settings sheet is the reference, NOT Music's Now Playing (busy-photo-backdrop case). |
| Modal alerts | Apple's iOS 26 `UIAlertController` aesthetic — thick glass, rounded, tight typography. |
| Empty states | Apple Photos memories — never apologize, always teach or invite. |
| Motion | Apple's interactive transitions — UIKit spring physics, never linear. Reanimated 4 spring presets only. |
| Color | iOS 26 system colors (semantic tokens). Restraint: one accent, one destructive, everything else neutral grays. Telegram's discipline is the reference. |
| Typography | Apple's system fonts (SF Pro on iOS) for chrome. Branded display fonts are acceptable for content but never compete with the system for chrome weight. |
| Iconography | SF Symbols on iOS chrome (`<NativeTabs.Trigger.Icon sf="..." />`). Lucide is the FALLBACK for Android + content icons; never for iOS chrome. |

## Anti-patterns (specific things this rule rejects)

- **Custom RN-rendered chrome trying to fake iOS** — every attempt fails the Apple-or-Telegram test on the first screenshot. Use native primitives (`NativeTabs`, `UIGlassEffect`, `BottomSheetModal` with solid bg).
- **`expo-blur` with custom tints** — it's the legacy `UIBlurEffect` API, doesn't get Liquid Glass. Use a real glass primitive (or solid card chrome) for everything chrome.
- **Wrapping app chrome in real `UIGlassEffect`** — against a near-black canvas, iOS 26's material adapts down to invisible glass with the *content behind it* showing through as a blurred smudge (chat bubbles become unreadable text smudges; map overlays disappear). System-rendered `<NativeTabs>` UITabBar is the only surface that uses real glass successfully — because it's over scrolling content, which is what the material is designed for. Until per-surface opt-in glass ships for over-camera / over-photo backdrops, keep chrome solid.
- **Heavy shadows / drop-shadow stacks** — iOS 26 doesn't shadow chrome heavily; the glass material's edge highlight + ambient occlusion does the depth work.
- **Multiple competing accent colors** — one color is THE accent. Use neutrals for everything else. Telegram does this; you should too.
- **"Material You" / Android-y card stacking** — iOS-first apps render cards as flat translucent surfaces, not stacked elevated paper.
- **Dense/tight tap targets** — Apple's HIG is 44pt minimum. Telegram is generous on iOS. Don't pack.

## Verification checklist

Before claiming "done" on any user-facing surface:

1. Open Apple's nearest-equivalent screen (Music, Settings, Photos, Wallet, App Store) — screenshot it.
2. Open Telegram's nearest-equivalent screen if applicable — screenshot it.
3. Compare side-by-side with your screen.
4. Name 1 thing you do better, 1 thing they do better, 1 thing you should fix to close the gap.
5. If you can't honestly claim parity on any non-trivial chrome dimension (material, motion, typography hierarchy, color discipline, tap targets, copy tone), it's not done.

## Where to find primitives

- **Native tab bar** — wrap `expo-router/unstable-native-tabs`. The ONE surface in the app that uses real iOS 26 Liquid Glass successfully (system-rendered, over scrolling content).
- **Solid card chrome** — a `<GlassCard>`-style primitive that preserves a glass-shaped API (variant / tintColor / cornerRadius / elevated) while rendering solid by default. Future per-surface opt-in can flip to real glass.
- **Native bottom sheet** — wrap `UISheetPresentationController` via expo-router `presentation: 'formSheet'` or `@gorhom/bottom-sheet` — with solid card backing.
- **Confirm dialog** — a `useConfirmDialog()` hook backed by solid card chrome.
- **Floating SF Symbol icons in chrome** — pass `sf="..."` on `<NativeTabs.Trigger.Icon>`. For non-chrome SF Symbols (compass rose, coverage toggle, etc.), use `expo-symbols` `<SymbolView>` directly.

When you need new chrome, check whether one of these primitives already gives it before rolling your own.

## Per-surface glass revival (when, if ever)

A solid-by-default chrome primitive can keep a glass-shaped API on purpose so a future per-surface opt-in can flip individual chrome elements back to real `UIGlassEffect` if the backdrop justifies it. Two cases qualify today:

- **Over-camera HUD** — pills floating over an AR / camera feed. Live photographic content gives `UIGlassEffect` something to refract.
- **Over-photo cards** — dashboard / detail chrome positioned on top of an actual image (user-uploaded photo, product hero shot).

Everything else (sheet headers on dark canvas, dialog backdrops over the app bg, list-row chrome) stays solid.

When piloting glass on a single surface, do it via a NEW `variant="glass"` opt-in — not by reverting the default impl.
