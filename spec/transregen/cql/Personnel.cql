// Example taken from Principles of Data Integration by Doan, Halevy and Ives

schema Personnel;

each ID is written as Auto Counter;
each Addr is written as String;
each Name is written as String;
each Salary is written as Decimal;

Personnel is identified by its ID;
Personnel has one Name;
Personnel has one Salary;
Personnel has one Addr;
