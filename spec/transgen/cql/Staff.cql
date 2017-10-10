// Example taken from Principles of Data Integration by Doan, Halevy and Ives

schema Staff;

each ID is written as Auto Counter;
each Addr is written as String;
each Name is written as String;
each Salary is written as Decimal;

// each Address is identified by its ID;
// Address has one Addr;

each Professor is identified by its ID;
Professor has one Name;
Professor has one Salary;

each GPA is written as Decimal;
each Year is written as Integer;

each Student is identified by its Name;
Student has one GPA;
Student is studying in one Year;

each Rank is written as Integer;
each HrRate is written as Decimal;

each PayRate is identified by its Rank;
PayRate has one HrRate;

each Hours is written as Decimal;

WorksOn is identified by its Name;
WorksOn has one Hours;
