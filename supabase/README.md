# Supabase cloud sync setup

1. Create a Supabase project.
2. In **SQL Editor**, run [`schema.sql`](./schema.sql). This creates one private itinerary row per authenticated user, enables row-level security, and adds the table to Realtime.
3. In **Project Settings → API**, copy the Project URL and the **publishable** key into `supabase-config.js` at the project root.
4. In **Authentication → URL Configuration**, set the published GitHub Pages URL as the Site URL and add it to Redirect URLs. Enable email OTP / magic links.
5. Publish `index.html`, `supabase-config.js`, and the `supabase/` folder with the normal GitHub Pages workflow.
6. Open the published page on each device, choose **雲端同步**, and sign in with the same email. The first signed-in device seeds the cloud row from its current browser itinerary; later devices load that row.

`supabase-config.js` is shipped to browsers. It may contain the Project URL and publishable key only. Never place a secret or service-role key in that file, `index.html`, or GitHub. The SQL policy restricts rows to `auth.uid() = owner_id`.

When two devices edit the same itinerary at the same time, the most recent save wins. Avoid simultaneous editing to prevent one device's save from replacing the other's.
