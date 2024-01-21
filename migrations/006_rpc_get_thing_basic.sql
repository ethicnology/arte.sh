DROP FUNCTION get_thing_basic;
CREATE OR REPLACE FUNCTION get_thing_basic(
    ids INT8[],
    lang INT
)
RETURNS TABLE (
    id_thing INT8,
    created_at timestamptz,
    id_type INT2,
    arte text,
    imdb INT,
    tmdb INT,
    title text,
    duration INT2,
    years INT2[],
    actors text[],
    authors text[],
    directors text[],
    countries text[],
    productors text[],
    subtitle text,
    description text,
    full_description text,
    parent_ids INT8[],
    child_ids INT8[]
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id AS id_thing,
        t.created_at AS created_at,
        t.id_type,
        t.arte,
        t.imdb,
        t.tmdb,
        COALESCE(title_lang2.label, title_lang1.label) AS title,
        ai.duration,
        ai.years,
        ai.actors,
        ai.authors,
        ai.directors,
        ai.countries,
        ai.productors,
        a.subtitle,
        a.description,
        a.full_description,
        ARRAY(SELECT l.id_parent FROM public.link l WHERE l.id_child = t.id) AS parent_ids,
        ARRAY(SELECT l.id_child FROM public.link l WHERE l.id_parent = t.id) AS child_ids
    FROM public.thing t
    LEFT JOIN public.arte_info ai ON t.id = ai.id_thing
    LEFT JOIN public.arte_description a ON t.id = a.id_thing AND a.id_lang = lang
    LEFT JOIN public.title title_lang1 ON t.id = title_lang1.id_thing AND title_lang1.id_lang = 1
    LEFT JOIN public.title title_lang2 ON t.id = title_lang2.id_thing AND title_lang2.id_lang = lang
    WHERE t.id = ANY(ids);
END;
$$ LANGUAGE plpgsql;
