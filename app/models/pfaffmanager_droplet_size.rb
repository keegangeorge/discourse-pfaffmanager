# frozen_string_literal: true

class PfaffmanagerDropletSize
  AMD1CPU1GB ||= "s-1vcpu-1gb-amd"
  AMD1CPU2GB ||= "s-1vcpu-2gb-amd"
  AMD2CPU2GB ||= "s-2vcpu-2gb-amd"
  AMD1CPU1GB ||= "s-1vcpu-1gb-amd"
  INTEL1CPU2GB ||= "s-1vcpu-2gb-intel"
  INTEL1CPU2GB ||= "s-1vcpu-2gb-intel"
  INTEL2CPU2GB ||= "s-2vcpu-2gb-intel"
  FIVEDOLLAR ||= "s-1vcpu-1gb"

  def self.valid_value?(val)
    values.any? { |v| v[:value] == val }
  end

  def self.values
    @values ||= [
        { name: "pfaffmanager.do.size.AMD1CPU1GB", value: AMD1CPU1GB },
        { name: "pfaffmanager.do.size.AMD1CPU2GB", value: AMD1CPU2GB },
    ]
  end

  def self.translate_names?
    true
  end
end
