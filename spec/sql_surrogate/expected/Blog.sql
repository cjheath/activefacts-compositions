CREATE TABLE Author (
	-- Author has Author Id
	AuthorId                                int NULL IDENTITY,
	-- Author is called Name
	AuthorName                              varchar(64) NULL,
	-- Primary index to Author over PresenceConstraint over (Author Id in "Author has Author Id") occurs at most one time
	PRIMARY KEY CLUSTERED(AuthorId),
	-- Unique index to Author over PresenceConstraint over (Author Name in "author-Name is of Author") occurs at most one time
	UNIQUE NONCLUSTERED(AuthorName)
)
GO

CREATE TABLE Comment (
	-- Comment has Comment Id
	CommentId                               int NULL IDENTITY,
	-- Comment was written by Author that has Author Id
	AuthorId                                int NULL,
	-- Comment consists of text-Content and maybe Content is of Style
	ContentStyle                            varchar(20) NOT NULL,
	-- Comment consists of text-Content and Content has Text
	ContentText                             text NULL,
	-- Paragraph ID
	ParagraphID                             BIGINT IDENTITY NOT NULL,
	-- Primary index to Comment over PresenceConstraint over (Comment Id in "Comment has Comment Id") occurs at most one time
	PRIMARY KEY CLUSTERED(CommentId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
)
GO

CREATE TABLE Paragraph (
	-- Paragraph ID
	ParagraphID                             BIGINT IDENTITY NOT NULL,
	-- Paragraph involves Post that has Post Id
	PostId                                  int NULL,
	-- Paragraph involves Ordinal
	Ordinal                                 int NULL,
	-- Paragraph contains Content that maybe is of Style
	ContentStyle                            varchar(20) NOT NULL,
	-- Paragraph contains Content that has Text
	ContentText                             text NULL,
	-- Primary index to Paragraph
	PRIMARY KEY CLUSTERED(ParagraphID),
	-- Unique index to Paragraph over PresenceConstraint over (Post, Ordinal in "Post includes Ordinal paragraph") occurs at most one time
	UNIQUE NONCLUSTERED(PostId, Ordinal)
)
GO

CREATE TABLE Post (
	-- Post has Post Id
	PostId                                  int NULL IDENTITY,
	-- Post was written by Author that has Author Id
	AuthorId                                int NULL,
	-- Post belongs to Topic that has Topic Id
	TopicId                                 int NULL,
	-- Primary index to Post over PresenceConstraint over (Post Id in "Post has Post Id") occurs at most one time
	PRIMARY KEY CLUSTERED(PostId),
	FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId)
)
GO

CREATE TABLE Topic (
	-- Topic has Topic Id
	TopicId                                 int NULL IDENTITY,
	-- Topic is called topic-Name
	TopicName                               varchar(64) NULL,
	-- maybe Topic belongs to parent-Topic and Topic has Topic Id
	ParentTopicId                           int NOT NULL,
	-- Primary index to Topic over PresenceConstraint over (Topic Id in "Topic has Topic Id") occurs at most one time
	PRIMARY KEY CLUSTERED(TopicId),
	-- Unique index to Topic over PresenceConstraint over (Topic Name in "Topic is called topic-Name") occurs at most one time
	UNIQUE NONCLUSTERED(TopicName),
	FOREIGN KEY (ParentTopicId) REFERENCES Topic (TopicId)
)
GO

ALTER TABLE Paragraph
	ADD FOREIGN KEY (ParagraphID) REFERENCES Paragraph (ParagraphID)
GO

ALTER TABLE Post
	ADD FOREIGN KEY (PostId) REFERENCES Post (PostId)
GO

ALTER TABLE Topic
	ADD FOREIGN KEY (TopicId) REFERENCES Topic (TopicId)
GO
