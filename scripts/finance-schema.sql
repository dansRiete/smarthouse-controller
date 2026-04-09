create table category
(
    id          serial
        primary key,
    name        varchar(50) not null
        unique,
    description text,
    created_at  timestamp default CURRENT_TIMESTAMP
);

alter table category
    owner to smarthouse;

create table credit_card
(
    id                     serial
        primary key,
    name                   varchar(100) not null,
    bank_name              varchar(100),
    last_four              varchar(4),
    credit_limit           numeric(15, 2),
    interest_rate_apr      numeric(5, 2),
    statement_day_of_month integer
        constraint credit_card_statement_day_of_month_check
            check ((statement_day_of_month >= 1) AND (statement_day_of_month <= 31)),
    grace_period_days      integer,
    is_active              boolean   default true,
    created_at             timestamp default CURRENT_TIMESTAMP
);

alter table credit_card
    owner to smarthouse;

create table transaction
(
    id               serial
        primary key,
    card_id          integer
        references credit_card,
    category_id      integer
        references category,
    transaction_date date                    not null,
    post_date        date,
    amount           numeric(15, 2)          not null,
    description      text,
    is_pending       boolean   default false,
    created_at       timestamp default CURRENT_TIMESTAMP,
    ignore           boolean   default false not null,
    original_amount  numeric(15, 2),
    subcategory      text
);

alter table transaction
    owner to smarthouse;

create table statement
(
    id                serial
        primary key,
    card_id           integer
        references credit_card,
    statement_date    date           not null,
    due_date          date           not null,
    statement_balance numeric(15, 2) not null,
    minimum_payment   numeric(15, 2),
    paid_amount       numeric(15, 2) default 0,
    is_fully_paid     boolean        default false,
    interest_charged  numeric(15, 2) default 0,
    created_at        timestamp      default CURRENT_TIMESTAMP,
    unique (card_id, statement_date)
);

alter table statement
    owner to smarthouse;

create table spending_report
(
    id               serial
        primary key,
    card_number      varchar(4),
    card_name        text,
    transaction_date date           not null,
    amount           numeric(15, 2) not null,
    description      text,
    category         text,
    subcategory      text,
    filename         text,
    original_amount  numeric(15, 2),
    created_at       timestamp default CURRENT_TIMESTAMP,
    modified_at      timestamp default CURRENT_TIMESTAMP
);

alter table spending_report
    owner to smarthouse;

INSERT INTO public.category (id, name) VALUES (1, 'Groceries');
INSERT INTO public.category (id, name) VALUES (2, 'Dining Out');
INSERT INTO public.category (id, name) VALUES (3, 'Utilities');
INSERT INTO public.category (id, name) VALUES (4, 'Transportation');
INSERT INTO public.category (id, name) VALUES (5, 'Entertainment');
INSERT INTO public.category (id, name) VALUES (6, 'Shopping');
INSERT INTO public.category (id, name) VALUES (7, 'Health');
INSERT INTO public.category (id, name) VALUES (8, 'Travel');
INSERT INTO public.category (id, name) VALUES (9, 'Subscription');
INSERT INTO public.category (id, name) VALUES (10, 'Payment');
INSERT INTO public.category (id, name) VALUES (11, 'Education');
INSERT INTO public.category (id, name) VALUES (12, 'Insurance');
INSERT INTO public.category (id, name) VALUES (17, 'Food');
INSERT INTO public.category (id, name) VALUES (24, 'Other');
INSERT INTO public.category (id, name) VALUES (56, 'Electronics');
INSERT INTO public.category (id, name) VALUES (57, 'Home');
INSERT INTO public.category (id, name) VALUES (63, 'Fees & Interest');

