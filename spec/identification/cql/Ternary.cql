vocabulary Ternary;

Thing is written as Thing;

// Two uniqueness constraints over the same Ternary
// Check that the computed indices work correctly:
each Ternary is where
    some first- Thing with some second- Thing relates to one third- Thing,
    that third Thing holds that second Thing for one first-Thing;
