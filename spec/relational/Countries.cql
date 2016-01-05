// This examples shows identification of a ValueType table by its value,
// and of an EntityType by a foreign key on to that value
vocabulary Countries;

Country Code [separate] is written as Char(3);

Country [separate] is identified by its Code;
