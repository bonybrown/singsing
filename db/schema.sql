--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: artists; Type: TABLE; Schema: public; Owner: karaoke
--

CREATE TABLE artists (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    sortkey character varying(80) DEFAULT NULL::character varying
);


ALTER TABLE artists OWNER TO karaoke;

--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: karaoke
--

CREATE SEQUENCE artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE artists_id_seq OWNER TO karaoke;

--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: karaoke
--

ALTER SEQUENCE artists_id_seq OWNED BY artists.id;


--
-- Name: queue; Type: TABLE; Schema: public; Owner: karaoke
--

CREATE TABLE queue (
    inserted timestamp without time zone,
    song_id integer,
    inserted_by character varying(50) DEFAULT NULL::character varying,
    id integer NOT NULL,
    played boolean DEFAULT false
);


ALTER TABLE queue OWNER TO karaoke;

--
-- Name: queue_id_seq; Type: SEQUENCE; Schema: public; Owner: karaoke
--

CREATE SEQUENCE queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE queue_id_seq OWNER TO karaoke;

--
-- Name: queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: karaoke
--

ALTER SEQUENCE queue_id_seq OWNED BY queue.id;


--
-- Name: songs; Type: TABLE; Schema: public; Owner: karaoke
--

CREATE TABLE songs (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying(80) NOT NULL,
    filename character varying(255) DEFAULT NULL::character varying,
    sortkey character varying(80) DEFAULT NULL::character varying
);


ALTER TABLE songs OWNER TO karaoke;

--
-- Name: search; Type: MATERIALIZED VIEW; Schema: public; Owner: karaoke
--

CREATE MATERIALIZED VIEW search AS
 SELECT to_tsvector('english'::regconfig, (((s.name)::text || ' '::text) || (a.name)::text)) AS english,
    to_tsvector('simple'::regconfig, (((s.name)::text || ' '::text) || (a.name)::text)) AS simple,
    s.id AS song_id
   FROM songs s,
    artists a
  WHERE (s.artist_id = a.id)
  WITH NO DATA;


ALTER TABLE search OWNER TO karaoke;

--
-- Name: songs_id_seq; Type: SEQUENCE; Schema: public; Owner: karaoke
--

CREATE SEQUENCE songs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE songs_id_seq OWNER TO karaoke;

--
-- Name: songs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: karaoke
--

ALTER SEQUENCE songs_id_seq OWNED BY songs.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY artists ALTER COLUMN id SET DEFAULT nextval('artists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY queue ALTER COLUMN id SET DEFAULT nextval('queue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY songs ALTER COLUMN id SET DEFAULT nextval('songs_id_seq'::regclass);


--
-- Name: artists_name_key; Type: CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_name_key UNIQUE (name);


--
-- Name: artists_pkey; Type: CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: queue_pkey; Type: CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (id);


--
-- Name: songs_pkey; Type: CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY songs
    ADD CONSTRAINT songs_pkey PRIMARY KEY (id);


--
-- Name: idx_search_english; Type: INDEX; Schema: public; Owner: karaoke
--

CREATE INDEX idx_search_english ON search USING gin (english);


--
-- Name: idx_search_simple; Type: INDEX; Schema: public; Owner: karaoke
--

CREATE INDEX idx_search_simple ON search USING gin (simple);


--
-- Name: queue_played; Type: INDEX; Schema: public; Owner: karaoke
--

CREATE INDEX queue_played ON queue USING btree (played, inserted);


--
-- Name: song_idx; Type: INDEX; Schema: public; Owner: karaoke
--

CREATE INDEX song_idx ON songs USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: queue_song_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_song_id_fkey FOREIGN KEY (song_id) REFERENCES songs(id);


--
-- Name: songs_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: karaoke
--

ALTER TABLE ONLY songs
    ADD CONSTRAINT songs_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artists(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

