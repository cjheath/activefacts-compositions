transform Staff_Personnel;

import source Staff;
import target Personnel;

/*
Personnel <== Professor has ID, Address has ID {
    ID <-- ID,
    Name <-- Name,
    Addr <-- Addr,
    Salary <-- Salary
};

Personnel <== Student has Name, WorksOn has Name {
    Name <-- Name,
    Salary <-- HrRate * Hours
};

*/