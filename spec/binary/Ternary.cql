vocabulary Ternary;

Cinema ID is written as Auto Counter;
DateTime Value is written as Date Time;
Film ID is written as Auto Counter;
Name is written as String;

Cinema is identified by its ID;

DateTime is identified by its Value;

Film is identified by its ID;
Film has at most one Name;

Session is where
	Cinema shows Film on DateTime,
	Film is showing on DateTime at Cinema,
	Cinema at DateTime is showing one Film;

Session is confirmed;
