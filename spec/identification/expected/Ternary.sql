CREATE TABLE Ternary (
	-- Ternary involves first-Thing
	FirstThing                              Thing NOT NULL,
	-- Ternary involves second-Thing
	SecondThing                             Thing NOT NULL,
	-- Ternary involves third-Thing
	ThirdThing                              Thing NOT NULL,
	-- Primary index to Ternary(First Thing, Second Thing in "first-Thing with second-Thing relates to third-Thing")
	PRIMARY KEY CLUSTERED(FirstThing, SecondThing),
	-- Unique index to Ternary(Third Thing, Second Thing in "first-Thing with second-Thing relates to third-Thing")
	UNIQUE NONCLUSTERED(SecondThing, ThirdThing)
)
GO


