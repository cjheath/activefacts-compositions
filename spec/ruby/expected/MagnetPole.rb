require 'activefacts/api'

module MagnetPole
  class MagnetAutoCounter < AutoCounter
    value_type
  end

  class Magnet
    identified_by   :magnet_auto_counter
    one_to_one      :magnet_auto_counter, mandatory: true  # Magnet has Magnet AutoCounter, see MagnetAutoCounter#magnet
  end

  class MagnetPole
    identified_by   :magnet, :is_north
    has_one         :magnet, mandatory: true            # MagnetPole belongs to Magnet, see Magnet#all_magnet_pole
    maybe           :is_north                           # Is North
  end
end