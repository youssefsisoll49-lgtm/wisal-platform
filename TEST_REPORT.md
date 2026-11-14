# WISAL verification report

Date: 2026-11-14

## Checks completed

- Supabase project status: `ACTIVE_HEALTHY` (PostgreSQL 17.11).
- JavaScript syntax: inline scripts in `index.html` and `delete-account.html` pass `node --check`.
- Row Level Security: enabled on all public tables reviewed. No anonymous table privileges were found on the core member tables.
- Authentication: recent logs show successful email sign-up, email confirmation, and password login events.
- Account deletion: the `delete-account` Edge Function is active, requires a valid JWT, validates the caller, and deletes only that caller's Auth user. The profile and user-linked records reviewed use cascading deletion.
- Database health advisor: no health lints.
- Simulated two-account flow (all fixture changes rolled back): first like remains pending; mutual like creates a match and conversation; message send decrements the free quota; recipient can read and mark the message read; phone request requires a match and a saved private phone; owner approval permits phone retrieval; reporting works; blocking closes the conversation and makes phone retrieval unavailable.
- Notification triggers: like, mutual match, message, phone approval, phone refusal, and phone-sharing revocation notifications all passed transactional tests.
- Skip RPC: rejects an incomplete/non-visible member before inserting a skip.
- No test profiles, test messages, test phone numbers, likes, matches, reports, or notifications were left in production after rollback.

## Fixes applied to production and recorded as migrations

- Align supported gender preference values with the profile search UI.
- Require an adult, complete, searchable member profile before search and public profile-detail retrieval.
- Notify the requester when phone sharing is approved, declined, or revoked.
- Permit those phone-decision event types in the notification constraint.
- Harden the skip RPC to require both members to be adults and searchable and to respect blocks.

## Remaining release blockers

1. The live Netlify site currently serves a landing page, but `privacy.html` and `delete-account.html` return HTTP 404. The GitHub source has these files, but this deployment has not been updated/verified from that source.
2. A browser-driven live UI test could not be run because the available browser automation wallet has insufficient balance. No account was created or changed by that attempt.
3. Supabase leaked-password protection remains disabled and must be enabled in Auth security settings.
4. Supabase security advisor still reports 16 authenticated-callable SECURITY DEFINER RPCs. Their definitions were reviewed for caller/ownership checks; these warnings should be re-reviewed during final security sign-off. Two RLS/no-policy notices apply to service/RPC-only tables.
5. Legal privacy wording is still provisional: operator identity, retention periods, jurisdiction-specific rights, and support/contact channel require final review.
6. A full browser test with two real, separately controlled accounts and an end-to-end account-deletion test remain outstanding.
7. Planned features such as full localization, translated chat, country-specific marriage-document guidance, family participation workflow, and verified rewarded-ad integration are not complete.

## Release decision

**Not ready for public launch yet.** Database-side core flows have passed simulated transactional tests, but the live deployment, auth hardening, legal review, and real two-account browser test must be completed first.
