# WISAL verification report

Date: 2026-11-14

## Checks completed

- Supabase project status: `ACTIVE_HEALTHY` (PostgreSQL 17.11).
- JavaScript syntax: inline scripts in `index.html` and `delete-account.html` pass `node --check`.
- Row Level Security: enabled on all public tables reviewed. No anonymous table privileges were found on the core member tables, except an overbroad grant on notifications found in the final audit and revoked as described below.
- Authentication: recent logs show successful email sign-up, email confirmation, and password login events.
- Account deletion: the `delete-account` Edge Function is active, requires a valid JWT, validates the caller, and deletes only that caller's Auth user. The profile and user-linked records reviewed use cascading deletion.
- Database health advisor: no health lints.
- Simulated two-account flow (all fixture changes rolled back): first like remains pending; mutual like creates a match and conversation; message send decrements the free quota; recipient can read and mark the message read; phone request requires a match and a saved private phone; owner approval permits phone retrieval; reporting works; blocking closes the conversation and makes phone retrieval unavailable.
- Notification triggers: like, mutual match, message, phone approval, phone refusal, and phone-sharing revocation notifications all passed transactional tests.
- Skip RPC: rejects an incomplete/non-visible member before inserting a skip.
- No test profiles, test messages, test phone numbers, likes, matches, reports, or notifications were left in production after rollback.
- Final privilege audit: all reviewed public/private tables have RLS enabled. The private contact table is not granted to `anon` or `authenticated`; its access is mediated by guarded functions.
- Final privilege audit found excess `REFERENCES`, `TRIGGER`, and `TRUNCATE` grants on `public.member_notifications` for `anon` and `authenticated`. Migration `20261114022813` revoked those privileges. Re-query confirmed that `anon` has no table privileges and `authenticated` retains only `SELECT`, which remains governed by RLS.
- All 16 SECURITY DEFINER functions callable by `authenticated` were inspected. Each has an authentication/ownership guard; the two admin RPCs require the trusted `app_metadata.role = 'admin'` claim. Service-only reward grant, auth trigger, and RLS event-trigger functions are not executable by `anon` or `authenticated`. The advisor still flags these 16 by design because they are exposed authenticated RPCs; keep them under review rather than blindly removing execution rights needed by the app.

## Fixes applied to production and recorded as migrations

- Align supported gender preference values with the profile search UI.
- Require an adult, complete, searchable member profile before search and public profile-detail retrieval.
- Notify the requester when phone sharing is approved, declined, or revoked.
- Permit those phone-decision event types in the notification constraint.
- Harden the skip RPC to require both members to be adults and searchable and to respect blocks.
- Revoke excess table-level `REFERENCES`, `TRIGGER`, and `TRUNCATE` privileges from `anon` and `authenticated` on `public.member_notifications`.

## Remaining release blockers

1. The live Netlify site currently serves the older landing page, and `privacy.html` and `delete-account.html` return HTTP 404. The GitHub source has these files, but the deployment has not been updated/verified from that source.
2. A browser-driven live UI test could not be run because the available browser automation wallet has insufficient balance. No account was created or changed by that attempt.
3. The Supabase security advisor reports leaked-password protection disabled. Current Supabase documentation states this feature is available on Pro plan and above. No paid upgrade has been made or recommended; if the project is on Free, this setting cannot be enabled without changing plans.
4. Supabase security advisor still reports 16 authenticated-callable SECURITY DEFINER RPCs. Their definitions were reviewed for caller/ownership checks; two RLS/no-policy notices apply to service/RPC-only tables. These are documented for final security sign-off.
5. Legal privacy wording is still provisional: operator identity, retention periods, jurisdiction-specific rights, and support/contact channel require final review.
6. A full browser test with two real, separately controlled accounts and an end-to-end account-deletion test remain outstanding.
7. Planned features such as full localization, translated chat, country-specific marriage-document guidance, family participation workflow, and verified rewarded-ad integration are not complete.

## Release decision

**Not ready for public launch yet.** Database-side core flows have passed simulated transactional tests, and the additional notification-table privilege issue has been fixed and verified. The live deployment, available auth hardening, legal review, and real two-account browser test must still be completed first.
