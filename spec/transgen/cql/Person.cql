schema Person version 1.2.3;

each ID is written as Auto Counter;
each Self is written as Self;
each Ref is written as Ref;
each Name is written as String;
each Date is written as DateTime;

each Person [separate] is identified by its ID;

each Status is written as String restricted to {'active', 'inactive'};

Person has one Status;
Person has one Name;
Person has at most one online- Name;

each Name Variations is identified by its Self;

Name Variations has one first- Name;
Name Variations has at most one middle- Name;
Name Variations has one last- Name;
Name Variations has at most one maiden- Name;
Name Variations has at most one nick- Name;
Name Variations has at most one legal- Name;
Name Variations has at most one sorted- Name;
Name Variations has at most one informal- letter Name;
Name Variations has at most one formal- letter Name;

Person has one Name Variations;

Person has at most one birth- Date;

each Gender is written as String restricted to {'male', 'female'};
Person has at most one Gender;

each Ethnicity is written as String;
Person has at most one Ethnicity;

each Shipping Preference is written as String;
Person has at most one Shipping Preference;

// Person Phones

Purpose is written as String restricted to {'work', 'home', 'mobile', 'primary'};
Phone Number is written as String;

each Phone is identified by its Self;

each Phone Purpose is where
    Phone has Purpose, Purpose is of Phone;
Phone has one Phone Number;

Person Phone is where
    Person has Phone, Phone is number of one Person;

// Person Address

each Address [separate] is identified by its Ref;

each Addr Purpose is written as String restricted to {'shipping', 'mailing'};
each Street Line is written as String;
each Locality is written as String;
each Region is written as String;
each Postal Code is written as String;
each Country is written as String;

each Address Purpose is where
    Address has at least one Addr Purpose;

each Address Street is where
    Address has at least one Street Line;

Address is located in one Locality;
Address is located in one Region;
Address has one Postal Code;
Address is located in one Country;

each Person Address is where
    Person has Address, Address is address of one Person;
    
//
// Person relationships
//
each Has Spouse [triple] is where
    Person has at most one spouse- Person;

each Has Parent [triple] is where
    Person has at most one parent- Person;

each Employer is identified by its ID;

Employer has one Name;

each Employer Address is where
    Employer has Address, Address is address of one Employer;

each Employment is where
    Person is employed by Employer,
    Employer employs Person;
Employment has one Status;
Employment has one create- Date;
Employment has one effective- start Date;
Employment has one effective- end Date;
