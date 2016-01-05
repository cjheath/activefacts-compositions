// This example shows identification of an entity by two roles, both binary
vocabulary Person;

Name is written as String;

each Person is identified by family-Name and given-Name where
    that Person has one given-Name,
    that Person has one family-Name;
