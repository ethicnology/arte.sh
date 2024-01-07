--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.language (id, created_at, tag) FROM stdin;
0	2023-12-24 21:19:30.511062+00	und
1	2023-12-24 21:19:43.095452+00	fr
2	2023-12-24 21:19:51.780767+00	de
3	2023-12-24 21:20:02.785492+00	en
4	2023-12-24 21:20:23.192028+00	es
5	2023-12-24 21:20:46.504857+00	it
6	2023-12-24 21:21:06.593329+00	pl
7	2023-12-24 21:34:36.563472+00	ru
\.


--
-- Data for Name: type; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.type (id, created_at, label) FROM stdin;
1	2023-12-14 00:30:22.192734+00	film
2	2023-12-14 00:30:42.413291+00	collection
3	2023-12-14 00:30:49.829222+00	episode
\.


--
-- Data for Name: thing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.thing (id, created_at, id_type, arte, imdb, tmdb) FROM stdin;
\.


--
-- Data for Name: arte_description; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.arte_description (id, created_at, id_thing, subtitle, description, full_description, id_lang) FROM stdin;
\.


--
-- Data for Name: arte_info; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.arte_info (id, created_at, id_thing, duration, years, actors, authors, directors, countries, productors) FROM stdin;
\.


--
-- Data for Name: cover; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.cover (id, created_at, id_thing, file, id_lang) FROM stdin;
\.


--
-- Data for Name: provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider (id, created_at, label, comment) FROM stdin;
1	2023-12-16 02:32:23.778263+00	arte	www.arte.tv
\.


--
-- Data for Name: subtitles; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.subtitles (id, created_at, id_thing, id_provider, file, ext, id_lang) FROM stdin;
\.


--
-- Data for Name: title; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.title (id, created_at, id_thing, is_original, label, id_lang) FROM stdin;
\.


--
-- Name: arte_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.arte_image_id_seq', 1, false);


--
-- Name: arte_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.arte_info_id_seq', 1, false);


--
-- Name: language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.language_id_seq', 1, false);


--
-- Name: metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.metadata_id_seq', 1, false);


--
-- Name: provider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.provider_id_seq', 2, true);


--
-- Name: subtitles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.subtitles_id_seq', 1, false);


--
-- Name: thing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.thing_id_seq', 1, false);


--
-- Name: title_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.title_id_seq', 1, false);


--
-- Name: type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: supabase_admin
--

SELECT pg_catalog.setval('public.type_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

