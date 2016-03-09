CREATE TABLE Author (
	-- Author has Author Id
	AuthorId                                BIGINT NOT NULL IDENTITY,
	-- Author is called Name
	AuthorName                              VARCHAR(64) NOT NULL,
	-- Primary index to Author over PresenceConstraint over (Author Id in "Author has Author Id") occurs at most one time
	PRIMARY KEY CLUSTERED(AuthorId),
	-- Unique index to Author over PresenceConstraint over (Author Name in "author-Name is of Author") occurs at most one time
	UNIQUE NONCLUSTERED(AuthorName)
);


CREATE TABLE Comment (
	-- Comment has Comment Id
	CommentId                               BIGINT NOT NULL IDENTITY,
	-- Comment was written by Author that has Author Id
	AuthorId                                BIGINT NOT NULL,
	-- Comment consists of text-Content and maybe Content is of Style
	ContentStyle                            VARCHAR(20) NULL,
	-- Comment consists of text-Content and Content has Text
	ContentText                             VARCHAR(MAX) NOT NULL,
	-- Paragraph ID
	ParagraphID                             BIGINT IDENTITY NOT NULL,
	-- Primary index to Comment over PresenceConstraint over (Comment Id in "Comment has Comment Id") occurs at most one time
	PRIMARY KEY CLUSTERED(CommentId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
);


CREATE TABLE Paragraph (
	-- Paragraph ID
	ParagraphID                             BIGINT IDENTITY NOT NULL,
	-- Paragraph involves Post that has Post Id
	PostId                                  BIGINT NOT NULL,
	-- Paragraph involves Ordinal
	Ordinal                                 INTEGER NOT NULL,
	-- Paragraph contains Content that maybe is of Style
	ContentStyle                            VARCHAR(20) NULL,
	-- Paragraph contains Content that has Text
	ContentText                             VARCHAR(MAX) NOT NULL,
	-- Primary index to Paragraph
	PRIMARY KEY CLUSTERED(ParagraphID),
	-- Unique index to Paragraph over PresenceConstraint over (Post, Ordinal in "Post includes Ordinal paragraph") occurs at most one time
	UNIQUE NONCLUSTERED(PostId, Ordinal)
);


CREATE TABLE Post (
	-- Post has Post Id
	PostId                                  BIGINT NOT NULL IDENTITY,
	-- Post was written by Author that has Author Id
	AuthorId                                BIGINT NOT NULL,
	-- Post belongs to Topic that has Topic Id
	TopicId                                 BIGINT NOT NULL,
	-- Primary index to Post over PresenceConstraint over (Post Id in "Post has Post Id") occurs at most one time
	PRIMARY KEY CLUSTERED(PostId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
);


CREATE TABLE Topic (
	-- Topic has Topic Id
	TopicId                                 BIGINT NOT NULL IDENTITY,
	-- Topic is called topic-Name
	TopicName                               VARCHAR(64) NOT NULL,
	-- maybe Topic belongs to parent-Topic and Topic has Topic Id
	ParentTopicId                           BIGINT NULL,
	-- Primary index to Topic over PresenceConstraint over (Topic Id in "Topic has Topic Id") occurs at most one time
	PRIMARY KEY CLUSTERED(TopicId),
	-- Unique index to Topic over PresenceConstraint over (Topic Name in "Topic is called topic-Name") occurs at most one time
	UNIQUE NONCLUSTERED(TopicName),
	FOREIGN KEY (ParentTopicId) REFERENCES Topic (TopicId)
);


ALTER TABLE Comment
	ADD FOREIGN KEY (ParagraphID) REFERENCES Paragraph (ParagraphID);


ALTER TABLE Paragraph
	ADD FOREIGN KEY (PostId) REFERENCES Post (PostId);


ALTER TABLE Post
	ADD FOREIGN KEY (TopicId) REFERENCES Topic (TopicId);

