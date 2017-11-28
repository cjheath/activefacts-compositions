CREATE TABLE Author (
	-- Author has Author Id
	AuthorId                                BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Author is called Name
	AuthorName                              VARCHAR(64) NOT NULL,
	-- Primary index to Author(Author Id in "Author has Author Id")
	PRIMARY KEY(AuthorId),
	-- Unique index to Author(Author Name in "author-Name is of Author")
	UNIQUE(AuthorName)
);


CREATE TABLE Comment (
	-- Comment has Comment Id
	CommentId                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Comment was written by Author that has Author Id
	AuthorId                                BIGINT NOT NULL,
	-- Comment consists of text-Content and maybe Content is of Style
	ContentStyle                            VARCHAR(20) NULL,
	-- Comment consists of text-Content and Content has Text
	ContentText                             VARCHAR(MAX) NOT NULL,
	-- Comment is on Paragraph that involves Post that has Post Id
	ParagraphPostId                         BIGINT NOT NULL,
	-- Comment is on Paragraph that involves Ordinal
	ParagraphOrdinal                        INTEGER NOT NULL,
	-- Primary index to Comment(Comment Id in "Comment has Comment Id")
	PRIMARY KEY(CommentId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
);


CREATE TABLE Paragraph (
	-- Paragraph involves Post that has Post Id
	PostId                                  BIGINT NOT NULL,
	-- Paragraph involves Ordinal
	Ordinal                                 INTEGER NOT NULL,
	-- Paragraph contains Content that maybe is of Style
	ContentStyle                            VARCHAR(20) NULL,
	-- Paragraph contains Content that has Text
	ContentText                             VARCHAR(MAX) NOT NULL,
	-- Primary index to Paragraph(Post, Ordinal in "Post includes Ordinal paragraph")
	PRIMARY KEY(PostId, Ordinal)
);


CREATE TABLE Post (
	-- Post has Post Id
	PostId                                  BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Post was written by Author that has Author Id
	AuthorId                                BIGINT NOT NULL,
	-- Post belongs to Topic that has Topic Id
	TopicId                                 BIGINT NOT NULL,
	-- Primary index to Post(Post Id in "Post has Post Id")
	PRIMARY KEY(PostId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
);


CREATE TABLE Topic (
	-- Topic has Topic Id
	TopicId                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Topic is called topic-Name
	TopicName                               VARCHAR(64) NOT NULL,
	-- maybe Topic belongs to parent-Topic and Topic has Topic Id
	ParentTopicId                           BIGINT NULL,
	-- Primary index to Topic(Topic Id in "Topic has Topic Id")
	PRIMARY KEY(TopicId),
	-- Unique index to Topic(Topic Name in "Topic is called topic-Name")
	UNIQUE(TopicName),
	FOREIGN KEY (ParentTopicId) REFERENCES Topic (TopicId)
);


ALTER TABLE Comment
	ADD FOREIGN KEY (ParagraphPostId, ParagraphOrdinal) REFERENCES Paragraph (PostId, Ordinal);

ALTER TABLE Paragraph
	ADD FOREIGN KEY (PostId) REFERENCES Post (PostId);

ALTER TABLE Post
	ADD FOREIGN KEY (TopicId) REFERENCES Topic (TopicId);
