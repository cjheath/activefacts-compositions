/*
 * FIML definitions for the schema used in Data Vault 2.0 Modeling book by Dan Linstedt
 */
schema DV2BookBDV;

import schema DV2Book;

/*
 * Computed Satellite data
 */
each Age is written as Integer;
    
Passenger has one Age /*[satellite PassengerBDV]*/ where
    Passenger has Birth Date,
    Age = /*DATEDIFF('year', Birth Date, NOW())*/ 18;

/*
 * Same as Link
 */

each Passenger Same As [separate, same as link] is where
    Passenger is same as at most one master- Passenger;

/*
 * Hierarchy Link
 */

each Part Hierachy [separate, hierarchy link] is where
    Part is child of at most one parent- Part;

/*
 * Computed Link
 */

Service [computed link] is where
    Airline flies from origin- Airport to destination- Airport;
    
// Service has Count where
//     count of Flight Number in Connection;
    
/*
 * Exploration Link
 */

each Airplane Part Manufacturer [exploration link] is where
    Airplane has parts from Manufacturer;

Airplane has parts from Manufacturer where
    Airplane has Part,
    Part is built by Manufacturer;

/*
 * Point in Time
 */

Passenger has one [point in time] Name;

/*
 * Bridge tables
 */

each Passenger Sales Agent [bridge] is where
    Passenger books a flight with Sales Agent;
