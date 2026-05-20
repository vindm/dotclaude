# The bug surfaced five screens later than the cause

## Symptom

A test harness flow logs in, navigates through five screens, types into a form, submits, asserts "results screen visible." The assertion fails: the results screen never appears. The harness's last successful step was the form submit on screen 5. The first failing step was the assertion on screen 6.

The natural reaction: debug screen 6. Why isn't it appearing? Is the API call failing? Is the response shape wrong? Is the router stuck?

After two hours, screen 6 was demonstrably fine. The API call returned the right shape. The router was configured correctly. The next-screen render conditioned on a valid response — and the response was valid.

So why didn't it show?

## Root cause

Five screens back, on the login screen, the harness flow templated the password from an environment variable: `password: ${TEST_PASSWORD}`. The harness was run via a bare invocation that did not perform `${...}` interpolation. The template wasn't substituted. The literal string `"undefined"` was typed into the password field.

Login succeeded against the dev database (which had a seed account whose password happened to be `"undefined"`). The session was created. Every subsequent screen rendered. Every API call succeeded. Every assertion passed — until screen 6, which tried to access a field on the user object that was populated by an account-completion step. The seed account hadn't completed that step. So the field was empty. So screen 6's render condition was false. So the assertion failed.

The bug was on screen 1. The symptom was on screen 6. Every intermediate screen had succeeded, and every intermediate success had moved the corrupted state forward one step.

## Lesson

**When a test harness skips a substitution step, the corrupted value cascades through valid-shaped operations until something asserts on it.**

The five intermediate screens were all "correct" — given the inputs they received, they produced the outputs they should. None of them validated *why* the input was the value it was. That's almost always the right tradeoff (you can't have every screen re-authenticate the user), but it means the cascade can travel a long way before it hits an assertion that disagrees.

## The diagnostic that finally worked

Screenshot the screen at the moment of failure. Screenshot the screen BEFORE that one. Screenshot every screen in the flow. Look at the email/password field on the login screen.

The literal text `"undefined"` was sitting in the password field.

The harness had typed exactly what we'd told it to type. The substitution had silently failed five screens earlier. The downstream cascade was entirely consistent with valid behavior given that input.

## The discipline this produced

1. **When a test fails at step N, screenshot step 0, step N-1, step N. Cheap. Catches the entire class of "value-was-wrong-from-the-start" bugs.**
2. **Validate harness inputs at the harness boundary, not at the application boundary.** If a flow templates `${VAR}`, the harness runner should assert `VAR` is defined before it starts the flow. Failing fast at the source beats failing slow at the symptom.
3. **Run the test the same way in CI as you do locally.** This bug only reproduced via the bare invocation (no env interpolation). Local runs used a wrapper that did interpolate. The CI runner used the wrapper. The local "is this even broken?" reproduction was via the bare invocation — and that was the only path that produced the bug. The harness IS part of the system under test.

## See also

- `rules/visual-verification.md` — screenshot the screen, even when the failure looks logic-shaped. Cheap diagnostic, eliminates entire hypothesis space.
- `agents/pre-flight` — pre-implementation review that asks "what other call paths exist?" applies equally to test runners.
