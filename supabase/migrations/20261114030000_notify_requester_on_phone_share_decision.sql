CREATE OR REPLACE FUNCTION private.notify_wisal_phone_response()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  v_event text;
  v_title text;
  v_body text;
BEGIN
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  IF NEW.status = 'approved' THEN
    v_event := 'phone_approved';
    v_title := 'تمت الموافقة على مشاركة رقم الهاتف';
    v_body := 'وافق صاحب الرقم على طلبك. يمكنك الآن عرض الرقم من تبويب طلبات الهاتف.';
  ELSIF NEW.status = 'declined' AND OLD.status = 'approved' THEN
    v_event := 'phone_revoked';
    v_title := 'تم إلغاء مشاركة رقم الهاتف';
    v_body := 'ألغى صاحب الرقم موافقته على مشاركة رقم الهاتف.';
  ELSIF NEW.status = 'declined' THEN
    v_event := 'phone_declined';
    v_title := 'تم رفض طلب مشاركة رقم الهاتف';
    v_body := 'اختار صاحب الرقم عدم مشاركة رقمه. نحترم قراره وخصوصيته.';
  ELSE
    RETURN NEW;
  END IF;

  INSERT INTO public.member_notifications(
    recipient_id, actor_id, event_type, title, body, related_id
  )
  VALUES (
    NEW.requester_id, NEW.owner_id, v_event, v_title, v_body, NEW.id
  );

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_notify_wisal_phone_response ON public.phone_share_requests;
CREATE TRIGGER trg_notify_wisal_phone_response
AFTER UPDATE OF status ON public.phone_share_requests
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION private.notify_wisal_phone_response();
