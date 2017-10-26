/*
 * FIML definitions for the schema used in Data Vault 2.0 Modeling book by Dan Linstedt
 */
schema DV2Book;

each ID is written as Auto Counter;
each Name is written as String(48);
each Tail Number is written as String(12);
each Flight Number is written as String(12);

// Airline
each Airline is identified by its ID;

// Airport
each Runway Length is written as Decimal(8,2);
each Runway Elevation is written as Decimal(8,2);
each Longitude is written as Decimal(10,4);
each Latitude is written as Decimal(10,4);
each Telephone Number is written as String(12);
each Website URL is written as String(128);

each Airport is identified by its Name;
Airport has at most one Runway Length;
Airport is at at most one Runway Elevation;
Airport is at most one Longitude;
Airport is at most one Latitude;
Airport has at one Telephone Number;
Airport has at most one Website URL;

each Flight Code is identified by Airline /*and Flight Number*/ where
    Flight Code is of one Airline, Airline has Flight Code/*,*/
    /*Flight Code has one Flight Number, Flight Numnber is of Flight Code*/;

each Connection [separate] is where
    Airline flies from origin- Airport to destination- Airport with flight Flight Number;

each Fixed Base Operator is where
    Airline flies from Airport;

// Airplane
each Airplane [separate] is identified by Tail Number where
    Airplane has one Tail Number, Tail Number is of one Airplane;
    
each Assigned Airplane is where
    Airplane is assigned to Connection;

// Passenger
each Birth Date is written as DateTime;
each Preferred Dish is written as String;

each Passenger is identified by its ID;
Passenger has one [satellite passenger name, point in time] Name;
Passenger has one Birth Date;
Passenger has one [satellite preferred dish, point in time] Preferred Dish;

// Part
each Part is identified by its ID;

each Airplane Part is where
    Airplane has Part;

Manufacturer is identified by its ID;
Part is built by one Manufacturer;

// Booking
each Sales Agent [separate] is identified by its Name;

each Booking is where
    Passenger books flight with Sales Agent;
