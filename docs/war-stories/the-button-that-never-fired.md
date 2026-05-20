# The button that never fired

## Symptom

End-to-end test driving the app via an external automation harness. The flow logs in, navigates to a sign-up form, types email and password, taps the submit button. The harness reports `tapOn: COMPLETED` for the submit button. The assertion that follows (presence of the post-signup home screen) fails with "timeout waiting for element."

For three hours I tried every wrong hypothesis. Maybe the button's `disabled` attribute was sticky. Maybe the handler had a race with form validation. Maybe the navigation library was eating the transition. I added `console.log` lines to the handler — they never fired. I added a visible debug `<Text>` mirroring the handler's state — it never changed.

## Root cause

The OS had just shipped a new version. That version mounts an off-screen "AutoFill suggestion bar" the moment any password input gains focus. The bar is visually invisible (it's positioned above the keyboard). The harness's view hierarchy reports the submit button at coordinates X,Y. The harness taps X,Y. The OS routes the tap to the AutoFill bar's invisible child instead of the button below. `tapOn` reports `COMPLETED` because the OS confirmed *something* received the event. The button's `onPressIn` was never called.

## The diagnostic that finally worked

I added a visible `<Text testID="signup-handler-state">{stage}</Text>` to the screen, where `stage` was a state variable advanced by each line of the handler. Re-running the harness, I watched the text never change from its initial value. That ruled out 90% of my hypotheses — the handler wasn't being entered at all. With that narrowed scope I could ask: "what could intercept a tap between the harness and the React Native component?" The OS-version-specific autofill bar was the first answer I'd believe.

## Lesson

**When the harness reports success and the handler never fires, something is between them.**

- Modal scrims that don't render visibly
- Off-screen system-level overlays (autofill, accessibility shortcuts)
- A parent `<Pressable>` swallowing the child's `onPress`
- A `<Modal>` whose backdrop intercepts the tap
- Reanimated `entering={...}` animations that haven't finished and absorb events

Stop trying to debug the handler. Start asking what's between the input and the handler.

## The discipline this produced

Every E2E flow now embeds an invisible `<Text testID="handler-state">` mirror on the surface under test. The harness asserts on that text after the tap. If the text never changes, the tap never reached the handler — and that's a fundamentally different bug from "the handler ran and produced the wrong state."

This costs three lines of code per screen. It would have saved three hours on this bug. It will save more on the next one.

## See also

- `interaction-audit` agent — pre-ship audit that asks "does this affordance fire its handler?" before the test harness has to.
