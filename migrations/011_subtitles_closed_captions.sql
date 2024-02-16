-- Create new column is_closed_captions
ALTER TABLE public.subtitles ADD COLUMN is_closed_captions BOOLEAN;

-- Drop the existing constraint
ALTER TABLE ONLY public.subtitles DROP CONSTRAINT uniq_subtitles_by_thing_n_lang_n_provider;

-- Create a new unique constraint with the additional column
ALTER TABLE ONLY public.subtitles ADD CONSTRAINT uniq_subtitles_by_thing_n_lang_n_provider_n_cc UNIQUE (id_thing, id_lang, id_provider, is_closed_captions);
