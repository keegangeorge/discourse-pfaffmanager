# frozen_string_literal: true
class PfaffmanagerConstraint
  def matches?(request)
    SiteSetting.pfaffmanager_enabled
  end
end
