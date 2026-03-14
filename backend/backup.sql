--
-- PostgreSQL database dump
--

\restrict 1D5XVw37Ivr1L1uRtbKY1Mdf1LaF6piJv0mEJ3LaAGQIkZG7RdMt3xTzb29nwhq

-- Dumped from database version 18.3 (Homebrew)
-- Dumped by pg_dump version 18.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clientes; Type: TABLE; Schema: public; Owner: danielapineda
--

CREATE TABLE public.clientes (
    id integer NOT NULL,
    nombre character varying(100),
    correo character varying(100),
    telefono character varying(20)
);


ALTER TABLE public.clientes OWNER TO danielapineda;

--
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: public; Owner: danielapineda
--

CREATE SEQUENCE public.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_seq OWNER TO danielapineda;

--
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: danielapineda
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- Name: minipostres; Type: TABLE; Schema: public; Owner: danielapineda
--

CREATE TABLE public.minipostres (
    id integer NOT NULL,
    nombre character varying(100)
);


ALTER TABLE public.minipostres OWNER TO danielapineda;

--
-- Name: minipostres_id_seq; Type: SEQUENCE; Schema: public; Owner: danielapineda
--

CREATE SEQUENCE public.minipostres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.minipostres_id_seq OWNER TO danielapineda;

--
-- Name: minipostres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: danielapineda
--

ALTER SEQUENCE public.minipostres_id_seq OWNED BY public.minipostres.id;


--
-- Name: pedido_postres; Type: TABLE; Schema: public; Owner: danielapineda
--

CREATE TABLE public.pedido_postres (
    id integer NOT NULL,
    pedido_id integer,
    postre_id integer
);


ALTER TABLE public.pedido_postres OWNER TO danielapineda;

--
-- Name: pedido_postres_id_seq; Type: SEQUENCE; Schema: public; Owner: danielapineda
--

CREATE SEQUENCE public.pedido_postres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedido_postres_id_seq OWNER TO danielapineda;

--
-- Name: pedido_postres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: danielapineda
--

ALTER SEQUENCE public.pedido_postres_id_seq OWNED BY public.pedido_postres.id;


--
-- Name: pedidos; Type: TABLE; Schema: public; Owner: danielapineda
--

CREATE TABLE public.pedidos (
    id integer NOT NULL,
    cliente_id integer,
    fecha_registro timestamp without time zone,
    fecha_entrega date,
    hora_entrega time without time zone,
    tipo_pedido character varying(255),
    tipo_torta character varying(255),
    peso_torta character varying(255),
    sabor_ponque character varying(255),
    relleno_base character varying(255),
    relleno_especial character varying(255),
    tipo_torta_especial character varying(255),
    estado character varying(255) DEFAULT 'pendiente'::character varying
);


ALTER TABLE public.pedidos OWNER TO danielapineda;

--
-- Name: pedidos_id_seq; Type: SEQUENCE; Schema: public; Owner: danielapineda
--

CREATE SEQUENCE public.pedidos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedidos_id_seq OWNER TO danielapineda;

--
-- Name: pedidos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: danielapineda
--

ALTER SEQUENCE public.pedidos_id_seq OWNED BY public.pedidos.id;


--
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- Name: minipostres id; Type: DEFAULT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.minipostres ALTER COLUMN id SET DEFAULT nextval('public.minipostres_id_seq'::regclass);


--
-- Name: pedido_postres id; Type: DEFAULT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedido_postres ALTER COLUMN id SET DEFAULT nextval('public.pedido_postres_id_seq'::regclass);


--
-- Name: pedidos id; Type: DEFAULT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN id SET DEFAULT nextval('public.pedidos_id_seq'::regclass);


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: danielapineda
--

