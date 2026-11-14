ALTER TABLE public.profile_preferences
  DROP CONSTRAINT IF EXISTS profile_preferences_gender_check;

ALTER TABLE public.profile_preferences
  ADD CONSTRAINT profile_preferences_gender_check
  CHECK (
    preferred_gender IS NULL OR
    preferred_gender IN ('رجل', 'امرأة', 'any', 'man', 'woman')
  );
