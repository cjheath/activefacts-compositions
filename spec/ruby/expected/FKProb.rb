require 'activefacts/api'

module FKProb
  class OT
    identified_by   :name
    one_to_one      :name, mandatory: true              # OT is called Name, see Name#ot
  end

  class DOT < OT
  end

  class Name < String
    value_type
  end

  class VT < DOT
  end

  class VTP
    identified_by   :vt, :name
    has_one         :vt, mandatory: true, class: VT     # VTP involves VT, see VT#all_vtp_as_vt
    has_one         :name, mandatory: true              # VTP involves Name, see Name#all_vtp
  end

  class VTPRestriction
    identified_by   :vt, :vtp
    has_one         :vt, mandatory: true, class: VT     # VTPRestriction involves VT, see VT#all_vtp_restriction_as_vt
    has_one         :vtp, mandatory: true, class: VTP   # VTPRestriction involves VTP, see VTP#all_vtp_restriction_as_vtp
  end
end
