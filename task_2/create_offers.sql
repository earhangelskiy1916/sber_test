-- public.offers определение

-- Drop table

-- DROP TABLE public.offers;

CREATE TABLE public.offers (
	visit_dt date NULL,
	product_offer varchar(255) NULL,
	employee_id int NULL,
	client_id int8 NULL,
	offer_qty int NULL
);