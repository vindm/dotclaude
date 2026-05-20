# The write that returned success and changed nothing

## Symptom

User signs up. The signup flow writes a row to `user_profiles` with the user's chosen display name. Local dev: works. Staging: works. Production: the row appears in the database, but the `display_name` column is empty. Not null — empty string. Every prod user.

The signup handler upserts the profile after auth. The upsert call returns `{ data: null, error: null }`. No exception. No warning. The handler logs "profile written." The next screen renders. The user proceeds. Days later, support tickets start coming in: "why does my profile show no name?"

## Root cause

The `user_profiles` table had a row-level-security policy that allowed writes only from the privileged service role. The auth-callback handler in our codebase had originally used the privileged client for the upsert. During a routine refactor, someone replaced it with the standard user-scoped client — the same pattern used everywhere else for user-owned mutations. The lint passed. The types passed. The test (mocked) passed.

In production, the user-scoped client's JWT couldn't satisfy the policy. The database silently no-op'd the write, returned a successful response shape (`{ data: null, error: null }`), and the call site interpreted that exactly as the documentation promised: "no error, write succeeded." It hadn't.

The local dev environment didn't reproduce because dev was running migrations + seeds as the privileged role, and our local database config defaulted everything to the service key. The RLS policy was technically enforced but trivially bypassed. We were never exercising the production code path.

## The diagnostic that finally worked

After the third support ticket I added a paranoid post-write: after every upsert that should produce a row, immediately re-query for that row. The re-query returned empty. That was the first signal the write hadn't actually persisted. From there, RLS policy inspection was the obvious next step.

## Lesson

**At trust boundaries (RLS, role-based access, capability tokens), the write API can succeed-shaped while doing nothing.**

This is the most pernicious class of bug in any system with row-level security. The response shape says "OK." The database silently dropped the row on the floor. There is no exception to catch. There is no log to grep.

## The discipline this produced

Three rules now hold in our codebase:

1. **Service-role writes go through an explicitly-named privileged client.** No silent fallback. The call site reads `adminDb.from(table).upsert(...)` (or your stack's equivalent) and is grep-able as a privileged path.

2. **For non-trivial writes to RLS-protected tables, the handler re-queries the row immediately and asserts it exists.** The cost is one extra round-trip; the win is that silent no-ops become loud failures.

3. **Local dev runs as a user, not as the service role.** The test environment must reproduce the production trust boundary, or every RLS bug ships invisible.

## See also

- `rules/database-query-discipline.md` — the broader CLI-over-LLM-tool discipline; the RLS-no-op trap is one specific instance of "trust the response shape less than you think."
