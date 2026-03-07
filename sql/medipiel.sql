--
-- PostgreSQL database dump
--

\restrict l5mVLaAwXkwrnuu4sfCbxqDx0FEpcaeSZ8m0obnGhlHs10TLQ4eKBvGVgcBnBkh

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-03-07 16:38:05

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

ALTER TABLE ONLY public.inventory_movements DROP CONSTRAINT fk_product_id_inv;
ALTER TABLE ONLY public.order_items DROP CONSTRAINT fk_product_id;
ALTER TABLE ONLY public.inventory_movements DROP CONSTRAINT fk_order_id_inv;
ALTER TABLE ONLY public.order_items DROP CONSTRAINT fk_order_id;
ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_customer_id;
DROP INDEX public.idx_order_pending;
DROP INDEX public.idx_order_items_product_id;
ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
ALTER TABLE ONLY public.order_items DROP CONSTRAINT order_items_pkey;
ALTER TABLE ONLY public.inventory_movements DROP CONSTRAINT inventory_movements_pkey;
ALTER TABLE ONLY public.customers DROP CONSTRAINT customers_pkey;
ALTER TABLE public.products ALTER COLUMN product_id DROP DEFAULT;
ALTER TABLE public.orders ALTER COLUMN order_id DROP DEFAULT;
ALTER TABLE public.order_items ALTER COLUMN order_items_id DROP DEFAULT;
ALTER TABLE public.inventory_movements ALTER COLUMN inv_mov_id DROP DEFAULT;
ALTER TABLE public.customers ALTER COLUMN customer_id DROP DEFAULT;
DROP SEQUENCE public.products_product_id_seq;
DROP TABLE public.products;
DROP SEQUENCE public.orders_order_id_seq;
DROP TABLE public.orders;
DROP SEQUENCE public.order_items_order_items_id_seq;
DROP TABLE public.order_items;
DROP SEQUENCE public.inventory_movements_inv_mov_id_seq;
DROP TABLE public.inventory_movements;
DROP SEQUENCE public.customers_customer_id_seq;
DROP TABLE public.customers;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16389)
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    customer_name character varying NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16388)
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 219
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- TOC entry 228 (class 1259 OID 16453)
-- Name: inventory_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_movements (
    inv_mov_id integer NOT NULL,
    product_id integer NOT NULL,
    order_id integer NOT NULL,
    quantity integer NOT NULL,
    movement_type character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 227 (class 1259 OID 16452)
-- Name: inventory_movements_inv_mov_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_movements_inv_mov_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 227
-- Name: inventory_movements_inv_mov_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_movements_inv_mov_id_seq OWNED BY public.inventory_movements.inv_mov_id;


--
-- TOC entry 226 (class 1259 OID 16430)
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    order_items_id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    CONSTRAINT check_qty_positive CHECK ((quantity > 0))
);


--
-- TOC entry 225 (class 1259 OID 16429)
-- Name: order_items_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_order_items_id_seq OWNED BY public.order_items.order_items_id;


--
-- TOC entry 224 (class 1259 OID 16412)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    total_amount numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_order_status CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'rejected'::character varying])::text[])))
);


--
-- TOC entry 223 (class 1259 OID 16411)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 222 (class 1259 OID 16401)
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    product_name character varying(100),
    price numeric(10,2),
    stock integer DEFAULT 0 NOT NULL,
    CONSTRAINT check_stock_min CHECK ((stock >= 0))
);


--
-- TOC entry 221 (class 1259 OID 16400)
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 221
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- TOC entry 4775 (class 2604 OID 16392)
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- TOC entry 4782 (class 2604 OID 16456)
-- Name: inventory_movements inv_mov_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements ALTER COLUMN inv_mov_id SET DEFAULT nextval('public.inventory_movements_inv_mov_id_seq'::regclass);


--
-- TOC entry 4781 (class 2604 OID 16433)
-- Name: order_items order_items_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_items_id SET DEFAULT nextval('public.order_items_order_items_id_seq'::regclass);


--
-- TOC entry 4778 (class 2604 OID 16415)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4776 (class 2604 OID 16404)
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- TOC entry 4952 (class 0 OID 16389)
-- Dependencies: 220
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.customers VALUES (1, 'Juan Perez');
INSERT INTO public.customers VALUES (2, 'Maria Garcia');
INSERT INTO public.customers VALUES (3, 'Carlos Lopez');


--
-- TOC entry 4960 (class 0 OID 16453)
-- Dependencies: 228
-- Data for Name: inventory_movements; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4958 (class 0 OID 16430)
-- Dependencies: 226
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items VALUES (1, 1, 1, 1, 1500.00);
INSERT INTO public.order_items VALUES (2, 1, 2, 1, 25.50);
INSERT INTO public.order_items VALUES (3, 2, 3, 2, 450.00);
INSERT INTO public.order_items VALUES (4, 3, 3, 1, 450.00);


--
-- TOC entry 4956 (class 0 OID 16412)
-- Dependencies: 224
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES (1, 1, 'pending', 1525.50, '2026-03-07 12:52:38.718956');
INSERT INTO public.orders VALUES (2, 2, 'pending', 900.00, '2026-03-07 12:52:38.718956');
INSERT INTO public.orders VALUES (3, 3, 'pending', 450.00, '2026-03-07 12:52:38.718956');


--
-- TOC entry 4954 (class 0 OID 16401)
-- Dependencies: 222
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES (1, 'Laptop Gamer Pro', 1500.00, 10);
INSERT INTO public.products VALUES (2, 'Mouse Inalámbrico', 25.50, 50);
INSERT INTO public.products VALUES (3, 'Monitor 4K 27"', 450.00, 2);


--
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 219
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 3, true);


--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 227
-- Name: inventory_movements_inv_mov_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_movements_inv_mov_id_seq', 1, false);


--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_order_items_id_seq', 4, true);


--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 3, true);


--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 221
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_product_id_seq', 3, true);


--
-- TOC entry 4788 (class 2606 OID 16398)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 4798 (class 2606 OID 16464)
-- Name: inventory_movements inventory_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT inventory_movements_pkey PRIMARY KEY (inv_mov_id);


--
-- TOC entry 4796 (class 2606 OID 16441)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_items_id);


--
-- TOC entry 4793 (class 2606 OID 16423)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4790 (class 2606 OID 16410)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4794 (class 1259 OID 16476)
-- Name: idx_order_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);


--
-- TOC entry 4791 (class 1259 OID 16475)
-- Name: idx_order_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_pending ON public.orders USING btree (status) WHERE ((status)::text = 'pending'::text);


--
-- TOC entry 4799 (class 2606 OID 16424)
-- Name: orders fk_customer_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- TOC entry 4800 (class 2606 OID 16442)
-- Name: order_items fk_order_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 4802 (class 2606 OID 16470)
-- Name: inventory_movements fk_order_id_inv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT fk_order_id_inv FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- TOC entry 4801 (class 2606 OID 16447)
-- Name: order_items fk_product_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- TOC entry 4803 (class 2606 OID 16465)
-- Name: inventory_movements fk_product_id_inv; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_movements
    ADD CONSTRAINT fk_product_id_inv FOREIGN KEY (product_id) REFERENCES public.products(product_id);


-- Completed on 2026-03-07 16:38:07

--
-- PostgreSQL database dump complete
--

\unrestrict l5mVLaAwXkwrnuu4sfCbxqDx0FEpcaeSZ8m0obnGhlHs10TLQ4eKBvGVgcBnBkh

