transform Null_Person;


import target Person;

Address <== /* OBJECT TYPE or QUERY */ {
    Address Ref <-- /* EXPR */,
    Country <-- /* EXPR */,
    Employer Address . Employer . Employer ID <-- /* EXPR */,
    Locality <-- /* EXPR */,
    Person Address . Person . Person ID <-- /* EXPR */,
    Postal Code <-- /* EXPR */,
    Region <-- /* EXPR */
};

Address Purpose <== /* OBJECT TYPE or QUERY */ {
    Address . Address Ref <-- /* EXPR */,
    Addr Purpose <-- /* EXPR */
};

Address Street <== /* OBJECT TYPE or QUERY */ {
    Address . Address Ref <-- /* EXPR */,
    Street Line <-- /* EXPR */
};

Employer <== /* OBJECT TYPE or QUERY */ {
    Employer ID <-- /* EXPR */,
    Name <-- /* EXPR */
};

Employment <== /* OBJECT TYPE or QUERY */ {
    Person . Person ID <-- /* EXPR */,
    Employer . Employer ID <-- /* EXPR */,
    create- Date <-- /* EXPR */,
    effective- end Date <-- /* EXPR */,
    effective- start Date <-- /* EXPR */,
    Status <-- /* EXPR */
};

Name Variations <== /* OBJECT TYPE or QUERY */ {
    Name Variations Self <-- /* EXPR */,
    first- Name <-- /* EXPR */,
    last- Name <-- /* EXPR */,
    formal- letter Name <-- /* EXPR */,
    informal- letter Name <-- /* EXPR */,
    legal- Name <-- /* EXPR */,
    maiden- Name <-- /* EXPR */,
    middle- Name <-- /* EXPR */,
    nick- Name <-- /* EXPR */,
    sorted- Name <-- /* EXPR */
};

Person <== /* OBJECT TYPE or QUERY */ {
    Person ID <-- /* EXPR */,
    Name <-- /* EXPR */,
    Name Variations . Name Variations Self <-- /* EXPR */,
    Status <-- /* EXPR */,
    birth- Date <-- /* EXPR */,
    Ethnicity <-- /* EXPR */,
    Gender <-- /* EXPR */,
    Has Parent . parent- Person . Person ID <-- /* EXPR */,
    Has Spouse . spouse- Person . Person ID <-- /* EXPR */,
    online- Name <-- /* EXPR */,
    Shipping Preference <-- /* EXPR */
};

Phone Purpose <== /* OBJECT TYPE or QUERY */ {
    Phone <== /* OBJECT TYPE or QUERY */ {
        Phone Self <-- /* EXPR */,
        Person Phone . Person . Person ID <-- /* EXPR */,
        Phone Number <-- /* EXPR */
    },
    Purpose <-- /* EXPR */
};