COPY public.clientes (id, nombre, correo, telefono) FROM stdin;
1	Ysbel García 	\N	0424-7327931 
2	Michelle balza	\N	04167741108
3	Elayne Ruiz 	\N	0426-4785506 
4	Yuskley serrano 	\N	04124576482
5	Ingrid Mora 	\N	7869619187
6	María José Roa Gonzalez 	\N	+573227354005
7	Anny Marquez 	\N	04267170198
8	Sarith Hernández 	\N	04247696676
9	Anna Orellana 	\N	04147365032
10	Emily rosales 	\N	04161740321
11	Yosmeira Coromoto Villalobos	\N	04161178289
12	María Moreno 	\N	04143794725
13	Beatriz Rosales 	\N	04143764721
14	Ana González 	\N	04147427785
15	Estiven Mora	\N	04247050654
16	Carolina García 	\N	4247475810
17	Yoleida casique	\N	04161776258
18	Marisol Sánchez 	\N	04147492554
19	Anyerleiby Sánchez Ramírez 	\N	04147423040
20	Lenis Guillén Ramírez 	\N	04247517270
21	Yamile vega 	\N	04143794363
22	Greys Suárez 	\N	04261611467
23	Oriana Sisa 	\N	04143743863
24	Lisbeth rinco	\N	0426-6777711
25	Miriam	\N	04247045383
26	Karley Pérez 	\N	04247122669
27	Rebeca Roa	\N	04165298118
28	Luisana finol	\N	0414754
29	Yenmary López 	\N	04162708680
30	Wendy rosales	\N	04247345493
31	Carmen julia Triana Suarez 	\N	04147361163
32	Amanda Molina 	\N	+19297683726
33	Jarihana Gabriela Pérez Zamudio 	\N	04247115080
34	Yhandry duque 	\N	04247345494
35	Egmily cuellar	\N	04247026971
36	Nuvia Monsalve 	\N	04247835034
37	Josue suarez 	\N	04122902121
38	Vanessa salazar	\N	0412 7044769
39	Yohana giron 	\N	04247147283
40	Elba Pineda	\N	0414 7131294
41	Luzmar contreras 	\N	+573170412996
42	Danyira Mejía 	\N	+13853132553
43	Gusmaidy	\N	04127958480
44	Enrique villalobos	\N	04161487584
45	Fabiola Colmenares	\N	0424-7162345
46	Lisvania Luzardo 	\N	04247721870
47	Dayana barona	\N	04147432426
48	Maria Quintero 	\N	04121822417
49	Marioxy cardenas 	\N	04262701846
50	Rebeca Roa	\N	0416-5298118 
51	LISBETH RINCON	\N	04266777711
52	Maria Gabriela Díaz 	\N	04126494703
53	Nohelia Aldana 	\N	4161796976
54	Yinette Arévalo 	\N	04247545287
55	María Elena Medina 	\N	04247367847
56	Yelitza giron	\N	04247269783
57	Greidy Chacón 	\N	3145489590
58	Rosmary sanguío	\N	04160765588
59	María Alexandra Suárez	\N	04247830334
60	Daniela pineda	\N	3166030975
61	Ana vielma	\N	04165712831
62	Yenni Patiarroyo 	\N	04147421138
63	Andy Cárdenas 	\N	04126883319
64	Enoe Ostos 	\N	0416-0883258
65	Victor Sánchez	\N	+58 4247639409
66	Karina Delgado 	\N	04247715248
67	Vanessa rujano 	\N	4247273029
68	Kassandra Valbuena 	\N	04149796887
69	Brenda Guerrero 	\N	04262687702
70	Andrea Guzmán 	\N	04160704062
71	Luiggi reyes 	\N	04247134256
72	Sugey Tolosa 	\N	04261199447
73	Dessiree Delgado 	\N	04247058595
74	Mairyn Salas	\N	04149727217
75	Ángeles Martínez 	\N	04247684499
76	Ysmeidy jaimes 	\N	04165405979
77	Genesis Márquez 	\N	04149745918
78	Berta Monsalve 	\N	04147545411
79	Wendy white	\N	+17205954386
80	Marialbert Angarita 	\N	04247136457
81	Olianny rincon	\N	04166750568
82	Maryory capacho 	\N	04262321848
83	Kehily Chacon 	\N	04242497706
84	Josué Roa 	\N	04247568245
85	Grecia Blanco 	\N	04147105174
86	Elba Pineda 	\N	04147131294
87	Cirily Rangel 	\N	04247712616
88	Shaday Bracho 	\N	04264142803
89	Andreina Rivas 	\N	4074918021
90	Ruth Cañizalez 	\N	04247528308
91	Wilmary Castro	\N	04247284681
92	Arlet Salas	\N	04124512608
93	David Pérez 	\N	04247805448
94	Eimily Sandoval 	\N	4147363141
95	Marleidy franco	\N	04163752455
96	Ramiro Duran	\N	04247796643
97	Naomi Contramaestre 	\N	04121729682
98	Freymar Rico 	\N	04247317254
99	Carolina Maldonado 	\N	04247143355
100	Karly cadevilla 	\N	04247081805
101	María Cardenas 	\N	04247166629
102	Kassandra valbuena	\N	04149796886
103	Yenireé Cegarra 	\N	04247121862
104	Gusmary Barreto 	\N	04261896398
105	Thalia Molina 	\N	04247375819
106	Gennesis zambrano 	\N	04122133212
107	Gabriela Martínez 	\N	04247326007
108	Mariana Balanta 	\N	04167284174
109	Coromoto de González 	\N	04269275847
110	Mairyn salas	\N	0414-9727217 
111	Katerin hidalgo	\N	04247158308
112	Mariana Balanta 	\N	0417284174
113	Zulay Montilla 	\N	4247138793
114	María José Ocando 	\N	04127047543
115	Paola Neira 	\N	04247169640
\.


