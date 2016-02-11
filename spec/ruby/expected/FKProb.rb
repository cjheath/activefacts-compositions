require 'activefacts/api'

module FKProb
  class Name < String
    value_type
  end

  class OT
    identified_by   :name
    one_to_one      :name, mandatory: true              # OT is called Name, see Name#ot
  end

  class DOT < OT
  end

  class VT < DOT
  end

  class VTP
    identified_by   :vt, :name
    has_one         :vt, mandatory: true                # VTP involves VT, see VT#all_vtp
    has_one         :name, mandatory: true              # VTP involves Name, see Name#all_vtp
  end

  class VTPRestriction
    identified_by   :vt, :vtp
    has_one         :vt, mandatory: true                # VTPRestriction involves VT, see VT#all_vtp_restriction
    has_one         :vtp, mandatory: true               # VTPRestriction involves VTP, see VTP#all_vtp_restriction
  end
end