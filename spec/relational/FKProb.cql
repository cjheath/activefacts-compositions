vocabulary FKProblem;

Name is written as String;

OT is identified by Name where
	OT is called one Name;

DOT is a kind of OT;

VT is a kind of DOT;

VTP [separate] is where
	VT has facet called Name,
	Name is a facet of VT;

/*
 * This should be equivalent, but doesn't fail where the above does (need a base_role somewhere?)
VTP [separate] is identified by VT and facet-Name where
	VTP applies to one VT,
	VTP is called one facet-Name;
*/

VTPRestriction is where
	VT receives VTP,
	VTP applies to VT;
