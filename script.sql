create table users
(
    id           serial not null
        constraint users_pk
            primary key,
    login        char(20),
    user_role    char(20),
    date_creaton date default CURRENT_TIMESTAMP
);

alter table users
    owner to postgres;

create table sections
(
    id   serial not null
        constraint section_pk
            primary key,
    name char(50)
);

comment on table sections is 'Разделы, возможно будут создаваться только админами';

alter table sections
    owner to postgres;

create table themes
(
    id            serial not null
        constraint themes_pk
            primary key,
    name          char(50),
    section_id    integer
        constraint themes_sections_id_fk
            references sections,
    date_creation date    default CURRENT_TIMESTAMP,
    user_id       integer
        constraint themes_users_id_fk
            references users,
    likes         integer default 0,
    dislikes      integer default 0
);

comment on table themes is 'Темы: содержат в себе сообщения';

alter table themes
    owner to postgres;

create unique index themes_id_uindex
    on themes (id);

create table messages
(
    id            serial not null
        constraint messages_pk
            primary key,
    theme_id      integer
        constraint messages_themes_id_fk
            references themes,
    text          text,
    user_id       integer
        constraint messages_users_id_fk
            references users,
    likes         integer default 0,
    dislikes      integer default 0,
    date_creation date    default CURRENT_TIMESTAMP
);

comment on table messages is 'Сообщения: содержат в себе комментарии';

alter table messages
    owner to postgres;

create unique index messages_id_uindex
    on messages (id);

create table comments
(
    id            serial not null
        constraint comments_pk
            primary key,
    message_id    integer
        constraint comments_messages_id_fk
            references messages,
    text          text,
    user_id       integer
        constraint comments_users_id_fk
            references users,
    date_creation date    default CURRENT_TIMESTAMP,
    likes         integer default 0,
    dislikes      integer default 0
);

alter table comments
    owner to postgres;

create unique index comments_id_uindex
    on comments (id);

create view messages_into_theme(count, theme_id) as
SELECT (SELECT COALESCE(count(m.*), 0::bigint) AS count) AS count,
       t.id                                              AS theme_id
FROM themes t
         LEFT JOIN messages m ON m.theme_id = t.id
GROUP BY t.id;

alter table messages_into_theme
    owner to postgres;

create view comments_into_message(count, message_id) as
SELECT (SELECT COALESCE(count(c.*), 0::bigint) AS count) AS count,
       m.id                                              AS message_id
FROM messages m
         LEFT JOIN comments c ON m.id = c.message_id
GROUP BY m.id;

alter table comments_into_message
    owner to postgres;

create view user_stats(id, likes, dislikes) as
SELECT users.id,
       ((SELECT COALESCE(sum(t.likes), 0::bigint) AS "coalesce")) +
       ((SELECT COALESCE(sum(m.likes), 0::bigint) AS "coalesce"))    AS likes,
       ((SELECT COALESCE(sum(t.dislikes), 0::bigint) AS "coalesce")) +
       ((SELECT COALESCE(sum(m.dislikes), 0::bigint) AS "coalesce")) AS dislikes
FROM users
         LEFT JOIN messages m ON users.id = m.user_id
         LEFT JOIN themes t ON users.id = t.user_id
GROUP BY users.id;

alter table user_stats
    owner to postgres;


