--
-- PostgreSQL database dump
--

-- Dumped from database version 17rc1
-- Dumped by pg_dump version 17rc1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
--SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: organization_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.organization_type AS ENUM (
    'IE',
    'LLC',
    'JSC'
);


ALTER TYPE public.organization_type OWNER TO postgres;

--
-- Name: insert_into_mapping(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_mapping() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO organization_mapping (uuid)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_into_mapping() OWNER TO postgres;

--
-- Name: integer_to_uuid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.integer_to_uuid(integer_id integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN uuid_generate_v5(uuid_ns_dns(), integer_id::text);
END;
$$;


ALTER FUNCTION public.integer_to_uuid(integer_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(50) NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    type public.organization_type,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.organization OWNER TO postgres;

--
-- Name: organization_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_mapping (
    organization_id integer NOT NULL,
    uuid uuid NOT NULL
);


ALTER TABLE public.organization_mapping OWNER TO postgres;

--
-- Name: organization_mapping_organization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_mapping_organization_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organization_mapping_organization_id_seq OWNER TO postgres;

--
-- Name: organization_mapping_organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_mapping_organization_id_seq OWNED BY public.organization_mapping.organization_id;


--
-- Name: organization_responsible; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_responsible (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    organization_id uuid,
    user_id uuid
);


ALTER TABLE public.organization_responsible OWNER TO postgres;

--
-- Name: proposal_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proposal_versions (
    id integer NOT NULL,
    proposal_id integer NOT NULL,
    version integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    status character varying(50) NOT NULL,
    tender_id integer NOT NULL,
    organization_id uuid NOT NULL,
    creator_username character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.proposal_versions OWNER TO postgres;

--
-- Name: proposal_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proposal_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proposal_versions_id_seq OWNER TO postgres;

--
-- Name: proposal_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proposal_versions_id_seq OWNED BY public.proposal_versions.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proposals (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    status character varying(50) NOT NULL,
    tender_id integer NOT NULL,
    organization_id uuid NOT NULL,
    creator_username character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.proposals OWNER TO postgres;

--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proposals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proposals_id_seq OWNER TO postgres;

--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proposals_id_seq OWNED BY public.proposals.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    proposal_id integer,
    author_username character varying(100) NOT NULL,
    organization_id integer NOT NULL,
    review_text text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq OWNER TO postgres;

--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: tender_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tender_versions (
    id integer NOT NULL,
    tender_id integer,
    version integer NOT NULL,
    name character varying(100),
    description text,
    service_type character varying(50),
    status character varying(50),
    organization_id uuid,
    creator_username character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tender_versions OWNER TO postgres;

--
-- Name: tender_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tender_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tender_versions_id_seq OWNER TO postgres;

--
-- Name: tender_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tender_versions_id_seq OWNED BY public.tender_versions.id;


--
-- Name: tenders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenders (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    service_type character varying(50),
    status character varying(50),
    organization_id uuid,
    creator_username character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tenders OWNER TO postgres;

--
-- Name: tenders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tenders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tenders_id_seq OWNER TO postgres;

--
-- Name: tenders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tenders_id_seq OWNED BY public.tenders.id;


--
-- Name: organization_mapping organization_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_mapping ALTER COLUMN organization_id SET DEFAULT nextval('public.organization_mapping_organization_id_seq'::regclass);


--
-- Name: proposal_versions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proposal_versions ALTER COLUMN id SET DEFAULT nextval('public.proposal_versions_id_seq'::regclass);


--
-- Name: proposals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proposals ALTER COLUMN id SET DEFAULT nextval('public.proposals_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: tender_versions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_versions ALTER COLUMN id SET DEFAULT nextval('public.tender_versions_id_seq'::regclass);


--
-- Name: tenders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenders ALTER COLUMN id SET DEFAULT nextval('public.tenders_id_seq'::regclass);


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (id, username, first_name, last_name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization (id, name, description, type, created_at, updated_at) FROM stdin;
9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	Avito	Classified	LLC	2024-09-12 16:58:58.917894	2024-09-12 16:58:58.917894
f42252a0-91dd-4c7a-8ea9-7af7402ccea0	Lambda	Food	LLC	2024-09-13 18:34:09.221175	2024-09-13 18:34:09.221175
\.


--
-- Data for Name: organization_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_mapping (organization_id, uuid) FROM stdin;
1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed
2	f42252a0-91dd-4c7a-8ea9-7af7402ccea0
\.


--
-- Data for Name: organization_responsible; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_responsible (id, organization_id, user_id) FROM stdin;
\.


--
-- Data for Name: proposal_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proposal_versions (id, proposal_id, version, name, description, status, tender_id, organization_id, creator_username, created_at, updated_at) FROM stdin;
1	14	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:27:32.413403	2024-09-13 20:27:32.413403
2	1	2	new prop 1	new desc╨╡	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:46:10.05029	2024-09-13 20:46:10.05029
3	1	2	new prop 1	new desc╨╡	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:47:25.023532	2024-09-13 20:47:25.023532
4	1	2	new prop 2	new desc	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:48:31.385086	2024-09-13 20:48:31.385086
5	1	2	new prop 3	new 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:49:02.714443	2024-09-13 20:49:02.714443
6	1	3	new prop 4	new 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:53:01.228483	2024-09-13 20:53:01.228483
7	1	4	new prop 5	new5 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 21:14:02.582331	2024-09-13 21:14:02.582331
8	1	5	new prop 4	new 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 21:14:39.239606	2024-09-13 21:14:39.239606
9	15	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:13:26.430454	2024-09-13 23:13:26.430454
10	16	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:14:41.401155	2024-09-13 23:14:41.401155
11	17	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:15:00.270251	2024-09-13 23:15:00.270251
12	1	6	new prop 5	new5 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:40:18.766126	2024-09-13 23:40:18.766126
13	1	7	new prop 5	new5 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:56:17.444183	2024-09-13 23:56:17.444183
14	1	8	new prop 5	new5 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-14 01:49:03.520052	2024-09-14 01:49:03.520052
15	18	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-14 13:28:00.385252	2024-09-14 13:28:00.385252
16	19	1	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-14 14:17:17.003184	2024-09-14 14:17:17.003184
\.


--
-- Data for Name: proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proposals (id, name, description, status, tender_id, organization_id, creator_username, created_at, updated_at) FROM stdin;
2	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:19:12.905792	2024-09-12 22:19:12.905792
3	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:21:21.403808	2024-09-12 22:21:21.403808
4	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:27:15.296203	2024-09-12 22:27:15.296203
5	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:29:04.665811	2024-09-12 22:29:04.665811
6	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:30:57.846894	2024-09-12 22:30:57.846894
7	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:31:52.769388	2024-09-12 22:31:52.769388
8	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:31:56.686775	2024-09-12 22:31:56.686775
9	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 23:09:28.929817	2024-09-12 23:09:28.929817
10	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 23:17:18.139113	2024-09-12 23:17:18.139113
11	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 18:05:20.636836	2024-09-13 18:05:20.636836
14	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 20:27:32.413403	2024-09-13 20:27:32.413403
15	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:13:26.430454	2024-09-13 23:13:26.430454
16	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:14:41.401155	2024-09-13 23:14:41.401155
17	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:15:00.270251	2024-09-13 23:15:00.270251
1	new prop 5	new5 	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 21:57:47.382356	2024-09-12 21:57:47.382356
18	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-14 13:28:00.385252	2024-09-14 13:28:00.385252
19	╨Я╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╨╡ 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╨┐╤А╨╡╨┤╨╗╨╛╨╢╨╡╨╜╨╕╤П	Submitted	1	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-14 14:17:17.003184	2024-09-14 14:17:17.003184
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, proposal_id, author_username, organization_id, review_text, created_at) FROM stdin;
1	1	user2	1	This is a review text for the proposal.	2024-09-13 21:49:04.104672
2	1	user2	1	This is a review text for the proposal.	2024-09-13 21:51:36.007565
3	6	user2	1	This is a review text for the proposal.	2024-09-13 21:52:38.794364
\.


--
-- Data for Name: tender_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tender_versions (id, tender_id, version, name, description, service_type, status, organization_id, creator_username, created_at) FROM stdin;
1	7	1	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 18:35:50.671955
2	2	1	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╤Л╨╣ ╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╨╛╨╡ ╨╛╨┐╨╕╤Б╨░╨╜╨╕╨╡	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 18:52:53.00893
3	2	2	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╤Л╨╣ ╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╨╛╨╡ ╨╛╨┐╨╕╤Б╨░╨╜╨╕╨╡	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 18:56:53.716851
4	2	3	CAKE 2	WATER	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 19:00:21.799808
5	2	4	CAKE 2	WATER	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 19:20:58.012506
6	2	5	CAKE 3	WATER3	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 21:19:35.05725
7	2	6	CAKE 2	WATER	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 21:19:52.800061
8	8	1	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 22:55:24.201002
9	9	1	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 23:02:42.273342
10	2	7	CAKE 2	WATER	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 23:11:45.587237
11	10	1	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 23:12:34.141268
\.


--
-- Data for Name: tenders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenders (id, name, description, service_type, status, organization_id, creator_username, created_at, updated_at) FROM stdin;
3	╨в╨╡╨╜╨┤╨╡╤А 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:22:14.46452	2024-09-12 22:22:14.46452
4	╨в╨╡╨╜╨┤╨╡╤А 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:22:49.583344	2024-09-12 22:22:49.583344
5	╨в╨╡╨╜╨┤╨╡╤А 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 23:17:01.499862	2024-09-12 23:17:01.499862
1	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╤Л╨╣ ╨в╨╡╨╜╨┤╨╡╤А 1	╨Ю╨▒╨╜╨╛╨▓╨╗╨╡╨╜╨╜╨╛╨╡ ╨╛╨┐╨╕╤Б╨░╨╜╨╕╨╡	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 17:21:56.17699	2024-09-12 17:21:56.17699
6	╨в╨╡╨╜╨┤╨╡╤А 1	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-13 18:05:30.884011	2024-09-13 18:05:30.884011
7	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 18:35:50.671955	2024-09-13 18:35:50.671955
8	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 22:55:24.201002	2024-09-13 22:55:24.201002
9	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 23:02:42.273342	2024-09-13 23:02:42.273342
2	CAKE 2	WATER	Construction	Open	9c7dcd89-9d1b-403a-99a1-56f78ebd11ed	user1	2024-09-12 22:16:58.914239	2024-09-12 22:16:58.914239
10	╨в╨╡╨╜╨┤╨╡╤А 2	╨Ю╨┐╨╕╤Б╨░╨╜╨╕╨╡ ╤В╨╡╨╜╨┤╨╡╤А╨░	Service	Open	f42252a0-91dd-4c7a-8ea9-7af7402ccea0	user2	2024-09-13 23:12:34.141268	2024-09-13 23:12:34.141268
\.


--
-- Name: organization_mapping_organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_mapping_organization_id_seq', 2, true);


--
-- Name: proposal_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proposal_versions_id_seq', 16, true);


--
-- Name: proposals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proposals_id_seq', 19, true);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_id_seq', 3, true);


--
-- Name: tender_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tender_versions_id_seq', 11, true);


--
-- Name: tenders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tenders_id_seq', 10, true);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee employee_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_username_key UNIQUE (username);


--
-- Name: organization_mapping organization_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_mapping
    ADD CONSTRAINT organization_mapping_pkey PRIMARY KEY (organization_id);


--
-- Name: organization_mapping organization_mapping_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_mapping
    ADD CONSTRAINT organization_mapping_uuid_key UNIQUE (uuid);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (id);


--
-- Name: organization_responsible organization_responsible_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_responsible
    ADD CONSTRAINT organization_responsible_pkey PRIMARY KEY (id);


--
-- Name: proposal_versions proposal_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proposal_versions
    ADD CONSTRAINT proposal_versions_pkey PRIMARY KEY (id);


--
-- Name: proposals proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: tender_versions tender_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_versions
    ADD CONSTRAINT tender_versions_pkey PRIMARY KEY (id);


--
-- Name: tenders tenders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenders
    ADD CONSTRAINT tenders_pkey PRIMARY KEY (id);


--
-- Name: organization after_insert_organization; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insert_organization AFTER INSERT ON public.organization FOR EACH ROW EXECUTE FUNCTION public.insert_into_mapping();


--
-- Name: organization_responsible organization_responsible_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_responsible
    ADD CONSTRAINT organization_responsible_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- Name: organization_responsible organization_responsible_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_responsible
    ADD CONSTRAINT organization_responsible_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: proposal_versions proposal_versions_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proposal_versions
    ADD CONSTRAINT proposal_versions_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE CASCADE;


--
-- Name: tender_versions tender_versions_tender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tender_versions
    ADD CONSTRAINT tender_versions_tender_id_fkey FOREIGN KEY (tender_id) REFERENCES public.tenders(id) ON DELETE CASCADE;


--
-- Name: tenders tenders_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenders
    ADD CONSTRAINT tenders_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

