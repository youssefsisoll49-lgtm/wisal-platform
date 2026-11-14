CREATE OR REPLACE FUNCTION public.skip_wisal_member(p_member_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;

  IF p_member_id IS NULL OR p_member_id = v_uid THEN
    RAISE EXCEPTION 'Invalid member';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles own
    WHERE own.id = v_uid
      AND own.is_searchable = true
      AND own.marriage_intent = true
      AND own.birth_date IS NOT NULL
      AND own.birth_date <= (current_date - interval '18 years')::date
  ) THEN
    RAISE EXCEPTION 'Complete your adult profile and enable visibility first';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles target
    WHERE target.id = p_member_id
      AND target.is_searchable = true
      AND target.marriage_intent = true
      AND target.birth_date IS NOT NULL
      AND target.birth_date <= (current_date - interval '18 years')::date
  ) THEN
    RAISE EXCEPTION 'Member unavailable';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.member_blocks b
    WHERE (b.blocker_id = v_uid AND b.blocked_id = p_member_id)
       OR (b.blocker_id = p_member_id AND b.blocked_id = v_uid)
  ) THEN
    RAISE EXCEPTION 'Action unavailable';
  END IF;

  INSERT INTO public.member_skips(skipper_id, skipped_id)
  VALUES (v_uid, p_member_id)
  ON CONFLICT DO NOTHING;

  RETURN true;
END;
$function$;
