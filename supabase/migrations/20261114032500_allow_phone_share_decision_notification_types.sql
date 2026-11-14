ALTER TABLE public.member_notifications
DROP CONSTRAINT IF EXISTS member_notifications_event_type_check;

ALTER TABLE public.member_notifications
ADD CONSTRAINT member_notifications_event_type_check
CHECK (
  event_type = ANY (ARRAY[
    'like',
    'match',
    'message',
    'phone_request',
    'phone_approved',
    'phone_declined',
    'phone_revoked'
  ]::text[])
);