--
-- Data for Name: minipostres; Type: TABLE DATA; Schema: public; Owner: danielapineda
--

COPY public.minipostres (id, nombre) FROM stdin;
\.


--
-- Data for Name: pedido_postres; Type: TABLE DATA; Schema: public; Owner: danielapineda
--

COPY public.pedido_postres (id, pedido_id, postre_id) FROM stdin;
\.


--
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: danielapineda
--

COPY public.pedidos (id, cliente_id, fecha_registro, fecha_entrega, hora_entrega, tipo_pedido, tipo_torta, peso_torta, sabor_ponque, relleno_base, relleno_especial, tipo_torta_especial, estado) FROM stdin;
1	\N	2026-12-03 18:29:35	2026-12-03	02:00:00	Cuarto de Kilo		Chocolate	Arequipe	Ninguno	Torta Clásica	\N	pendiente
2	5	2025-01-06 00:00:00	2025-02-03	20:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Crema de Coco		\N	pendiente
3	2	2025-01-08 00:00:00	2025-01-10	20:26:16	Medio Kilo		Vainilla	Chocolate Blanco	Fresas con Crema		\N	pendiente
4	6	2025-01-10 00:00:00	2025-01-11	22:56:16	Medio Kilo		Chocolate	Chocolate			\N	pendiente
5	7	2025-01-10 00:00:00	2025-01-11	09:56:16	Medio Kilo		Vainilla	Chocolate	Crema de Samba		\N	pendiente
6	8	2025-01-11 00:00:00	2025-01-13	17:56:16	Medio Kilo		Chocolate	Chocolate			\N	pendiente
7	9	2025-01-11 00:00:00	2025-01-13	23:26:16	Un Kilo		Chocolate	Chocolate	Crema de Oreo		\N	pendiente
8	2	2025-01-11 00:00:00	2025-01-13	18:56:16	Un Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
9	10	2025-01-11 00:00:00	2025-01-20	10:26:16	Medio Kilo		Chocolate	Chocolate	Crema de Samba		\N	pendiente
10	11	2025-01-12 00:00:00	2025-01-13	18:56:16	Un Kilo		Vainilla	Chocolate	Crema de Samba		\N	pendiente
11	12	2025-01-15 00:00:00	2025-01-21	22:56:16	Cuarto de Kilo		Vainilla	Chocolate	Crema de Oreo		\N	pendiente
12	13	2025-01-19 00:00:00	2025-01-21	20:56:16	Medio Kilo		Vainilla	Chocolate	Crema de Samba		\N	pendiente
13	2	2025-01-21 00:00:00	2025-01-25	20:56:16	Medio Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
14	15	2025-01-22 00:00:00	2005-01-26	00:56:16	3/4 		Vainilla	Chocolate	Pie de Parchita		\N	pendiente
15	16	2025-01-23 00:00:00	2025-01-25	23:26:16	Medio Kilo		Vainilla	Chocolate	Crema de Samba		\N	pendiente
16	17	2025-01-30 00:00:00	2025-02-02	13:56:16	Un Kilo		Vainilla	Arequipe	Crema de Samba		\N	pendiente
17	19	2025-02-05 00:00:00	2025-02-09	07:56:16	Medio Kilo		Chocolate	Chocolate			\N	pendiente
18	20	2025-02-05 00:00:00	2025-02-06	19:56:16	Medio Kilo		Vainilla	Arequipe	Crema de Samba		\N	pendiente
19	21	2025-02-06 00:00:00	2025-02-06	10:26:16	Medio Kilo		Vainilla	Chocolate	Crema de Samba		\N	pendiente
20	23	2025-02-06 00:00:00	2025-02-10	06:56:16	Un Kilo		Chocolate	Chocolate	Crema de Oreo		\N	pendiente
21	24	2025-02-07 00:00:00	1925-02-22	06:56:16	Un Kilo		Chocolate	Chocolate Blanco	Matilda chocolate 		\N	pendiente
22	9	2025-02-17 00:00:00	2025-02-23	19:56:16	Un Kilo		Vainilla	Chocolate Blanco	Crema de Samba		\N	pendiente
23	25	2025-02-24 00:00:00	2025-03-03	18:56:16	Un Kilo		Vainilla	Arequipe	Fresas con Crema		\N	pendiente
24	26	2025-02-24 00:00:00	2025-02-27	22:56:16	Medio Kilo		Chocolate	Chocolate	Ninguno		\N	pendiente
25	27	2025-02-28 00:00:00	2025-03-08	21:56:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Crema de Mani		\N	pendiente
26	27	2025-02-28 00:00:00	2025-03-08	21:56:16	Cuarto de Kilo		Vainilla	Arequipe	Crema de Coco		\N	pendiente
27	28	2025-03-12 00:00:00	2025-03-13	23:56:16	Medio Kilo		Vainilla	Arequipe	Crema de Oreo		\N	pendiente
28	25	2025-03-16 00:00:00	1925-03-18	20:56:16	Medio Kilo		Vainilla	Arequipe	Crema de Samba		\N	pendiente
29	29	2025-03-20 00:00:00	2025-03-23	06:56:16	Un Kilo		Vainilla	Chocolate			\N	pendiente
30	16	2025-03-21 00:00:00	2025-03-26	21:56:16	Un Kilo		Chocolate	Chocolate Blanco	Crema de Oreo		\N	pendiente
31	30	2025-03-22 00:00:00	2025-03-25	21:56:16	Medio Kilo		Vainilla	Arequipe	Ninguno		\N	pendiente
32	31	2025-03-23 00:00:00	2025-03-25	09:56:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Fresas con Crema		\N	pendiente
33	25	2025-04-18 00:00:00	2025-05-05	14:56:16	Medio Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
34	25	2025-04-18 00:00:00	2025-05-05	17:56:16	Un Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
35	34	2025-04-23 00:00:00	2025-04-26	21:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Crema de Samba		\N	pendiente
36	35	2025-04-29 00:00:00	2025-05-06	17:56:16	Un Kilo		Chocolate	Chocolate			\N	pendiente
37	36	2025-05-03 00:00:00	2025-05-04	19:26:16	Un Kilo		Vainilla	Chocolate Blanco	Fresas con Crema		\N	pendiente
38	37	2025-05-08 00:00:00	2025-05-12	15:56:16	Medio Kilo		Chocolate	Chocolate			\N	pendiente
39	40	2025-05-26 00:00:00	2025-05-27	09:56:16	Medio Kilo		Chocolate	Chocolate Blanco	Crema de Oreo		\N	pendiente
40	42	2025-05-27 00:00:00	2025-06-13	20:56:16	Medio Kilo		Vainilla	Arequipe	Pie de Parchita		\N	pendiente
41	46	2025-06-01 00:00:00	2025-06-12	21:56:16	Medio Kilo		Chocolate	Chocolate	Ninguno		\N	pendiente
42	47	2025-06-03 00:00:00	2025-06-13	14:56:16	Cuarto de Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
43	47	2025-06-03 00:00:00	2025-06-14	10:56:16	3/4 de kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
44	48	2025-06-04 00:00:00	2025-06-07	23:56:16	Medio Kilo		Vainilla	Arequipe	Pie de Parchita		\N	pendiente
45	2	2025-06-06 00:00:00	2025-06-24	16:56:16	Un Kilo		Vainilla	Chocolate	Fresas con Crema		\N	pendiente
46	50	2025-06-09 00:00:00	2025-06-11	20:56:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Crema de Samba		\N	pendiente
47	52	2025-06-20 00:00:00	2025-06-25	09:56:16	Medio Kilo		Chocolate	Chocolate	Chocolate 		\N	pendiente
48	53	2025-07-01 00:00:00	2025-07-17	19:26:16	Medio Kilo		Vainilla	Arequipe	Crema de Oreo		\N	pendiente
49	54	2025-07-03 00:00:00	2025-07-19	11:26:16	Un Kilo		Chocolate	Chocolate	Crema de Mani		\N	pendiente
50	55	2025-07-05 00:00:00	2025-07-11	20:56:16	Un Kilo		Chocolate	Chocolate	Crema de Oreo		\N	pendiente
51	9	2025-07-15 00:00:00	2025-07-18	22:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo		\N	pendiente
52	58	2025-07-16 00:00:00	2025-08-07	23:26:16	Cuarto de Kilo		Vainilla	Arequipe			\N	pendiente
53	59	2025-07-16 00:00:00	2025-07-19	18:56:16	Un Kilo		Chocolate	Chocolate	Crema de Samba		\N	pendiente
54	60	2025-07-18 00:00:00	2004-08-07	14:26:16						Mini postres	\N	pendiente
55	61	2025-07-19 00:00:00	2025-07-22	21:56:16		Medio kilo				Torta/Postre especial	\N	pendiente
56	62	2025-07-23 00:00:00	2025-08-02	21:56:16	Medio Kilo		Vainilla	Chocolate	Ninguno	Torta Clásica	\N	pendiente
57	63	2025-07-31 00:00:00	2025-08-10	16:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
58	64	2025-08-04 00:00:00	2025-09-16	22:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
59	65	2025-08-04 00:00:00	2025-08-11	05:56:16	Cuarto de Kilo		Vainilla	Chocolate	Avellana 	Torta Clásica	\N	pendiente
60	66	2025-08-12 00:00:00	2025-11-02	12:56:16	Dos kilo y medio 		Vainilla	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
61	16	2025-08-13 00:00:00	2025-08-18	06:56:16	Kilo y Medio		Vainilla	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
62	67	2025-08-14 00:00:00	2025-09-01	20:56:16		Cuarto de kilo				Torta/Postre especial	\N	pendiente
63	68	2025-08-16 00:00:00	2025-09-30	19:56:16	Un Kilo		Chocolate	Chocolate	Chantelle	Torta Clásica	\N	pendiente
64	69	2025-08-16 00:00:00	2025-08-21	21:56:16	Cuarto de Kilo		Chocolate	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
65	70	2025-08-17 00:00:00	2025-09-21	10:26:16	2 pisos 		Vainilla	Arequipe	Crema de Cocosete	Torta Clásica	\N	pendiente
66	71	2025-08-18 00:00:00	2025-08-31	16:56:16		Torta especial 				Torta/Postre especial	\N	pendiente
67	72	2025-08-18 00:00:00	2025-09-07	18:56:16	Para 15 persona 		Vainilla	Arequipe	Fresas con Crema	Torta Clásica	\N	pendiente
68	73	2025-08-19 00:00:00	2025-09-01	06:56:16	Kilo y Medio		Vainilla	Arequipe	Ninguno	Torta Clásica	\N	pendiente
69	73	2025-08-19 00:00:00	2025-09-01	06:56:16						Mini postres	\N	pendiente
70	74	2025-08-19 00:00:00	2025-08-25	21:56:16		Medio kilo				Torta/Postre especial	\N	pendiente
71	75	2025-08-22 00:00:00	2025-08-24	15:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Pie de Limon	Torta Clásica	\N	pendiente
72	76	2025-08-26 00:00:00	2025-09-14	18:56:16	Kilo y Medio		Vainilla	Arequipe	Crema de Samba	Torta Clásica	\N	pendiente
73	77	2025-08-26 00:00:00	1925-08-31	16:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
74	78	2025-08-31 00:00:00	2025-09-02	19:56:16	Medio Kilo		Vainilla	Arequipe	Crema de Oreo	Torta Clásica	\N	pendiente
75	79	2025-09-02 00:00:00	2025-09-21	23:56:16	Un Kilo		Vainilla	Arequipe	Fresas con Crema	Torta Clásica	\N	pendiente
76	80	2025-09-08 00:00:00	2025-09-14	16:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
77	81	2025-09-10 00:00:00	2025-09-19	15:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
78	82	2025-10-01 00:00:00	2025-10-14	21:26:16	Un Kilo		Chocolate	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
79	83	2025-10-12 00:00:00	2025-10-15	07:56:16	Medio Kilo		Vainilla	Arequipe	Pie de Limon	Torta Clásica	\N	pendiente
80	84	2025-10-14 00:00:00	2025-10-18	17:56:16	3/4		Vainilla	Arequipe	Crema de Oreo	Torta Clásica	\N	pendiente
81	16	2025-10-17 00:00:00	2025-10-24	22:56:16	Un Kilo		Vainilla	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
82	85	2025-10-18 00:00:00	2025-10-29	12:26:16		Un kilo				Torta/Postre especial	\N	pendiente
83	86	2025-10-18 00:00:00	2025-11-22	15:56:16	Kilo y Medio		Chocolate	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
84	87	2025-10-19 00:00:00	2025-10-31	13:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Ninguno	Torta Clásica	\N	pendiente
85	16	2025-10-19 00:00:00	2025-10-25	22:56:16	Un Kilo		Chocolate	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
86	88	2025-10-19 00:00:00	2025-10-22	21:56:16	Un Kilo		Vainilla	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
87	89	2025-10-21 00:00:00	2025-10-30	17:56:16	Para 10 personas 		Vainilla	Chocolate Blanco	Fresas con Crema	Torta Clásica	\N	pendiente
88	90	2025-10-25 00:00:00	2025-11-15	18:56:16	Un Kilo		Vainilla	Chocolate Blanco	Pie de Parchita	Torta Clásica	\N	pendiente
89	87	2025-10-28 00:00:00	2025-11-02	15:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Ninguno	Torta Clásica	\N	pendiente
90	91	2025-10-28 00:00:00	2025-10-31	07:56:16		Medio kilo				Torta/Postre especial	\N	pendiente
91	92	2025-10-29 00:00:00	2025-11-01	22:56:16		Un kilo				Torta/Postre especial	\N	pendiente
92	50	2025-11-02 00:00:00	2025-11-05	09:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Crema de Mani	Torta Clásica	\N	pendiente
93	93	2025-11-04 00:00:00	2025-11-05	11:56:16		Un kilo				Torta/Postre especial	\N	pendiente
94	94	2025-11-13 00:00:00	2025-11-22	19:56:16	Medio Kilo		Vainilla	Chocolate	Fresas con Crema	Torta Clásica	\N	pendiente
95	95	2025-11-14 00:00:00	2025-11-12	19:56:16	Dos Kilos		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
96	36	2025-11-22 00:00:00	2025-11-25	20:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
97	98	2025-12-04 00:00:00	2025-12-11	18:56:16		Cuarto de kilo				Torta/Postre especial	\N	pendiente
98	94	2025-12-05 00:00:00	2025-12-12	15:56:16	Medio Kilo		Vainilla	Chocolate	Fresas con Crema	Torta Clásica	\N	pendiente
99	97	2025-12-05 00:00:00	2025-12-09	06:56:16	Cuarto de Kilo		Chocolate	Arequipe	Crema de Oreo	Torta Clásica	\N	pendiente
100	99	2025-12-20 00:00:00	2025-12-23	06:56:16	Medio Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
101	99	2025-12-20 00:00:00	2025-12-23	06:56:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Pie de Limon	Torta Clásica	\N	pendiente
102	100	2025-12-23 00:00:00	2025-12-28	23:56:16	Medio Kilo		Vainilla	Chocolate	Fresas con Crema	Torta Clásica	\N	pendiente
103	99	2025-12-24 00:00:00	2025-12-29	07:56:16	Medio Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
104	102	2025-12-27 00:00:00	2026-01-09	10:56:16	Medio Kilo		Chocolate	Chocolate	Chantelle	Torta Clásica	\N	pendiente
105	103	2025-12-27 00:00:00	2026-01-03	14:56:16	Un Kilo		Vainilla	Arequipe	Crema de Samba	Torta Clásica	\N	pendiente
106	97	2026-01-02 00:00:00	2026-01-06	21:56:16	Un Kilo		Chocolate	Chocolate Blanco	Crema de Cocosete	Torta Clásica	\N	pendiente
107	105	2026-01-05 00:00:00	2026-01-10	22:01:16		Un kilo				Torta/Postre especial	\N	pendiente
108	15	2026-01-08 00:00:00	2026-01-26	11:56:16	Un Kilo		Vainilla	Chocolate Blanco	Pie de Parchita	Torta Clásica	\N	pendiente
109	106	2026-01-08 00:00:00	2026-01-14	21:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Pie de Parchita	Torta Clásica	\N	pendiente
110	107	2026-01-14 00:00:00	2026-01-16	14:56:16	Medio Kilo		Chocolate	Chocolate Blanco	Ninguno	Torta Clásica	\N	pendiente
111	108	2026-01-21 00:00:00	2026-02-07	19:56:16	Un Kilo		Chocolate	Arequipe	Crema de Oreo	Torta Clásica	\N	pendiente
112	109	2026-01-22 00:00:00	2026-01-31	22:26:16	Un Kilo		Vainilla	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
113	16	2026-01-22 00:00:00	2026-01-25	18:56:16	Un Kilo		Vainilla	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
114	110	2026-01-23 00:00:00	2026-01-30	16:56:16	1 kilo y 1 1/4		Vainilla	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
115	111	2026-01-28 00:00:00	2026-01-31	23:56:16	Medio Kilo		Vainilla	Chocolate Blanco	Crema de Oreo	Torta Clásica	\N	pendiente
116	112	2026-02-08 00:00:00	2026-02-15	18:56:16	Medio Kilo		Chocolate	Arequipe	Crema de Oreo	Torta Clásica	\N	pendiente
117	95	2026-02-11 00:00:00	2026-02-15	18:56:16	Un Kilo		Vainilla	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
118	106	2026-02-16 00:00:00	2026-02-25	19:26:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Pie de Parchita	Torta Clásica	\N	pendiente
119	114	2026-02-17 00:00:00	2026-02-18	21:56:16	Un Kilo		Vainilla	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
120	106	2026-02-18 00:00:00	2026-02-27	21:56:16	Cuarto de Kilo		Vainilla	Chocolate Blanco	Fresas con Crema	Torta Clásica	\N	pendiente
121	9	2026-02-20 00:00:00	2026-02-23	22:56:16	Un Kilo		Vainilla	Chocolate Blanco	Fresas con Crema	Torta Clásica	\N	pendiente
122	115	2026-02-23 00:00:00	2026-03-04	22:26:16		Un kilo				Torta/Postre especial	\N	pendiente
123	50	2026-03-12 00:00:00	2026-03-17	21:56:16	Un Kilo		Vainilla	Arequipe	Crema de oreo y crema de samba	Torta Clásica	\N	pendiente
124	60	2026-03-12 00:00:00	2026-03-12	06:56:16	Cuarto de Kilo		Chocolate	Arequipe	Ninguno	Torta Clásica	\N	pendiente
175	51	2025-06-16 00:00:00	2025-06-23	18:56:16	Ya sabes como es 3 cuartos abajo y arriba el corazon		Chocolate	Chocolate	Crema de Oreo		\N	pendiente
259	1	2025-01-02 00:00:00	2025-01-07	15:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Fresas con Crema		\N	pendiente
260	2	2025-01-05 00:00:00	2025-01-13	21:26:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
261	3	2025-01-05 00:00:00	2025-01-18	20:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
262	4	2025-01-06 00:00:00	2025-01-06	23:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
264	2	2025-01-06 00:00:00	2025-01-07	20:26:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Fresas con Crema		\N	pendiente
275	14	2025-01-19 00:00:00	2025-01-21	22:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Chocolate			\N	pendiente
280	18	2025-01-30 00:00:00	1925-01-31	18:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Arequipe	Crema de Mani		\N	pendiente
284	22	2025-02-06 00:00:00	2025-02-10	10:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
289	25	2025-02-24 00:00:00	2025-03-03	18:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate			\N	pendiente
299	32	2025-03-25 00:00:00	2025-03-28	18:56:16	3/4		Marmoleado (Vainilla, Chocolate)	Arequipe	Crema de Samba		\N	pendiente
300	33	2025-04-14 00:00:00	2025-05-01	22:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Arequipe	Ninguno		\N	pendiente
307	38	2025-05-22 00:00:00	2025-05-26	13:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Samba		\N	pendiente
308	9	2025-05-24 00:00:00	2025-05-26	23:26:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Oreo		\N	pendiente
309	33	2025-05-24 00:00:00	2025-06-07	04:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate			\N	pendiente
310	39	2025-05-24 00:00:00	2025-05-31	19:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba		\N	pendiente
312	41	2025-05-26 00:00:00	2025-05-28	20:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Arequipe	Crema de Oreo		\N	pendiente
314	43	2025-05-27 00:00:00	2025-06-08	19:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
315	44	2025-05-31 00:00:00	2025-06-08	18:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Samba		\N	pendiente
316	45	2025-05-31 00:00:00	2025-06-24	06:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate			\N	pendiente
322	49	2025-06-06 00:00:00	2025-06-07	21:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco			\N	pendiente
324	9	2025-06-16 00:00:00	2025-06-21	22:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco			\N	pendiente
330	56	2025-07-09 00:00:00	2025-07-10	22:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Fresas con Crema		\N	pendiente
332	57	2025-07-15 00:00:00	2025-07-30	18:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo		\N	pendiente
341	63	2025-08-05 00:00:00	2025-08-10	16:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
363	43	2025-10-16 00:00:00	2025-11-30	19:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
364	67	2025-10-17 00:00:00	2025-11-06	21:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
377	67	2025-11-04 00:00:00	2025-11-16	18:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Cocosete	Torta Clásica	\N	pendiente
381	96	2025-11-19 00:00:00	2025-11-23	14:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
383	97	2025-11-28 00:00:00	2025-12-04	10:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
384	56	2025-11-28 00:00:00	2025-12-04	22:56:16	Cuarto de Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
385	43	2025-11-28 00:00:00	2025-12-07	17:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
386	74	2025-12-04 00:00:00	2025-12-09	11:56:16	Medio Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Cocosete	Torta Clásica	\N	pendiente
390	71	2025-12-16 00:00:00	2025-12-20	18:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Crema de Samba	Torta Clásica	\N	pendiente
394	101	2025-12-23 00:00:00	2025-12-27	05:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Ninguno	Torta Clásica	\N	pendiente
396	101	2025-12-26 00:00:00	2025-12-27	17:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Arequipe	Ninguno	Torta Clásica	\N	pendiente
400	104	2026-01-02 00:00:00	2026-01-10	17:56:16	Kilo y Medio		Marmoleado (Vainilla, Chocolate)	Arequipe	Crema de Samba	Torta Clásica	\N	pendiente
404	9	2026-01-11 00:00:00	2026-01-13	22:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate Blanco	Fresas con Crema	Torta Clásica	\N	pendiente
406	108	2026-01-20 00:00:00	2026-02-08	14:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Oreo	Torta Clásica	\N	pendiente
414	113	2026-02-12 00:00:00	2026-02-15	19:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Samba	Torta Clásica	\N	pendiente
415	108	2026-02-16 00:00:00	2026-03-15	19:56:16	Un Kilo		Marmoleado (Vainilla, Chocolate)	Chocolate	Crema de Coco	Torta Clásica	\N	pendiente
\.


