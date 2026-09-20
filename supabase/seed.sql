-- Local-only fixture. Never reuse this account or password outside Supabase local.
-- Email: admin@koreaquest.local
-- Password: KoreaQuestLocal123

insert into auth.users (
  id,
  instance_id,
  role,
  aud,
  email,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  encrypted_password,
  created_at,
  updated_at,
  last_sign_in_at,
  email_confirmed_at,
  confirmation_sent_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
) values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'admin@koreaquest.local',
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"display_name":"KoreaQuest Local Admin"}'::jsonb,
  false,
  extensions.crypt('KoreaQuestLocal123', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  now(),
  now(),
  '',
  '',
  '',
  ''
);

insert into auth.identities (
  id,
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) values (
  '00000000-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001',
  '{"sub":"00000000-0000-4000-8000-000000000001","email":"admin@koreaquest.local","email_verified":true}'::jsonb,
  'email',
  now(),
  now(),
  now()
);

insert into public.admin_users (user_id, created_by)
values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001'
);
