# WISAL — وِصال

A serious, privacy-focused Muslim marriage platform. The product is intended for adults (18+) seeking marriage, not casual dating.

## Static site deployment

This repository is a static Netlify Drop site. Publish the repository root:

- Build command: none
- Publish directory: `.`
- Required root files: `index.html`, `privacy.html`, `delete-account.html`, `_headers`

The Supabase browser client uses the project's public publishable key. Never put a Supabase service-role or secret key in this repository or any browser code.

## Supabase services

- Authentication and database: Supabase project `yatcvycflojzwcbjyobe`
- Account deletion: Edge Function `delete-account` (JWT verification enabled)
- The Edge Function requires server-side Supabase environment variables, including the service-role key. These must remain in Supabase Function Secrets and must never be copied into this repository.

## Current release checks

Before a public launch, verify all of the following on the deployed domain:

1. Home page, privacy page, and account-deletion page return HTTP 200.
2. Register two independent adult test accounts and confirm email verification / sign-in.
3. Complete profiles, keep visibility off by default, then explicitly enable search.
4. Confirm search only returns adult, visible profiles and excludes blocked/skipped members.
5. Test mutual likes, match creation, conversation access, messaging quota, and read receipts.
6. Confirm phone numbers are never exposed before the number owner approves a specific request; test revoke.
7. Test reports, block/unblock, notification ownership, and account deletion end-to-end.
8. Inspect Supabase Security and Performance Advisors; document any intentional warnings.
9. Complete legal/privacy review for every launch country and configure support/contact details.

## Important status

This repository is a release candidate, not a declaration that WISAL is production-ready. The source files and Supabase backend require deployment verification and two-account end-to-end testing before public launch.
