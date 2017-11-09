CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE author (
	-- Author has Author Id
	author_id                               BIGSERIAL NOT NULL,
	-- Author is called Name
	author_name                             VARCHAR(64) NOT NULL,
	-- Primary index to Author over PresenceConstraint over (Author Id in "Author has Author Id") occurs at most one time
	PRIMARY KEY(author_id),
	-- Unique index to Author over PresenceConstraint over (Author Name in "author-Name is of Author") occurs at most one time
	UNIQUE(author_name)
);


CREATE TABLE comment (
	-- Comment has Comment Id
	comment_id                              BIGSERIAL NOT NULL,
	-- Comment was written by Author that has Author Id
	author_id                               BIGINT NOT NULL,
	-- Comment consists of text-Content and maybe Content is of Style
	content_style                           VARCHAR(20) NULL,
	-- Comment consists of text-Content and Content has Text
	content_text                            VARCHAR(MAX) NOT NULL,
	-- Comment is on Paragraph that involves Post that has Post Id
	paragraph_post_id                       BIGINT NOT NULL,
	-- Comment is on Paragraph that involves Ordinal
	paragraph_ordinal                       INTEGER NOT NULL,
	-- Primary index to Comment over PresenceConstraint over (Comment Id in "Comment has Comment Id") occurs at most one time
	PRIMARY KEY(comment_id),
	FOREIGN KEY (author_id) REFERENCES author (author_id)
);


CREATE TABLE paragraph (
	-- Paragraph involves Post that has Post Id
	post_id                                 BIGINT NOT NULL,
	-- Paragraph involves Ordinal
	ordinal                                 INTEGER NOT NULL,
	-- Paragraph contains Content that maybe is of Style
	content_style                           VARCHAR(20) NULL,
	-- Paragraph contains Content that has Text
	content_text                            VARCHAR(MAX) NOT NULL,
	-- Primary index to Paragraph over PresenceConstraint over (Post, Ordinal in "Post includes Ordinal paragraph") occurs at most one time
	PRIMARY KEY(post_id, ordinal)
);


CREATE TABLE post (
	-- Post has Post Id
	post_id                                 BIGSERIAL NOT NULL,
	-- Post was written by Author that has Author Id
	author_id                               BIGINT NOT NULL,
	-- Post belongs to Topic that has Topic Id
	topic_id                                BIGINT NOT NULL,
	-- Primary index to Post over PresenceConstraint over (Post Id in "Post has Post Id") occurs at most one time
	PRIMARY KEY(post_id),
	FOREIGN KEY (author_id) REFERENCES author (author_id)
);


CREATE TABLE topic (
	-- Topic has Topic Id
	topic_id                                BIGSERIAL NOT NULL,
	-- Topic is called topic-Name
	topic_name                              VARCHAR(64) NOT NULL,
	-- maybe Topic belongs to parent-Topic and Topic has Topic Id
	parent_topic_id                         BIGINT NULL,
	-- Primary index to Topic over PresenceConstraint over (Topic Id in "Topic has Topic Id") occurs at most one time
	PRIMARY KEY(topic_id),
	-- Unique index to Topic over PresenceConstraint over (Topic Name in "Topic is called topic-Name") occurs at most one time
	UNIQUE(topic_name),
	FOREIGN KEY (parent_topic_id) REFERENCES topic (topic_id)
);


ALTER TABLE comment
	ADD FOREIGN KEY (paragraph_post_id, paragraph_ordinal) REFERENCES paragraph (post_id, ordinal);


ALTER TABLE paragraph
	ADD FOREIGN KEY (post_id) REFERENCES post (post_id);


ALTER TABLE post
	ADD FOREIGN KEY (topic_id) REFERENCES topic (topic_id);

