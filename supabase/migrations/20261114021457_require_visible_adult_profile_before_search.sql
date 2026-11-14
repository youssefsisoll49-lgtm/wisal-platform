CREATE OR REPLACE FUNCTION public.search_wisal_members(
  p_gender text DEFAULT NULL,
  p_country text DEFAULT NULL,
  p_min_age integer DEFAULT NULL,
  p_max_age integer DEFAULT NULL,
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0
)
RETURNS TABLE(
  member_id uuid, display_name text, country text, gender text, age integer,
  city text, bio text, height_cm integer, body_build text, skin_tone text,
  education text, occupation text, eye_color text, hair_color text,
  personality text, hobbies text, appearance_notes text
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_min integer;
  v_max integer;
  v_gender text;
  v_country text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.profiles own
    WHERE own.id = v_uid
      AND own.is_searchable = true
      AND own.marriage_intent = true
      AND own.birth_date IS NOT NULL
      AND own.birth_date <= (current_date - interval '18 years')::date
  ) THEN
    RAISE EXCEPTION 'Complete your adult profile and enable visibility first';
  END IF;

  SELECT coalesce(p_min_age,pref.min_age,18),
         coalesce(p_max_age,pref.max_age,100),
         coalesce(nullif(p_gender,''),case pref.preferred_gender
           when 'woman' then 'امرأة' when 'man' then 'رجل' else null end),
         coalesce(nullif(p_country,''),pref.preferred_country)
    INTO v_min,v_max,v_gender,v_country
  FROM (SELECT 1) seed
  LEFT JOIN public.profile_preferences pref ON pref.user_id=v_uid;

  IF v_min < 18 OR v_max > 100 OR v_min > v_max THEN
    RAISE EXCEPTION 'Invalid age range';
  END IF;

  RETURN QUERY
  SELECT p.id,p.display_name,p.country,p.gender,
         extract(year from age(current_date,p.birth_date))::integer,
         p.city,p.bio,p.height_cm,p.body_build,p.skin_tone,p.education,
         p.occupation,p.eye_color,p.hair_color,p.personality,p.hobbies,p.appearance_notes
  FROM public.profiles p
  WHERE p.id <> v_uid
    AND p.is_searchable = true
    AND p.marriage_intent = true
    AND p.birth_date IS NOT NULL
    AND p.birth_date <= (current_date - interval '18 years')::date
    AND extract(year from age(current_date,p.birth_date)) BETWEEN v_min AND v_max
    AND (v_gender IS NULL OR p.gender=v_gender)
    AND (v_country IS NULL OR p.country=v_country)
    AND NOT EXISTS (
      SELECT 1 FROM public.member_blocks b
      WHERE (b.blocker_id=v_uid AND b.blocked_id=p.id)
         OR (b.blocker_id=p.id AND b.blocked_id=v_uid)
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.member_skips s
      WHERE s.skipper_id=v_uid AND s.skipped_id=p.id
    )
    AND NOT EXISTS (
      SELECT 1 FROM public.member_likes l
      WHERE l.sender_id=v_uid AND l.recipient_id=p.id
    )
  ORDER BY p.updated_at DESC
  LIMIT greatest(1,least(coalesce(p_limit,20),50))
  OFFSET greatest(coalesce(p_offset,0),0);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_wisal_public_profile_details(p_member_ids uuid[])
RETURNS TABLE(
  member_id uuid, height_cm integer, body_build text, skin_tone text,
  personality text, hobbies text, education text, occupation text,
  marital_status text, eye_color text, hair_color text, appearance_notes text
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.profiles own
    WHERE own.id=auth.uid()
      AND own.is_searchable=true
      AND own.marriage_intent=true
      AND own.birth_date IS NOT NULL
      AND own.birth_date <= (current_date - interval '18 years')::date
  ) THEN
    RAISE EXCEPTION 'Complete your adult profile and enable visibility first';
  END IF;

  RETURN QUERY
  SELECT p.id,p.height_cm,p.body_build,p.skin_tone,p.personality,p.hobbies,
         p.education,p.occupation,p.marital_status,p.eye_color,p.hair_color,p.appearance_notes
  FROM public.profiles p
  WHERE p.id=ANY(coalesce(p_member_ids,'{}'::uuid[]))
    AND p.is_searchable=true
    AND p.marriage_intent=true
    AND p.birth_date <= (current_date-interval '18 years')::date
    AND NOT EXISTS (
      SELECT 1 FROM public.member_blocks b
      WHERE (b.blocker_id=auth.uid() AND b.blocked_id=p.id)
         OR (b.blocker_id=p.id AND b.blocked_id=auth.uid())
    );
END;
$function$;
