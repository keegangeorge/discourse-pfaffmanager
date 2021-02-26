# frozen_string_literal: true

class PfaffmanagerInstallType
  STD ||= "std"
  PRO ||= "pro"
  LITE ||= "lite"
  EC2 ||= "ec2"

  def self.valid_value?(val)
    values.any? { |v| v[:value] == val }
  end

  def self.values
    @values ||= [
        { name: I18n.t("js.pfaffmanager.install_type." + LITE), value: LITE },
        { name: I18n.t("js.pfaffmanager.install_type." + EC2), value: EC2 },
        { name: I18n.t("js.pfaffmanager.install_type." + STD), value: STD },
        { name: I18n.t("js.pfaffmanager.install_type." + PRO), value: PRO },
    ]
  end

  def self.translate_names?
    true
  end
end
