transform Staff_Personnel;

import source Staff;
import target Personnel;

Personnel <== /* OBJECT TYPE or QUERY */ {
    Personnel ID <-- /* EXPR */,
    Addr <-- /* EXPR */,
    Name <-- /* EXPR */,
    Salary <-- /* EXPR */
};

