# frozen_string_literal: true

class PfaffmanagerInstallType
  STD ||= "Standard"
  LITE ||= "Lite"
  EC2 ||= "EC2"

  def self.valid_value?(val)
    values.any? { |v| v[:value] == val }
  end

  def self.values
    @values ||= [
        { name: "pfaffmanager.install_type.lite", value: LITE },
        { name: "pfaffmanager.install_type.ec2", value: EC2 },
        { name: "pfaffmanager.install_type.std", value: STD },
    ]
  end

  def self.translate_names?
    true
  end
end
