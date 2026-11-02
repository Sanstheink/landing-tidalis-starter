# TIDALIS CMS

Supabase project: yequlgpopdnhvmmwagaa. Admin: /admin.html.

Authentication uses Supabase email/password. Admin privileges are stored in tidalis_admins and cannot be granted by browser clients. No admin is provisioned yet: the owner must identify their email, create the corresponding Auth user using Supabase's supported dashboard/API, then a trusted project operator inserts that user's UUID into tidalis_admins. Never store a password or service key in this repository. Do not grant access based on user_metadata.

The public browser uses only a publishable key. RLS protects drafts and contact messages. Media in tidalis-media is public; only admins can upload JPG, PNG or WebP up to 5 MB. Auth tokens stay in sessionStorage and the UI expires sessions after at most 60 minutes or the access token expiry. No automatic refresh is performed.

Page records use the original data-i keys as slugs. Thai and English body fields replace textContent, never HTML. Services, artists, works and news render from published content. Unpublishing a page override restores the built-in fallback text. Messages are submitted directly to the database with field constraints; the inbox shows the latest 200. Add CAPTCHA/rate limiting before a broad promotional launch if spam becomes an issue. Uploaded media remains public even if its content record is unpublished.

Database schema is in schema.sql and was applied through Supabase migration tidalis_cms_initial. Do not rerun it on an initialized project. Security advisors returned no findings. Anonymous permissions and non-admin membership visibility were checked. End-to-end administrator login/save/upload still requires provisioning the owner's account.
