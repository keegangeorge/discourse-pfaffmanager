class PfaffmanagerConstraint
  def matches?(request)
    SiteSetting.pfaffmanager_enabled
  end
end