--
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: danielapineda
--

SELECT pg_catalog.setval('public.clientes_id_seq', 115, true);


--
-- Name: minipostres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: danielapineda
--

SELECT pg_catalog.setval('public.minipostres_id_seq', 1, false);


--
-- Name: pedido_postres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: danielapineda
--

SELECT pg_catalog.setval('public.pedido_postres_id_seq', 1, false);


--
-- Name: pedidos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: danielapineda
--

SELECT pg_catalog.setval('public.pedidos_id_seq', 427, true);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: minipostres minipostres_pkey; Type: CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.minipostres
    ADD CONSTRAINT minipostres_pkey PRIMARY KEY (id);


--
-- Name: pedido_postres pedido_postres_pkey; Type: CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedido_postres
    ADD CONSTRAINT pedido_postres_pkey PRIMARY KEY (id);


--
-- Name: pedidos pedido_unico; Type: CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedido_unico UNIQUE (cliente_id, fecha_entrega, hora_entrega, tipo_pedido, tipo_torta, peso_torta, sabor_ponque, relleno_base, relleno_especial);


--
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- Name: pedido_postres pedido_postres_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedido_postres
    ADD CONSTRAINT pedido_postres_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id);


--
-- Name: pedido_postres pedido_postres_postre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedido_postres
    ADD CONSTRAINT pedido_postres_postre_id_fkey FOREIGN KEY (postre_id) REFERENCES public.minipostres(id);


--
-- Name: pedidos pedidos_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: danielapineda
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 1D5XVw37Ivr1L1uRtbKY1Mdf1LaF6piJv0mEJ3LaAGQIkZG7RdMt3xTzb29nwhq

