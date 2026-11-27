# Supabase cloud sync setup

1. Run schema.sql in Supabase SQL Editor. Re-running it updates the access policy and creates the allowlist table.
2. In SQL Editor, add only approved email addresses to public.tokyo_allowed_emails, for example:
   insert into public.tokyo_allowed_emails(email) values ('owner@example.com') on conflict do nothing;
   Replace the example with your approved email. Do not put personal email addresses in public GitHub files.
3. Disable public signups in Authentication → Settings. The site also requests sign-in without creating new users.
4. In Authentication → URL Configuration, set the published GitHub Pages URL as the Site URL and add it to Redirect URLs.
5. Publish index.html, supabase-config.js, and the supabase folder.
6. On each device, sign in using an existing email that appears in the database allowlist. Users not on the allowlist cannot read or write itinerary rows; editing controls remain hidden unless the authorized session can access the row.

supabase-config.js is public and should contain the Project URL and publishable key only. Never put a secret or service_role key there. Database row-level security is the actual access control; the browser UI is only a convenience layer.

Time fields use a time picker and sort in 24-hour order when saved. When two devices edit simultaneously, the most recent save wins.