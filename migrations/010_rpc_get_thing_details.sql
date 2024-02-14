CREATE OR REPLACE FUNCTION get_thing_details(ids bigint[])
RETURNS TABLE (
    thing jsonb,
    titles jsonb,
    descriptions jsonb,
    info jsonb,
    parents jsonb,
    children jsonb
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        to_jsonb(thing.*) AS thing,
        coalesce(jsonb_agg(DISTINCT title.*) FILTER (WHERE title.id IS NOT NULL), '[]') AS titles,
        coalesce(jsonb_agg(DISTINCT arte_description.*) FILTER (WHERE arte_description.id IS NOT NULL), '[]') AS descriptions,
        COALESCE(to_jsonb(arte_info.*),  'null') AS info,
        COALESCE(jsonb_agg(DISTINCT p.id_parent) FILTER (WHERE p.id_parent IS NOT NULL), '[]') AS parents,
        COALESCE(jsonb_agg(distinct c.id_child) FILTER (WHERE c.id_child IS NOT NULL), '[]') AS children
    FROM public.thing
    LEFT JOIN public.arte_info ON thing.id = arte_info.id_thing
    LEFT JOIN public.arte_description ON thing.id = arte_description.id_thing 
    LEFT JOIN public.title ON thing.id = title.id_thing
    LEFT JOIN public.link p ON thing.id = p.id_child 
    LEFT JOIN public.link c ON thing.id = c.id_parent  
    WHERE thing.id = ANY(ids)
    GROUP BY 
        thing.id,
        arte_info.id,
        arte_description.id_thing,
        title.id_thing;
END;
$$

