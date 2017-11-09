require 'activefacts/api'

module Separate
  class Base
    identified_by   :base_guid
    one_to_one      :base_guid, mandatory: true, class: "BaseGUID"  # Base has Base GUID, see BaseGUID#base_as_base_guid
    has_one         :base_val, mandatory: true, class: "Val"  # Base has base-Val, see Val#all_base_as_base_val
  end

  class PartitionInd < Base
    identified_by   :partition_ind_key
    one_to_one      :partition_ind_key, mandatory: true  # PartitionInd has PartitionInd Key, see PartitionIndKey#partition_ind
  end

  class Val < ::Val
    value_type
  end

  class AbsorbedPart < PartitionInd
    has_one         :abs_part_val, mandatory: true, class: Val  # AbsorbedPart has abs- part Val, see Val#all_absorbed_part_as_abs_part_val
  end

  class BaseGUID < GUID
    value_type
  end

  class Key < GUID
    value_type
  end

  class Partition < Base
    has_one         :part_val, mandatory: true, class: Val  # Partition has part-Val, see Val#all_partition_as_part_val
  end

  class PartitionIndKey < Key
    value_type
  end

  class Separate < Base
    has_one         :sep_val, mandatory: true, class: Val  # Separate has sep-Val, see Val#all_separate_as_sep_val
  end
end
