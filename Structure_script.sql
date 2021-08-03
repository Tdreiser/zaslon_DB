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
SELECT count(m.*) AS count,
       m.theme_id
FROM messages m
         LEFT JOIN themes t ON m.theme_id = t.id
GROUP BY m.theme_id;

alter table messages_into_theme
    owner to postgres;

create view comments_into_message(count, message_id) as
SELECT count(c.*) AS count,
       c.message_id
FROM comments c
         LEFT JOIN messages m ON m.id = c.message_id
GROUP BY c.message_id;

alter table comments_into_message
    owner to postgres;

create view user_likes(id, likes, dislikes) as
SELECT u.id,
       ((SELECT sum(m.likes) AS sum)) + ((SELECT sum(c.likes) / 3 AS sum2)) +
       ((SELECT sum(t.likes) / 4 AS sum5))    AS likes,
       ((SELECT sum(m.dislikes) AS sum3)) + ((SELECT sum(c.dislikes) / 3 AS sum4)) +
       ((SELECT sum(t.dislikes) / 4 AS sum6)) AS dislikes
FROM users u
         JOIN messages m ON u.id = m.user_id
         JOIN comments c ON u.id = c.user_id
         JOIN themes t ON u.id = t.user_id
GROUP BY u.id;

alter table user_likes
    owner to postgres;

create view view_name(id, likes) as
SELECT users.id,
       (SELECT COALESCE(sum(t.likes), 0::bigint) AS "coalesce") AS likes
FROM users
         JOIN messages m ON users.id = m.user_id
         JOIN themes t ON users.id = t.user_id
GROUP BY users.id;

alter table view_name
    owner to postgres;


