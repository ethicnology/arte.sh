-- DROP FUNCTION public.get_last_10_days_things_with_zero_subtitles();

CREATE OR REPLACE FUNCTION public.get_last_10_days_things_with_zero_subtitles()
 RETURNS TABLE(id bigint, arte text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT t.id::BIGINT, t.arte
    FROM public.thing t
    LEFT JOIN public.subtitles s ON t.id = s.id_thing
    WHERE t.created_at >= current_date - interval '10 days'
    GROUP BY t.id, t.arte
    HAVING COUNT(s.id) = 0;
    
    RETURN;
END;
$function$
;
