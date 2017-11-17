/*
 * An example of a table with multiple unique identifiers
 */
vocabulary Countries;

ISO3166Code2 is written as String(2);
ISO3166Code3 is written as String(3);
Country is independent identified by ISO3166Code3 where
    Country has one ISO3166Code3,
    ISO3166Code3 is of at most one Country;
Country has one ISO3166Code2, ISO3166Code2 is of one Country;
Country Name is written as String(60);
Country is called one Country Name, Country Name is of at most one Country;
ISO3166Numeric3 is written as Integer;
Country has one ISO3166Numeric3, ISO3166Numeric3 is of one Country;

